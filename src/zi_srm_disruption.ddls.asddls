@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Disruption CDS'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zi_srm_Disruption 
as select from zsrm_disruption
association [0..1] to ZI_SRM_VENDOR as _Supplier
    on $projection.VendorId = _Supplier.VendorId

  association [0..1] to zi_srm_po_hdr as _PurchaseOrder
    on $projection.PoId = _PurchaseOrder.PoId
{
    key disruption_id as DisruptionId,
    vendor_id as VendorId,
    po_id as PoId,
    disruption_type as DisruptionType,
    disruption_title as DisruptionTitle,
    disruption_description as DisruptionDescription,
    severity as Severity,
    impact_area as ImpactArea,
    start_date as StartDate,
    end_date as EndDate,
    impacted_days as ImpactedDays,
    source_type as SourceType,
    source_reference as SourceReference,
    ai_analysis as AiAnalysis,
    event_status as EventStatus,
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
      _PurchaseOrder
}
