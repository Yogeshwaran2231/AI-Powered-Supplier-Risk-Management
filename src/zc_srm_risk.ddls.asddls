@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection risk'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_srm_risk 
provider contract transactional_query
as projection on zi_srm_risk
{
    key RiskId,
    VendorId,
    PoId,
    InvoiceId,
    DisruptionId,
    RiskType,
    RiskTitle,
    SupplierRiskScore,
    DeliveryRiskScore,
    FinancialRiskScore,
    DisruptionRiskScore,
    OverallRiskScore,
    RiskLevel,
    RiskReason,
    AiInsight,
    RecommendedAction,
    AlertStatus,
    RiskStatus,
    ReviewStatus,
    ReviewComment,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Supplier : redirected to zc_srm_vendor,
    _PurchaseOrder : redirected to zc_srm_po_hdr,
    _Invoice : redirected to zc_srm_invoice,
    _Disruption : redirected to zc_srm_disruption
}
