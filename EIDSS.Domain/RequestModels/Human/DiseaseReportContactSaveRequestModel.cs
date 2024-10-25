using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class DiseaseReportContactSaveRequestModel
    {

        public long? ContactedCasePersonId { get; set; }

        public long? CaseContactId { get; set; } //Outbreak Only

        public long? CaseOrReportId { get; set; } //Human disease report or outbreak case identifier

        public long? ContactTypeId { get; set; } //Outbreak Only

        public long? ContactRelationshipTypeId { get; set; }

        public long? HumanMasterId { get; set; }

        public long? HumanId { get; set; }

        public long? PersonalIdTypeId { get; set; }

        public string? PersonalId { get; set; }

        public string? FirstName { get; set; }

        public string? SecondName { get; set; }

        public string? LastName { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public int? Age {get;set;}

        public long? AgeTypeId { get; set; }

        public long? GenderTypeId { get; set; }

        public long? CitizenshipTypeId { get; set; }

        public long? AddressId { get; set; }

        public long? LocationId { get; set; } // Lowest administrative level

        public string? Street { get; set; }

        public string? PostalCode { get; set; }

        public string? Apartment { get; set; }

        public string? Building { get; set; }

        public string? House { get; set; }

        public string? ForeignAddressString { get; set; }

        public int? ContactPhoneCountryCode { get; set; }

        public string? ContactPhone { get; set; }

        public long? ContactPhoneTypeId { get; set; }

        public DateTime? DateOfLastContact { get; set; }

        public string? PlaceOfLastContact { get; set; }

        public string? Comments { get; set; }

        public long? ContactStatusId { get; set; } // Outbreak only

        public long? ContactTracingObservationId { get; set; } // Outbreak only

        public int? RowStatus { get; set; }

        public int? RowAction { get; set; }


        public string AuditUserName { get; set; }

    }
}
