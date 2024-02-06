using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ContactSaveRequestModel : BaseSaveRequestModel
    {
        public long? ContactedCasePersonID { get; set; }
        public long? CaseContactID { get; set; }
        [Required]
        public long OutbreakCaseReportUID { get; set; }
        public long? ContactTypeID { get; set; }
        public long? OutbreakID { get; set; }
        [Required]
        public long HumanMasterID { get; set; }
        public long? HumanID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? PersonalIdTypeID { get; set; }
        [StringLength(100)]
        public string PersonalID { get; set; }
        [StringLength(200)]
        public string FirstName { get; set; }
        [StringLength(200)]
        public string SecondName { get; set; }
        [StringLength(200)]
        public string LastName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public long? GenderTypeID { get; set; }
        public long? CitizenshipTypeID { get; set; }
        public long? AddressID { get; set; }
        public long? LocationID { get; set; }
        public string Street { get; set; }
        public string PostalCode { get; set; }
        [StringLength(200)]
        public string Apartment { get; set; }
        [StringLength(200)]
        public string Building { get; set; }
        [StringLength(200)]
        public string House { get; set; }
        [StringLength(200)]
        public string ForeignAddressString { get; set; }
        public long? ContactPhoneTypeID { get; set; }
        public int? ContactPhoneCountryCode { get; set; }
        [StringLength(200)]
        public string ContactPhone { get; set; }
        public DateTime? DateOfLastContact { get; set; }
        [StringLength(200)]
        public string PlaceOfLastContact { get; set; }
        [StringLength(500)]
        public string Comment { get; set; }
        public long? ContactRelationshipTypeID { get; set; }
        public long? ContactStatusID { get; set; }
        public long? ContactTracingObservationID { get; set; }
        [Required]
        public int RowStatus { get; set; }
        [Required]
        public int RowAction { get; set; }
        public string Contacts { get; set; }
    }
}
