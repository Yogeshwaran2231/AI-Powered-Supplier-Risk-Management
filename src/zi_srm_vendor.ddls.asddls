@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'supplier Master cds'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_SRM_VENDOR 
as select from zsrm_vendor
{
    key vendor_id as VendorId,
    vendor_name as VendorName,
    vendor_category as VendorCategory,
    contact_person as ContactPerson,
    email as Email,
    phone as Phone,
    address as Address,
    city as City,
    state as State,
    postal_code as PostalCode,
    country as Country,
    tax_number as TaxNumber,
    bank_account as BankAccount,
    payment_terms as PaymentTerms,
    lead_time_days as LeadTimeDays,
    supplier_criticality as SupplierCriticality,
    vendor_status as VendorStatus,
     @Semantics.user.createdBy: true
    local_created_by      as LocalCreatedBy,
@Semantics.systemDateTime.createdAt: true
    local_created_at      as LocalCreatedAt,
 @Semantics.user.localInstanceLastChangedBy: true
    local_last_changed_by as LocalLastChangedBy,
 @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
@Semantics.systemDateTime.lastChangedAt: true
    last_changed_at       as LastChangedAt
    
}
