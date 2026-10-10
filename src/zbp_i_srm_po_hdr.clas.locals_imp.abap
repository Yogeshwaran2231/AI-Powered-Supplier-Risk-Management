CLASS lhc_PurchaseOrder DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations
      FOR PurchaseOrder
      RESULT result.

    METHODS recalculatePOTotals
      FOR MODIFY
      IMPORTING keys
      FOR ACTION PurchaseOrder~recalculatePOTotals.

ENDCLASS.


CLASS lhc_PurchaseOrder IMPLEMENTATION.

  METHOD get_global_authorizations.

    result-%create = if_abap_behv=>auth-allowed.

  ENDMETHOD.


  METHOD recalculatePOTotals.

    READ ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrder BY \_Items
      FIELDS ( PoId NetAmount TaxAmount ItemTotalAmount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    READ ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( PoId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    DATA lt_update TYPE TABLE FOR UPDATE zi_srm_po_hdr.

    LOOP AT lt_headers INTO DATA(ls_header).

      DATA(lv_net)   = CONV decfloat34( 0 ).
      DATA(lv_tax)   = CONV decfloat34( 0 ).
      DATA(lv_total) = CONV decfloat34( 0 ).

      LOOP AT lt_items INTO DATA(ls_item)
        WHERE PoId = ls_header-PoId.

        lv_net =
          lv_net + CONV decfloat34( ls_item-NetAmount ).

        lv_tax =
          lv_tax + CONV decfloat34( ls_item-TaxAmount ).

        lv_total =
          lv_total + CONV decfloat34( ls_item-ItemTotalAmount ).

      ENDLOOP.

      APPEND VALUE #(
        %tky = ls_header-%tky

        TotalNetAmount =
          CONV #( round(
            val = lv_net
            dec = 2 ) )

        TotalTaxAmount =
          CONV #( round(
            val = lv_tax
            dec = 2 ) )

        TotalAmount =
          CONV #( round(
            val = lv_total
            dec = 2 ) )
      ) TO lt_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrder
      UPDATE FIELDS
        ( TotalNetAmount
          TotalTaxAmount
          TotalAmount )
      WITH lt_update.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_PurchaseOrderItem DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateItemAmounts
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR PurchaseOrderItem~calculateItemAmounts.

ENDCLASS.


CLASS lhc_PurchaseOrderItem IMPLEMENTATION.

  METHOD calculateItemAmounts.

    READ ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrderItem
      FIELDS ( Quantity UnitPrice TaxRate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    MODIFY ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrderItem
      UPDATE FIELDS
        ( NetAmount
          TaxAmount
          ItemTotalAmount )
      WITH VALUE #(
        FOR item IN lt_items

        LET
          lv_net =
            CONV decfloat34( item-Quantity )
            * CONV decfloat34( item-UnitPrice )

          lv_tax =
            lv_net
            * CONV decfloat34( item-TaxRate )
            / 100

          lv_total =
            lv_net + lv_tax

        IN
          ( %tky = item-%tky

            NetAmount =
              CONV #( round(
                val = lv_net
                dec = 2 ) )

            TaxAmount =
              CONV #( round(
                val = lv_tax
                dec = 2 ) )

            ItemTotalAmount =
              CONV #( round(
                val = lv_total
                dec = 2 ) )
          )
      ).

    READ ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrderItem BY \_PurchaseOrder
      FIELDS ( PoId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_purchase_orders).

    SORT lt_purchase_orders BY %tky.
    DELETE ADJACENT DUPLICATES FROM lt_purchase_orders
      COMPARING %tky.

    MODIFY ENTITIES OF zi_srm_po_hdr IN LOCAL MODE
      ENTITY PurchaseOrder
      EXECUTE recalculatePOTotals
      FROM CORRESPONDING #( lt_purchase_orders ).

  ENDMETHOD.

ENDCLASS.


