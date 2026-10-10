@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Risk Analysis CDS'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zi_srm_risk as select from zsrm_risk
 association [0..1] to ZI_SRM_VENDOR as _Supplier
    on $projection.VendorId = _Supplier.VendorId

  association [0..1] to zi_srm_po_hdr as _PurchaseOrder
    on $projection.PoId = _PurchaseOrder.PoId

  association [0..1] to zi_srm_invoice as _Invoice
    on $projection.InvoiceId = _Invoice.InvoiceId

  association [0..1] to zi_srm_Disruption as _Disruption
    on $projection.DisruptionId = _Disruption.DisruptionId{
    key risk_id as RiskId,
    vendor_id as VendorId,
    po_id as PoId,
    invoice_id as InvoiceId,
    disruption_id as DisruptionId,
    risk_type as RiskType,
    risk_title as RiskTitle,
    supplier_risk_score as SupplierRiskScore,
    delivery_risk_score as DeliveryRiskScore,
    financial_risk_score as FinancialRiskScore,
    disruption_risk_score as DisruptionRiskScore,
    overall_risk_score as OverallRiskScore,
    risk_level as RiskLevel,
    risk_reason as RiskReason,
    ai_insight as AiInsight,
    recommended_action as RecommendedAction,
    alert_status as AlertStatus,
    risk_status as RiskStatus,
    review_status as ReviewStatus,
    review_comment as ReviewComment,
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
      _PurchaseOrder,
      _Invoice,
      _Disruption
}
