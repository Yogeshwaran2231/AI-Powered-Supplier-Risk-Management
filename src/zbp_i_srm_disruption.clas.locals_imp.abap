CLASS lhc_Disruption DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS analyzeDisruption
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Disruption~analyzeDisruption.

ENDCLASS.


CLASS lhc_Disruption IMPLEMENTATION.

  METHOD analyzeDisruption.

    "------------------------------------------------------------
    " Read disruption instances that triggered the determination
    "------------------------------------------------------------
    READ ENTITIES OF zi_srm_disruption IN LOCAL MODE
      ENTITY Disruption
      FIELDS (
        DisruptionId
        VendorId
        PoId
        DisruptionType
        DisruptionTitle
        DisruptionDescription
        Severity
        ImpactArea
        StartDate
        EndDate
        SourceType
        SourceReference
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_disruptions).

    CHECK lt_disruptions IS NOT INITIAL.


    "------------------------------------------------------------
    " Table for calculated values
    "------------------------------------------------------------
    DATA lt_update TYPE TABLE FOR UPDATE zi_srm_disruption.


    LOOP AT lt_disruptions INTO DATA(ls_disruption).

      "----------------------------------------------------------
      " Use exact DDIC types from ZSRM_DISRUPTION
      "----------------------------------------------------------
      DATA lv_impacted_days
        TYPE zsrm_disruption-impacted_days.

      DATA lv_start_date
        TYPE zsrm_disruption-start_date.

      DATA lv_end_date
        TYPE zsrm_disruption-end_date.

      DATA lv_ai_analysis
        TYPE zsrm_disruption-ai_analysis.


      CLEAR lv_impacted_days.
      CLEAR lv_ai_analysis.


      "----------------------------------------------------------
      " Copy dates
      "----------------------------------------------------------
      lv_start_date = ls_disruption-StartDate.
      lv_end_date   = ls_disruption-EndDate.


      "----------------------------------------------------------
      " 1. Calculate Impacted Days
      "----------------------------------------------------------
      IF lv_start_date IS NOT INITIAL
         AND lv_end_date IS NOT INITIAL.

        IF lv_end_date >= lv_start_date.

          lv_impacted_days =
            ( lv_end_date - lv_start_date ) + 1.

        ELSE.

          lv_impacted_days = 0.

        ENDIF.

      ELSE.

        lv_impacted_days = 0.

      ENDIF.


      "----------------------------------------------------------
      " 2. Generate analysis based on severity
      "----------------------------------------------------------
      IF ls_disruption-Severity = 'CRITICAL'.

        lv_ai_analysis =
          |Critical disruption detected. Immediate procurement |
          && |attention is required. Expected impact duration: |
          && |{ lv_impacted_days } day(s).|.

      ELSEIF ls_disruption-Severity = 'HIGH'.

        lv_ai_analysis =
          |High-severity disruption identified. Supplier and |
          && |supply continuity should be reviewed. Expected |
          && |impact duration: { lv_impacted_days } day(s).|.

      ELSEIF ls_disruption-Severity = 'MEDIUM'.

        lv_ai_analysis =
          |Medium-severity disruption identified. Close |
          && |monitoring of supplier and delivery impact is |
          && |recommended. Expected impact duration: |
          && |{ lv_impacted_days } day(s).|.

      ELSEIF ls_disruption-Severity = 'LOW'.

        lv_ai_analysis =
          |Low-severity disruption identified. Normal monitoring |
          && |is recommended. Expected impact duration: |
          && |{ lv_impacted_days } day(s).|.

      ELSE.

        lv_ai_analysis =
          |Disruption recorded. Further assessment is required. |
          && |Expected impact duration: |
          && |{ lv_impacted_days } day(s).|.

      ENDIF.


      "----------------------------------------------------------
      " 3. Add impact area
      "----------------------------------------------------------
      IF ls_disruption-ImpactArea IS NOT INITIAL.

        lv_ai_analysis =
          lv_ai_analysis
          && | Impact area: { ls_disruption-ImpactArea }.|.

      ENDIF.


      "----------------------------------------------------------
      " 4. Add disruption type
      "----------------------------------------------------------
      IF ls_disruption-DisruptionType IS NOT INITIAL.

        lv_ai_analysis =
          lv_ai_analysis
          && | Disruption type: { ls_disruption-DisruptionType }.|.

      ENDIF.


      "----------------------------------------------------------
      " 5. Add title information
      "----------------------------------------------------------
      IF ls_disruption-DisruptionTitle IS NOT INITIAL.

        lv_ai_analysis =
          lv_ai_analysis
          && | Event: { ls_disruption-DisruptionTitle }.|.

      ENDIF.


      "----------------------------------------------------------
      " 6. Add recommended action
      "----------------------------------------------------------
      IF ls_disruption-Severity = 'CRITICAL'.

        lv_ai_analysis =
          lv_ai_analysis
          && | Recommended action: activate contingency sourcing, |
          && |escalate procurement, and assess alternate suppliers.|.

      ELSEIF ls_disruption-Severity = 'HIGH'.

        lv_ai_analysis =
          lv_ai_analysis
          && | Recommended action: review alternate suppliers |
          && |and revise the procurement plan.|.

      ELSEIF ls_disruption-Severity = 'MEDIUM'.

        lv_ai_analysis =
          lv_ai_analysis
          && | Recommended action: monitor the event and |
          && |review delivery alternatives.|.

      ELSE.

        lv_ai_analysis =
          lv_ai_analysis
          && | Recommended action: continue normal monitoring.|.

      ENDIF.


      "----------------------------------------------------------
      " 7. Update calculated fields
      "----------------------------------------------------------
      APPEND VALUE #(
        %tky = ls_disruption-%tky

        ImpactedDays = lv_impacted_days

        AIAnalysis = lv_ai_analysis

      ) TO lt_update.

    ENDLOOP.


    "------------------------------------------------------------
    " 8. Update RAP transactional buffer
    "------------------------------------------------------------
    MODIFY ENTITIES OF zi_srm_disruption IN LOCAL MODE
      ENTITY Disruption
      UPDATE FIELDS (
        ImpactedDays
        AIAnalysis
      )
      WITH lt_update.

  ENDMETHOD.

ENDCLASS.


