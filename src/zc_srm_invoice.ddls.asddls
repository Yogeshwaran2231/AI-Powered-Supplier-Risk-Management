@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection invoice'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_srm_invoice 
provider contract transactional_query
as projection on zi_srm_invoice
{
    key InvoiceId,
    PoId,
    VendorId,
    InvoiceDate,
    DueDate,
    CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    InvoiceNetAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    InvoiceTaxAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    InvoiceTotalAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    PoTotalAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    AmountVariance,
    MatchStatus,
    InvoiceStatus,
    PaymentStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
     _PurchaseOrder : redirected to zc_srm_po_hdr,

      _Supplier : redirected to zc_srm_vendor
}
