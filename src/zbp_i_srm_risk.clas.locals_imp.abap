CLASS lhc_Risk DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateRiskAnalysis
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Risk~calculateRiskAnalysis.

ENDCLASS.


CLASS lhc_Risk IMPLEMENTATION.

  METHOD calculateRiskAnalysis.

    "------------------------------------------------------------
    " Read Risk records
    "------------------------------------------------------------
    READ ENTITIES OF zi_srm_risk IN LOCAL MODE
      ENTITY Risk
      FIELDS (
        RiskId
        VendorId
        PoId
        InvoiceId
        DisruptionId
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_risks).

    CHECK lt_risks IS NOT INITIAL.


    "------------------------------------------------------------
    " Table for calculated Risk values
    "------------------------------------------------------------
    DATA lt_update TYPE TABLE FOR UPDATE zi_srm_risk.


    LOOP AT lt_risks INTO DATA(ls_risk).

      "----------------------------------------------------------
      " Default scores
      "----------------------------------------------------------
      DATA(lv_supplier_score)   = CONV decfloat34( 0 ).
      DATA(lv_delivery_score)   = CONV decfloat34( 0 ).
      DATA(lv_financial_score)  = CONV decfloat34( 0 ).
      DATA(lv_disruption_score) = CONV decfloat34( 0 ).


      "==========================================================
      " 1. SUPPLIER RISK
      "==========================================================
      DATA lv_vendor_status        TYPE string.
      DATA lv_supplier_criticality TYPE string.

      DATA lv_lead_time
        TYPE zsrm_vendor-lead_time_days.

      CLEAR lv_vendor_status.
      CLEAR lv_supplier_criticality.
      CLEAR lv_lead_time.


      IF ls_risk-VendorId IS NOT INITIAL.

        SELECT SINGLE
          vendor_status,
          supplier_criticality,
          lead_time_days
          FROM zsrm_vendor
          WHERE vendor_id = @ls_risk-VendorId
          INTO (
            @lv_vendor_status,
            @lv_supplier_criticality,
            @lv_lead_time
          ).

        IF sy-subrc = 0.

          " Supplier criticality
          IF lv_supplier_criticality = 'CRITICAL'.

            lv_supplier_score = 90.

          ELSEIF lv_supplier_criticality = 'HIGH'.

            lv_supplier_score = 70.

          ELSEIF lv_supplier_criticality = 'MEDIUM'.

            lv_supplier_score = 40.

          ELSEIF lv_supplier_criticality = 'LOW'.

            lv_supplier_score = 20.

          ELSE.

            lv_supplier_score = 10.

          ENDIF.


          " Supplier status
          IF lv_vendor_status = 'BLOCKED'
             OR lv_vendor_status = 'INACTIVE'.

            lv_supplier_score =
              lv_supplier_score + 20.

          ENDIF.


          " Lead time
          IF lv_lead_time > 60.

            lv_supplier_score =
              lv_supplier_score + 15.

          ELSEIF lv_lead_time > 30.

            lv_supplier_score =
              lv_supplier_score + 10.

          ENDIF.


          " Maximum 100
          IF lv_supplier_score > 100.

            lv_supplier_score = 100.

          ENDIF.

        ENDIF.

      ENDIF.


      "==========================================================
      " 2. DELIVERY RISK
      "==========================================================
      DATA lv_delivery_status TYPE string.

      DATA lv_delay_days
        TYPE zsrm_po_hdr-delivery_delay_days.

      CLEAR lv_delivery_status.
      CLEAR lv_delay_days.


      IF ls_risk-PoId IS NOT INITIAL.

        SELECT SINGLE
          delivery_delay_days,
          delivery_status
          FROM zsrm_po_hdr
          WHERE po_id = @ls_risk-PoId
          INTO (
            @lv_delay_days,
            @lv_delivery_status
          ).

        IF sy-subrc = 0.

          " Delivery delay
          IF lv_delay_days >= 30.

            lv_delivery_score = 100.

          ELSEIF lv_delay_days >= 15.

            lv_delivery_score = 80.

          ELSEIF lv_delay_days >= 8.

            lv_delivery_score = 60.

          ELSEIF lv_delay_days >= 3.

            lv_delivery_score = 40.

          ELSEIF lv_delay_days > 0.

            lv_delivery_score = 20.

          ELSE.

            lv_delivery_score = 0.

          ENDIF.


          " Delayed PO status
          IF lv_delivery_status = 'DELAYED'
             AND lv_delivery_score < 80.

            lv_delivery_score =
              lv_delivery_score + 20.

          ENDIF.


          " Maximum 100
          IF lv_delivery_score > 100.

            lv_delivery_score = 100.

          ENDIF.

        ENDIF.

      ENDIF.


      "==========================================================
      " 3. FINANCIAL RISK
      "==========================================================
      DATA lv_match_status TYPE string.

      DATA lv_amount_variance
        TYPE zsrm_invoice-amount_variance.

      CLEAR lv_match_status.
      CLEAR lv_amount_variance.


      IF ls_risk-InvoiceId IS NOT INITIAL.

        SELECT SINGLE
          match_status,
          amount_variance
          FROM zsrm_invoice
          WHERE invoice_id = @ls_risk-InvoiceId
          INTO (
            @lv_match_status,
            @lv_amount_variance
          ).

        IF sy-subrc = 0.

          " Invoice matching
          IF lv_match_status = 'MATCH'.

            lv_financial_score = 0.

          ELSEIF lv_match_status = 'MISMATCH'.

            lv_financial_score = 80.

          ELSEIF lv_match_status = 'PO_NOT_FOUND'.

            lv_financial_score = 60.

          ELSE.

            lv_financial_score = 30.

          ENDIF.


          " Amount variance
          IF abs( CONV decfloat34( lv_amount_variance ) ) >= 100000.

            lv_financial_score =
              lv_financial_score + 20.

          ELSEIF abs( CONV decfloat34( lv_amount_variance ) ) >= 50000.

            lv_financial_score =
              lv_financial_score + 10.

          ENDIF.


          " Maximum 100
          IF lv_financial_score > 100.

            lv_financial_score = 100.

          ENDIF.

        ENDIF.

      ENDIF.


      "==========================================================
      " 4. DISRUPTION RISK
      "==========================================================
      DATA lv_severity TYPE string.

      DATA lv_impacted_days
        TYPE zsrm_disruption-impacted_days.

      CLEAR lv_severity.
      CLEAR lv_impacted_days.


      IF ls_risk-DisruptionId IS NOT INITIAL.

        SELECT SINGLE
          severity,
          impacted_days
          FROM zsrm_disruption
          WHERE disruption_id = @ls_risk-DisruptionId
          INTO (
            @lv_severity,
            @lv_impacted_days
          ).

        IF sy-subrc = 0.

          " Disruption severity
          IF lv_severity = 'CRITICAL'.

            lv_disruption_score = 100.

          ELSEIF lv_severity = 'HIGH'.

            lv_disruption_score = 80.

          ELSEIF lv_severity = 'MEDIUM'.

            lv_disruption_score = 50.

          ELSEIF lv_severity = 'LOW'.

            lv_disruption_score = 20.

          ELSE.

            lv_disruption_score = 10.

          ENDIF.


          " Duration impact
          IF lv_impacted_days >= 30.

            lv_disruption_score =
              lv_disruption_score + 20.

          ELSEIF lv_impacted_days >= 15.

            lv_disruption_score =
              lv_disruption_score + 10.

          ENDIF.


          " Maximum 100
          IF lv_disruption_score > 100.

            lv_disruption_score = 100.

          ENDIF.

        ENDIF.

      ENDIF.


      "==========================================================
      " 5. OVERALL RISK SCORE
      "==========================================================
      DATA(lv_overall_score) =
          ( lv_supplier_score
          + lv_delivery_score
          + lv_financial_score
          + lv_disruption_score ) / 4.


      "==========================================================
      " 6. RISK LEVEL
      "==========================================================
      DATA lv_risk_level TYPE string.


      IF lv_overall_score >= 75.

        lv_risk_level = 'CRITICAL'.

      ELSEIF lv_overall_score >= 50.

        lv_risk_level = 'HIGH'.

      ELSEIF lv_overall_score >= 25.

        lv_risk_level = 'MEDIUM'.

      ELSE.

        lv_risk_level = 'LOW'.

      ENDIF.


      "==========================================================
      " 7. RISK REASON
      "==========================================================
      DATA lv_risk_reason TYPE string.

      lv_risk_reason =
        |Supplier={ lv_supplier_score }, |
        && |Delivery={ lv_delivery_score }, |
        && |Financial={ lv_financial_score }, |
        && |Disruption={ lv_disruption_score }.|.


      "==========================================================
      " 8. AI INSIGHT
      "==========================================================
      DATA lv_ai_insight TYPE string.

      lv_ai_insight =
        |Risk analysis identified { lv_risk_level } risk |
        && |with an overall score of { lv_overall_score }.|.


      "==========================================================
      " 9. RECOMMENDED ACTION
      "==========================================================
      DATA lv_recommended_action TYPE string.


      IF lv_risk_level = 'CRITICAL'.

        lv_recommended_action =
          'Immediate supplier review, procurement escalation and contingency sourcing required.'.

      ELSEIF lv_risk_level = 'HIGH'.

        lv_recommended_action =
          'Review supplier performance, delivery plan and alternate sourcing options.'.

      ELSEIF lv_risk_level = 'MEDIUM'.

        lv_recommended_action =
          'Monitor supplier, delivery and financial conditions closely.'.

      ELSE.

        lv_recommended_action =
          'Continue normal monitoring.'.

      ENDIF.


      "==========================================================
      " 10. ALERT STATUS
      "==========================================================
      DATA lv_alert_status TYPE string.


      IF lv_risk_level = 'CRITICAL'
         OR lv_risk_level = 'HIGH'.

        lv_alert_status = 'ALERT'.

      ELSE.

        lv_alert_status = 'NORMAL'.

      ENDIF.


      "==========================================================
      " 11. RISK STATUS
      "==========================================================
      DATA lv_risk_status TYPE string.

      lv_risk_status = 'OPEN'.


      "==========================================================
      " 12. UPDATE RISK ENTITY
      "==========================================================
      APPEND VALUE #(
        %tky = ls_risk-%tky

        SupplierRiskScore =
          CONV #( round(
            val = lv_supplier_score
            dec = 2 ) )

        DeliveryRiskScore =
          CONV #( round(
            val = lv_delivery_score
            dec = 2 ) )

        FinancialRiskScore =
          CONV #( round(
            val = lv_financial_score
            dec = 2 ) )

        DisruptionRiskScore =
          CONV #( round(
            val = lv_disruption_score
            dec = 2 ) )

        OverallRiskScore =
          CONV #( round(
            val = lv_overall_score
            dec = 2 ) )

        RiskLevel =
          lv_risk_level

        RiskReason =
          lv_risk_reason

        AIInsight =
          lv_ai_insight

        RecommendedAction =
          lv_recommended_action

        AlertStatus =
          lv_alert_status

        RiskStatus =
          lv_risk_status

      ) TO lt_update.

    ENDLOOP.


    "============================================================
    " 13. UPDATE BUSINESS OBJECT
    "============================================================
    MODIFY ENTITIES OF zi_srm_risk IN LOCAL MODE
      ENTITY Risk
      UPDATE FIELDS (
        SupplierRiskScore
        DeliveryRiskScore
        FinancialRiskScore
        DisruptionRiskScore
        OverallRiskScore
        RiskLevel
        RiskReason
        AIInsight
        RecommendedAction
        AlertStatus
        RiskStatus
      )
      WITH lt_update.

  ENDMETHOD.

ENDCLASS.

