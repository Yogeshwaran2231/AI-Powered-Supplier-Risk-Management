@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection disruption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_srm_disruption 
provider contract transactional_query
as projection on zi_srm_Disruption
{
    key DisruptionId,
    VendorId,
    PoId,
    DisruptionType,
    DisruptionTitle,
    DisruptionDescription,
    Severity,
    ImpactArea,
    StartDate,
    EndDate,
    ImpactedDays,
    SourceType,
    SourceReference,
    AiAnalysis,
    EventStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Supplier : redirected to zc_srm_vendor,

      _PurchaseOrder : redirected to zc_srm_po_hdr
}
