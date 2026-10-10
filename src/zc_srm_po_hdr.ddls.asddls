@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection heder po'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_srm_po_hdr
provider contract transactional_query
 as projection on zi_srm_po_hdr
{
    key PoId,
    VendorId,
    PoDate,
    ExpectedDeliveryDate,
    ActualDeliveryDate,
    CompanyCode,
    CurrencyCode,
    PaymentTerms,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalNetAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalTaxAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalAmount,
    DeliveryDelayDays,
    PoStatus,
    DeliveryStatus,
    Priority,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
     _Supplier : redirected to zc_srm_vendor,

      _Items : redirected to composition child zc_srm_po_itm
}
