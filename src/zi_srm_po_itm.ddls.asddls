@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'itm purchase order cds'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zi_srm_po_itm 
as select from zsrm_po_item
association to parent zi_srm_po_hdr as _PurchaseOrder
    on $projection.PoId = _PurchaseOrder.PoId
{
    key po_id as PoId,
    key item_no as ItemNo,
    material_id as MaterialId,
    material_desc as MaterialDesc,
    unit as Unit,
     @Semantics.quantity.unitOfMeasure: 'Unit'
    quantity as Quantity,
    currency_code as CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    unit_price as UnitPrice,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    net_amount as NetAmount,
    tax_rate as TaxRate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    tax_amount as TaxAmount,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    item_total_amount as ItemTotalAmount,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    delivered_qty as DeliveredQty,
    item_status as ItemStatus,
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
    
    _PurchaseOrder
}
