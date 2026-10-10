CLASS lhc_Invoice DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateInvoiceAnalysis
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Invoice~calculateInvoiceAnalysis.

ENDCLASS.


CLASS lhc_Invoice IMPLEMENTATION.

  METHOD calculateInvoiceAnalysis.

    READ ENTITIES OF zi_srm_invoice IN LOCAL MODE
      ENTITY Invoice
      FIELDS (
        InvoiceId
        PoId
        InvoiceNetAmount
        InvoiceTaxAmount
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_invoices).

    DATA lt_update TYPE TABLE FOR UPDATE zi_srm_invoice.

    LOOP AT lt_invoices INTO DATA(ls_invoice).

      "--------------------------------------------------------
      " Calculate Invoice Total
      "--------------------------------------------------------
      DATA(lv_invoice_total) =
          CONV decfloat34( ls_invoice-InvoiceNetAmount )
        + CONV decfloat34( ls_invoice-InvoiceTaxAmount ).

      "--------------------------------------------------------
      " Read Purchase Order Total
      "--------------------------------------------------------
      DATA(lv_po_total) = CONV decfloat34( 0 ).
      DATA(lv_po_found) = abap_false.

      SELECT SINGLE total_amount
        FROM zsrm_po_hdr
        WHERE po_id = @ls_invoice-PoId
        INTO @DATA(lv_db_po_total).

      IF sy-subrc = 0.

        lv_po_total = CONV decfloat34( lv_db_po_total ).
        lv_po_found = abap_true.

      ENDIF.

      "--------------------------------------------------------
      " Calculate Variance
      "--------------------------------------------------------
      DATA(lv_variance) =
          lv_invoice_total - lv_po_total.

      "--------------------------------------------------------
      " Determine Match Status
      "--------------------------------------------------------
      DATA lv_match_status TYPE c LENGTH 15.

      IF lv_po_found = abap_false.

        lv_match_status = 'PO_NOT_FOUND'.

      ELSEIF lv_variance = 0.

        lv_match_status = 'MATCH'.

      ELSE.

        lv_match_status = 'MISMATCH'.

      ENDIF.

      "--------------------------------------------------------
      " Prepare Update
      "--------------------------------------------------------
      APPEND VALUE #(
        %tky = ls_invoice-%tky

        InvoiceTotalAmount =
          CONV #( round(
            val = lv_invoice_total
            dec = 2 ) )

        PoTotalAmount =
          CONV #( round(
            val = lv_po_total
            dec = 2 ) )

        AmountVariance =
          CONV #( round(
            val = lv_variance
            dec = 2 ) )

        MatchStatus = lv_match_status

      ) TO lt_update.

    ENDLOOP.

    "--------------------------------------------------------
    " Update Invoice Business Object
    "--------------------------------------------------------
    MODIFY ENTITIES OF zi_srm_invoice IN LOCAL MODE
      ENTITY Invoice
      UPDATE FIELDS
        (
          InvoiceTotalAmount
          PoTotalAmount
          AmountVariance
          MatchStatus
        )
      WITH lt_update.

  ENDMETHOD.

ENDCLASS.


