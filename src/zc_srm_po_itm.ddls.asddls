@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection item po'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_srm_po_itm 
as projection on zi_srm_po_itm
{
    key PoId,
    key ItemNo,
    MaterialId,
    MaterialDesc,
    Unit,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    Quantity,
    CurrencyCode,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    UnitPrice,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    NetAmount,
    TaxRate,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    TaxAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    ItemTotalAmount,
     @Semantics.quantity.unitOfMeasure: 'Unit'
    DeliveredQty,
    ItemStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
     _PurchaseOrder : redirected to parent zc_srm_po_hdr
}
