@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection vendor'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_srm_vendor 
provider contract transactional_query
as projection on ZI_SRM_VENDOR
{
    key VendorId,
    VendorName,
    VendorCategory,
    ContactPerson,
    Email,
    Phone,
    Address,
    City,
    State,
    PostalCode,
    Country,
    TaxNumber,
    BankAccount,
    PaymentTerms,
    LeadTimeDays,
    SupplierCriticality,
    VendorStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
}
