using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class ContactGetListViewModel : BaseModel
    {
        public ContactGetListViewModel ShallowCopy()
        {
            return (ContactGetListViewModel)MemberwiseClone();
        }

        public long CaseContactID { get; set; }
        public long CaseID { get; set; }
        public long OutbreakTypeID { get; set; }
        public long DiseaseID { get; set; }
        
        public long? ContactedHumanCasePersonID { get; set; }

        public long? PersonalIdTypeID { get; set; }
        public string PersonalID { get; set; }
        public string FirstName { get; set; }
        public string SecondName { get; set; }
        public string LastName { get; set; }
        public string ContactName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public int? Age { get; set; }
        public long? GenderTypeID { get; set; }
        public string GenderTypeName { get; set; }
        public long? CitizenshipTypeID { get; set; }
        public string CitizenshipTypeName { get; set; }
        public DateTime? DateOfLastContact { get; set; }
        public bool ForeignAddressIndicator { get; set; }
        public string ForeignAddressString { get; set; }
        public long? AddressID { get; set; }
        public long? LocationID { get; set; }
        public long? AdministrativeLevel0ID { get; set; }
        public long? AdministrativeLevel1ID { get; set; }
        public long? AdministrativeLevel2ID { get; set; }
        public long? SettlementTypeID { get; set; }
        public long? SettlementID { get; set; }
        public string Apartment { get; set; }
        public string Building { get; set; }
        public string House { get; set; }
        public long? StreetID { get; set; }
        public string Street { get; set; }
        public long? PostalCodeID { get; set; }
        public string PostalCode { get; set; }
        public string PlaceOfLastContact { get; set; }
        public string Comment { get; set; }
        public long? ContactTypeID { get; set; }
        public string ContactTypeName { get; set; }
        public long? ContactStatusID { get; set; }
        public string ContactStatusName { get; set; }
        public long? ContactRelationshipTypeID { get; set; }
        public string ContactRelationshipTypeName { get; set; }
        public string CurrentLocation { get; set; }
        public long? ContactTracingObservationID { get; set; }
        public int ContactTracingDuration { get; set; }
        public int ContactTracingFrequency { get; set; }
        public long? VeterinaryDiseaseReportTypeID { get; set; }
        public FlexFormQuestionnaireGetRequestModel ContactTracingFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> ContactTracingFlexFormAnswers { get; set; }
        public string ContactTracingObservationParameters { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? HumanID { get; set; }
        public long HumanMasterID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? ContactPhoneTypeID { get; set; }
        public int? ContactPhoneCountryCode { get; set; }
        public string ContactPhone { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }

        public string FarmName { get; set; }
        public IEnumerable<long> SelectedFarmTypes { get; set; }
        public LocationViewModel FarmLocation { get; set; }
        public LocationViewModel ContactLocation { get; set; }
        public bool ContactTracingEditInProgressIndicator { get; set; }
    }
}
