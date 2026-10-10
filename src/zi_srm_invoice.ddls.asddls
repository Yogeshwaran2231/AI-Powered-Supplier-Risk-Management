@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'supplier invoice cds'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity zi_srm_invoice as select from zsrm_invoice
 association [0..1] to zi_srm_po_hdr as _PurchaseOrder
    on $projection.PoId = _PurchaseOrder.PoId

  association [0..1] to ZI_SRM_VENDOR as _Supplier
    on $projection.VendorId = _Supplier.VendorId
{
    key invoice_id as InvoiceId,
    po_id as PoId,
    vendor_id as VendorId,
    invoice_date as InvoiceDate,
    due_date as DueDate,
    currency_code as CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    invoice_net_amount as InvoiceNetAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    invoice_tax_amount as InvoiceTaxAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    invoice_total_amount as InvoiceTotalAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    po_total_amount as PoTotalAmount,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    amount_variance as AmountVariance,
    match_status as MatchStatus,
    invoice_status as InvoiceStatus,
    payment_status as PaymentStatus,
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
    _PurchaseOrder,
      _Supplier
}
