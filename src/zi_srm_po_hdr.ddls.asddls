@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'hdr purchase order cds'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zi_srm_po_hdr 
as select from zsrm_po_hdr
association [0..1] to ZI_SRM_VENDOR as _Supplier
    on $projection.VendorId = _Supplier.VendorId

  composition [0..*] of zi_srm_po_itm as _Items
{
    key po_id as PoId,
    vendor_id as VendorId,
    po_date as PoDate,
    expected_delivery_date as ExpectedDeliveryDate,
    actual_delivery_date as ActualDeliveryDate,
    company_code as CompanyCode,
    currency_code          as CurrencyCode,
    payment_terms          as PaymentTerms,
 @Semantics.amount.currencyCode: 'CurrencyCode'
    total_net_amount       as TotalNetAmount,
 @Semantics.amount.currencyCode: 'CurrencyCode'
      total_tax_amount       as TotalTaxAmount,
@Semantics.amount.currencyCode: 'CurrencyCode'
      total_amount           as TotalAmount,
    delivery_delay_days as DeliveryDelayDays,
    po_status as PoStatus,
    delivery_status as DeliveryStatus,
    priority as Priority,
    @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
 @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
 @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
@Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
@Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
    _Supplier,
     _Items
}
