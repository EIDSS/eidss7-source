using System;
using System.Collections.Generic;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.Helpers;

namespace EIDSS.Web.Services
{
    public class PersonStateContainer
    {
        public string EIDSSPersonID { get; set; }
        public string PersonID { get; set; }
        public string PersonalID { get; set; }
        public long? HumanMasterID { get; set; }
        public string PersonLastName { get; set; }
        public string PersonFirstName { get; set; }
        public string PersonMiddleName { get; set; }
        public long? PersonalIDType { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public DateTime? DateOfDeath { get; set; }
        public bool IsDateOfDeathVisible { get; set; }
        public int? ReportedAge { get; set; }
        public long? ReportedAgeUOMID { get; set; }
        public long? GenderType { get; set; }
        public long? CitizenshipType { get; set; }
        public string PassportNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string PhoneNumber2 { get; set; }
        public string EmployerPhoneNumber { get; set; }
        public long? PhoneNumberType { get; set; }
        public long? PhoneNumber2Type { get; set; }
        public long? OccupationType { get; set; }
        public string EmployerName { get; set; }
        public DateTime? DateOfLastPresenceAtWork { get; set; }
        public bool WorkAddressSameAsCurrentAddress { get; set; }
        public bool PermanentAddressSameAsCurrentAddress { get; set; }
        public bool IsForeignWorkAddress { get; set; }
        public bool IsForeignAlternateAddress { get; set; }
        public bool IsDiseaseReportHidden { get; set; }
        public bool IsOutbreakReportHidden { get; set; }
        public long? ForeignAlternateCountryID { get; set; }
        public long? ForeignWorkCountryID { get; set; }
        public long? ForeignSchoolCountryID { get; set; }
        public long? HumanGeoLocationID { get; set; }
        public long? HumanPermGeoLocationID { get; set; }
        public long? HumanAltGeoLocationID { get; set; }
        public long? SchoolGeoLocationID { get; set; }
        public long? EmployerGeoLocationID { get; set; }
        public long? IsStudentTypeID { get; set; }
        public string WorkPhone { get; set; }
        public string HomePhone { get; set; }
        public string ForeignWorkAddress { get; set; }
        public string ForeignSchoolAddress { get; set; }
        public string ForeignAlternateAddress { get; set; }
        public string SchoolName { get; set; }
        public DateTime? DateOfLastPresenceAtSchool { get; set; }
        public string SchoolPhoneNumber { get; set; }
        public bool IsForeignSchoolAddress { get; set; }
        public DateTime? DateEntered { get; set; }
        public DateTime? DateModified { get; set; }
        public string ContactPhone { get; set; }
        public long? ContactPhoneTypeID { get; set; }
        public string ContactPhone2 { get; set; }
        public long? ContactPhone2TypeID { get; set; }
        public bool IsAnotherPhoneNumberHidden { get; set; } = true;  
        public int IsAnotherPhoneNumberHiddenValue { get; set; }
        public int IsEmploymentHiddenValue { get; set; }
        public long? IsEmployedTypeID { get; set; }
        public long? IsAnotherPhoneTypeID { get; set; }
        public long? IsAnotherAddressTypeID { get; set; }
        public bool IsSchoolHidden { get; set; } = true;
        public int IsSchoolHiddenValue { get; set; }
        public bool IsReadOnly { get; set; }
        public bool IsReview { get; set; }
        public bool IsHeaderVisible { get; set; }
        public bool IsFindPINDisabled { get; set; }
        public bool IsFindPINVisible { get; set; }
        public LocationViewModel PersonCurrentAddressLocationModel { get; set; }
        public LocationViewModel PersonPermanentAddressLocationModel { get; set; }
        public LocationViewModel PersonAlternateAddressLocationModel { get; set; }
        public LocationViewModel PersonEmploymentAddressLocationModel { get; set; }
        public LocationViewModel PersonSchoolAddressLocationModel { get; set; }
        public UserPermissions PersonAddSessionPermissions { get; set; }
        public UserPermissions HumanDiseaseReportPermissions { get; set; }
        public List<CaseGetListViewModel> OutbreakCases { get; set; }
        public List<HumanDiseaseReportViewModel> DiseaseReports { get; set; }
        public List<PersonViewModel> PinSearchResults { get; set; }
        public bool IsHumanAgeTypeRequired { get; set; }
        public bool IsHumanAgeFieldsCouldBeSelectedByUserWhenDateOfBirthIsNotSet { get; set; }
        public bool? IsDateOfBirthRequired { get; set; }
        public bool? IsDateOfDeathRequired { get; set; }
        public bool IsDOBErrorMessageVisible { get; set; }
        public bool IsPersonalIDDuplicated { get; set; }
        public List<BaseReferenceViewModel> SessionStatuses { get; set; }
        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public List<BaseReferenceAdvancedListResponseModel> Species { get; set; }
        public List<BaseReferenceViewModel> SpeciesTypes { get; set; }
        public List<DiseaseSampleTypeByDiseaseResponseModel> SampleTypes { get; set; }
        public bool PersonHeaderSectionValidIndicator { get; set; }
        public bool PersonInformationSectionValidIndicator { get; set; }
        public bool PersonAddressSectionValidIndicator { get; set; }
        public bool PersonEmploymentSchoolSectionValidIndicator { get; set; }
        public bool PersonReviewSectionValidIndicator { get; set; }
        public bool IsPersonValidationActive { get; set; }

        public PersonStateContainer()
        {
            SetDefaultValuesForFields();
        }

        public void ResetModelValues()
        {
            SetDefaultValuesForFields();
        }

        private void SetDefaultValuesForFields()
        {
            EIDSSPersonID = null;
            PersonID = null;
            PersonalID = null;
            HumanMasterID = null;
            PersonLastName = null;
            PersonFirstName = null;
            PersonMiddleName = null;
            PersonalIDType = null;
            DateOfBirth = null;
            DateOfDeath = null;
            IsDateOfDeathVisible = true;
            ReportedAge = null;
            ReportedAgeUOMID = null;
            GenderType = null;
            CitizenshipType = null;
            PassportNumber = null;
            PhoneNumber = null;
            PhoneNumber2 = null;
            EmployerPhoneNumber = null;
            PhoneNumberType = null;
            PhoneNumber2Type = null;
            OccupationType = null;
            EmployerName = null;
            DateOfLastPresenceAtWork = null;
            WorkAddressSameAsCurrentAddress = false;
            PermanentAddressSameAsCurrentAddress = false;
            IsForeignWorkAddress = false;
            IsForeignAlternateAddress = false;
            IsDiseaseReportHidden = false;
            IsOutbreakReportHidden = false;
            ForeignAlternateCountryID = null;
            ForeignWorkCountryID = null;
            ForeignSchoolCountryID = null;
            HumanGeoLocationID = null;
            HumanPermGeoLocationID = null;
            HumanAltGeoLocationID = null;
            SchoolGeoLocationID = null;
            EmployerGeoLocationID = null;
            IsStudentTypeID = null;
            WorkPhone = null;
            HomePhone = null;
            ForeignWorkAddress = null;
            ForeignSchoolAddress = null;
            ForeignAlternateAddress = null;
            SchoolName = null;
            DateOfLastPresenceAtSchool = null;
            SchoolPhoneNumber = null;
            IsForeignSchoolAddress = false;
            DateEntered = null;
            DateModified = null;
            ContactPhone = null;
            ContactPhoneTypeID = null;
            ContactPhone2 = null;
            ContactPhone2TypeID = null;
            IsAnotherPhoneNumberHidden = true;
            IsAnotherPhoneNumberHiddenValue = 0;
            IsEmploymentHiddenValue = 0;
            IsEmployedTypeID = null;
            IsAnotherPhoneTypeID = null;
            IsAnotherAddressTypeID = null;
            IsSchoolHidden = true;
            IsSchoolHiddenValue = 0;
            IsReadOnly = false;
            IsHumanAgeFieldsCouldBeSelectedByUserWhenDateOfBirthIsNotSet = false;
            IsReview = false;
            IsHeaderVisible = true;
            IsFindPINDisabled = false;
            IsFindPINVisible = true;
            PersonCurrentAddressLocationModel = new();
            PersonPermanentAddressLocationModel = new();
            PersonAlternateAddressLocationModel = new();
            PersonEmploymentAddressLocationModel = new();
            PersonSchoolAddressLocationModel = new();
            PersonAddSessionPermissions = new();
            HumanDiseaseReportPermissions = new();
            OutbreakCases = null;
            DiseaseReports = null;
            PinSearchResults = null;
            IsHumanAgeTypeRequired = false;
            IsDateOfBirthRequired = null;
            IsDateOfDeathRequired = null;
            IsDOBErrorMessageVisible = false;
            IsPersonalIDDuplicated = false;
            IsPersonValidationActive = true;
        }

        public void SetupFrom(DiseaseReportPersonalInformationViewModel? personDetail, long countryId, bool requireBaseAddressLevelOneAndTwo = true, long? defaultRegionId = null, long? defaultRayonId = null)
        {
            if (personDetail == null)
            {
                ResetModelValues();
            }

            PersonCurrentAddressLocationModel = CreateAddressModelBasedOnPermissions(countryId, defaultRegionId: defaultRegionId, defaultRayonId: defaultRayonId);
            PersonPermanentAddressLocationModel = CreateAddressModelBasedOnPermissions(countryId, false, requireBaseAddressLevelOneAndTwo, defaultRegionId, defaultRayonId);
            PersonAlternateAddressLocationModel = CreateAddressModelBasedOnPermissions(countryId, false, requireBaseAddressLevelOneAndTwo, defaultRegionId, defaultRayonId);
            PersonEmploymentAddressLocationModel = CreateAddressModelBasedOnPermissions(countryId, false, requireBaseAddressLevelOneAndTwo, defaultRegionId, defaultRayonId);
            PersonSchoolAddressLocationModel = CreateAddressModelBasedOnPermissions(countryId, false, requireBaseAddressLevelOneAndTwo, defaultRegionId, defaultRayonId);

            if (personDetail == null)
            {
                return;
            }

            EIDSSPersonID = personDetail.EIDSSPersonID;

            //Person Header
            DateEntered = personDetail.EnteredDate;
            DateModified = personDetail.ModificationDate;

            //Person Information
            PersonFirstName = personDetail.FirstOrGivenName;
            PersonMiddleName = personDetail.SecondName;
            PersonLastName = personDetail.LastOrSurname;
            PersonalIDType = personDetail.PersonalIDType;
            PersonalID = personDetail.PersonalID;
            DateOfBirth = personDetail.DateOfBirth;
            DateOfDeath = personDetail.DateOfDeath;
            GenderType = personDetail.GenderTypeID;
            CitizenshipType = personDetail.CitizenshipTypeID;
            PassportNumber = personDetail.PassportNumber;
            HumanGeoLocationID = personDetail.HumanGeoLocationID;
            HumanPermGeoLocationID = personDetail.HumanPermGeoLocationID;
            HumanAltGeoLocationID = personDetail.HumanAltGeoLocationID;
            SchoolGeoLocationID = personDetail.SchoolGeoLocationID;
            EmployerGeoLocationID = personDetail.EmployerGeoLocationID;
            IsEmployedTypeID = personDetail.IsEmployedTypeID;
            IsStudentTypeID = personDetail.IsStudentTypeID;
            WorkPhone = personDetail.WorkPhone;
            HomePhone = personDetail.HomePhone;
            ContactPhone = personDetail.ContactPhone;
            ContactPhoneTypeID = personDetail.ContactPhoneTypeID;
            ContactPhone2 = personDetail.ContactPhone2;
            ContactPhone2TypeID = personDetail.ContactPhone2TypeID;
            UpdateAge(DateOfBirth, DateOfDeath);
            IsAnotherPhoneTypeID = personDetail.IsAnotherPhoneTypeID;
            IsAnotherAddressTypeID = personDetail.IsAnotherAddressTypeID;

            // Toggle Display of Secondary Phone Number section
            IsAnotherPhoneNumberHidden = personDetail.IsAnotherPhoneTypeID != Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes);


            //Current Address
            PersonCurrentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
            PersonCurrentAddressLocationModel.AdminLevel1Value = personDetail.HumanidfsRegion;
            PersonCurrentAddressLocationModel.AdminLevel2Value = personDetail.HumanidfsRayon;
            PersonCurrentAddressLocationModel.SettlementType = personDetail.HumanidfsSettlementType;
            PersonCurrentAddressLocationModel.AdminLevel3Value = personDetail.HumanidfsSettlement;

            PersonCurrentAddressLocationModel.AdminLevel1Text = personDetail.HumanRegion;
            PersonCurrentAddressLocationModel.AdminLevel2Text = personDetail.HumanRayon;
            PersonCurrentAddressLocationModel.AdminLevel3Text = personDetail.HumanSettlement;

            PersonCurrentAddressLocationModel.PostalCodeText = personDetail.HumanstrPostalCode;
            PersonCurrentAddressLocationModel.Latitude = personDetail.HumanstrLatitude;
            PersonCurrentAddressLocationModel.Longitude = personDetail.HumanstrLongitude;
            PersonCurrentAddressLocationModel.StreetText = personDetail.HumanstrStreetName;
            PersonCurrentAddressLocationModel.House = personDetail.HumanstrHouse;
            PersonCurrentAddressLocationModel.Building = personDetail.HumanstrBuilding;
            PersonCurrentAddressLocationModel.Apartment = personDetail.HumanstrApartment;

            PersonCurrentAddressLocationModel.EnableAdminLevel2 = !IsReadOnly && personDetail.HumanidfsRegion != null;
            PersonCurrentAddressLocationModel.EnableAdminLevel3 = !IsReadOnly && personDetail.HumanidfsRayon != null;
            PersonCurrentAddressLocationModel.EnableSettlementType = !IsReadOnly && personDetail.HumanidfsRayon != null;
            PersonCurrentAddressLocationModel.EnableAdminLevel4 = !IsReadOnly && personDetail.HumanidfsSettlement != null;
            PersonCurrentAddressLocationModel.EnablePostalCode = !IsReadOnly && personDetail.HumanstrPostalCode != null || personDetail.HumanidfsSettlement != null;
            PersonCurrentAddressLocationModel.EnableStreet = !IsReadOnly && personDetail.HumanstrStreetName != null || personDetail.HumanidfsSettlement != null;
            PersonCurrentAddressLocationModel.EnableHouse = !IsReadOnly && personDetail.HumanstrHouse != null || personDetail.HumanidfsSettlement != null;
            PersonCurrentAddressLocationModel.EnableBuilding = !IsReadOnly && personDetail.HumanstrBuilding != null || personDetail.HumanidfsSettlement != null;
            PersonCurrentAddressLocationModel.EnableApartment = !IsReadOnly && personDetail.HumanstrApartment!=null || personDetail.HumanidfsSettlement != null;

            //Permanent Address
            PersonPermanentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
            PersonPermanentAddressLocationModel.AdminLevel1Value = personDetail.HumanPermidfsRegion;
            PersonPermanentAddressLocationModel.AdminLevel2Value = personDetail.HumanPermidfsRayon;
            PersonPermanentAddressLocationModel.SettlementType = personDetail.HumanPermidfsSettlementType;
            PersonPermanentAddressLocationModel.AdminLevel3Value = personDetail.HumanPermidfsSettlement;

            PersonPermanentAddressLocationModel.AdminLevel1Text = personDetail.HumanPermRegion;
            PersonPermanentAddressLocationModel.AdminLevel2Text = personDetail.HumanPermRayon;
            PersonPermanentAddressLocationModel.AdminLevel3Text = personDetail.HumanPermSettlement;

            PersonPermanentAddressLocationModel.PostalCodeText = personDetail.HumanPermstrPostalCode;
            PersonPermanentAddressLocationModel.StreetText = personDetail.HumanPermstrStreetName;
            PersonPermanentAddressLocationModel.House = personDetail.HumanPermstrHouse;
            PersonPermanentAddressLocationModel.Building = personDetail.HumanPermstrBuilding;
            PersonPermanentAddressLocationModel.Apartment = personDetail.HumanPermstrApartment;

            PersonPermanentAddressLocationModel.EnableAdminLevel2 = !IsReadOnly && personDetail.HumanPermidfsRegion != null;
            PersonPermanentAddressLocationModel.EnableAdminLevel3 = !IsReadOnly && personDetail.HumanPermidfsRayon != null;
            PersonPermanentAddressLocationModel.EnableSettlementType = !IsReadOnly && personDetail.HumanPermidfsRayon != null;
            PersonPermanentAddressLocationModel.EnableAdminLevel4 = !IsReadOnly && personDetail.HumanPermidfsSettlement != null;
            PersonPermanentAddressLocationModel.EnablePostalCode = !IsReadOnly && personDetail.HumanPermstrPostalCode != null || personDetail.HumanPermidfsSettlement != null;
            PersonPermanentAddressLocationModel.EnableStreet = !IsReadOnly && personDetail.HumanPermstrStreetName != null || personDetail.HumanPermidfsSettlement != null;
            PersonPermanentAddressLocationModel.EnableHouse = !IsReadOnly && personDetail.HumanPermstrHouse != null || personDetail.HumanPermidfsSettlement != null;
            PersonPermanentAddressLocationModel.EnableBuilding = !IsReadOnly && personDetail.HumanPermstrBuilding != null || personDetail.HumanPermidfsSettlement != null;
            PersonPermanentAddressLocationModel.EnableApartment = !IsReadOnly && personDetail.HumanPermstrApartment != null || personDetail.HumanPermidfsSettlement != null;

            if (PersonPermanentAddressLocationModel.AdminLevel0Value == PersonCurrentAddressLocationModel.AdminLevel0Value
            && PersonPermanentAddressLocationModel.AdminLevel1Value == PersonCurrentAddressLocationModel.AdminLevel1Value
            && PersonPermanentAddressLocationModel.AdminLevel2Value == PersonCurrentAddressLocationModel.AdminLevel2Value
            && PersonPermanentAddressLocationModel.SettlementType == PersonCurrentAddressLocationModel.SettlementType
            && PersonPermanentAddressLocationModel.AdminLevel3Value == PersonCurrentAddressLocationModel.AdminLevel3Value
            && PersonPermanentAddressLocationModel.AdminLevel1Text == PersonCurrentAddressLocationModel.AdminLevel1Text
            && PersonPermanentAddressLocationModel.AdminLevel2Text == PersonCurrentAddressLocationModel.AdminLevel2Text
            && PersonPermanentAddressLocationModel.AdminLevel3Text == PersonCurrentAddressLocationModel.AdminLevel3Text
            && PersonPermanentAddressLocationModel.PostalCodeText == PersonCurrentAddressLocationModel.PostalCodeText
            && PersonPermanentAddressLocationModel.StreetText == PersonCurrentAddressLocationModel.StreetText
            && PersonPermanentAddressLocationModel.House == PersonCurrentAddressLocationModel.House
            && PersonPermanentAddressLocationModel.Building == PersonCurrentAddressLocationModel.Building
            && PersonPermanentAddressLocationModel.Apartment == PersonCurrentAddressLocationModel.Apartment
            )
            {
                PermanentAddressSameAsCurrentAddress = true;
            }

            //Alternate Address
            PersonAlternateAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
            PersonAlternateAddressLocationModel.AdminLevel1Value = personDetail.HumanAltidfsRegion;
            PersonAlternateAddressLocationModel.AdminLevel2Value = personDetail.HumanAltidfsRayon;
            PersonAlternateAddressLocationModel.SettlementType = personDetail.HumanAltidfsSettlementType;
            PersonAlternateAddressLocationModel.AdminLevel3Value = personDetail.HumanAltidfsSettlement;

            PersonAlternateAddressLocationModel.AdminLevel1Text = personDetail.HumanAltRegion;
            PersonAlternateAddressLocationModel.AdminLevel2Text = personDetail.HumanAltRayon;
            PersonAlternateAddressLocationModel.AdminLevel3Text = personDetail.HumanAltSettlement;

            PersonAlternateAddressLocationModel.PostalCodeText = personDetail.HumanAltstrPostalCode;
            PersonAlternateAddressLocationModel.StreetText = personDetail.HumanAltstrStreetName;
            PersonAlternateAddressLocationModel.House = personDetail.HumanAltstrHouse;
            PersonAlternateAddressLocationModel.Building = personDetail.HumanAltstrBuilding;
            PersonAlternateAddressLocationModel.Apartment = personDetail.HumanAltstrApartment;
            IsForeignAlternateAddress = personDetail.HumanAltForeignAddressIndicator ?? false;
            ForeignAlternateAddress = personDetail.HumanAltForeignAddressString;
            ForeignAlternateCountryID = personDetail.HumanAltidfsCountry;
            PersonAlternateAddressLocationModel.EnableAdminLevel2 = !IsReadOnly && personDetail.HumanAltidfsRegion != null;
            PersonAlternateAddressLocationModel.EnableAdminLevel3 = !IsReadOnly && personDetail.HumanAltidfsRayon != null;
            PersonAlternateAddressLocationModel.EnableSettlementType = !IsReadOnly && personDetail.HumanAltidfsRayon != null;
            PersonAlternateAddressLocationModel.EnableAdminLevel4 = !IsReadOnly && personDetail.HumanAltidfsSettlement != null;
            PersonAlternateAddressLocationModel.EnablePostalCode = !IsReadOnly && personDetail.HumanAltstrPostalCode != null || personDetail.HumanAltidfsSettlement != null;
            PersonAlternateAddressLocationModel.EnableStreet = !IsReadOnly && personDetail.HumanAltstrStreetName != null || personDetail.HumanAltidfsSettlement != null;
            PersonAlternateAddressLocationModel.EnableHouse = !IsReadOnly && personDetail.HumanAltstrHouse != null || personDetail.HumanAltidfsSettlement != null;
            PersonAlternateAddressLocationModel.EnableBuilding = !IsReadOnly && personDetail.HumanAltstrBuilding != null || personDetail.HumanAltidfsSettlement != null;
            PersonAlternateAddressLocationModel.EnableApartment = !IsReadOnly && personDetail.HumanAltstrApartment != null || personDetail.HumanAltidfsSettlement != null;

            //Work Address
            EmployerName = personDetail.EmployerName;
            OccupationType = personDetail.OccupationTypeID;
            DateOfLastPresenceAtWork = personDetail.EmployedDateLastPresent;
            EmployerPhoneNumber = personDetail.EmployerPhone;
            IsForeignWorkAddress = personDetail.EmployerForeignAddressIndicator ?? false;
            ForeignWorkAddress = personDetail.EmployerForeignAddressString;
            ForeignWorkCountryID = personDetail.EmployeridfsCountry;

            PersonEmploymentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
            PersonEmploymentAddressLocationModel.AdminLevel1Value = personDetail.EmployeridfsRegion;
            PersonEmploymentAddressLocationModel.AdminLevel2Value = personDetail.EmployeridfsRayon;
            PersonEmploymentAddressLocationModel.SettlementType = personDetail.EmployeridfsSettlementType;
            PersonEmploymentAddressLocationModel.AdminLevel3Value = personDetail.EmployeridfsSettlement;

            PersonEmploymentAddressLocationModel.AdminLevel1Text = personDetail.EmployerRegion;
            PersonEmploymentAddressLocationModel.AdminLevel2Text = personDetail.EmployerRayon;
            PersonEmploymentAddressLocationModel.AdminLevel3Text = personDetail.EmployerSettlement;

            PersonEmploymentAddressLocationModel.PostalCodeText = personDetail.EmployerstrPostalCode;
            PersonEmploymentAddressLocationModel.StreetText = personDetail.EmployerstrStreetName;
            PersonEmploymentAddressLocationModel.House = personDetail.EmployerstrHouse;
            PersonEmploymentAddressLocationModel.Building = personDetail.EmployerstrBuilding;
            PersonEmploymentAddressLocationModel.Apartment = personDetail.EmployerstrApartment;
            PersonEmploymentAddressLocationModel.EnableAdminLevel2 = !IsReadOnly && personDetail.EmployeridfsRegion != null;
            PersonEmploymentAddressLocationModel.EnableAdminLevel3 = !IsReadOnly && personDetail.EmployeridfsRayon != null;
            PersonEmploymentAddressLocationModel.EnableSettlementType = !IsReadOnly && personDetail.EmployeridfsRayon != null;
            PersonEmploymentAddressLocationModel.EnableAdminLevel4 = !IsReadOnly && personDetail.EmployeridfsSettlement != null;
            PersonEmploymentAddressLocationModel.EnablePostalCode = !IsReadOnly && personDetail.EmployerstrPostalCode != null || personDetail.EmployeridfsSettlement != null;
            PersonEmploymentAddressLocationModel.EnableStreet = !IsReadOnly && personDetail.EmployerstrStreetName != null || personDetail.EmployeridfsSettlement != null;
            PersonEmploymentAddressLocationModel.EnableHouse = !IsReadOnly && personDetail.EmployerstrHouse != null || personDetail.EmployeridfsSettlement != null;
            PersonEmploymentAddressLocationModel.EnableBuilding = !IsReadOnly && personDetail.EmployerstrBuilding != null || personDetail.EmployeridfsSettlement != null;
            PersonEmploymentAddressLocationModel.EnableApartment = !IsReadOnly && personDetail.EmployerstrApartment != null || personDetail.EmployeridfsSettlement != null;

            if (PersonEmploymentAddressLocationModel.AdminLevel0Value == PersonCurrentAddressLocationModel.AdminLevel0Value
            && PersonEmploymentAddressLocationModel.AdminLevel1Value == PersonCurrentAddressLocationModel.AdminLevel1Value
            && PersonEmploymentAddressLocationModel.AdminLevel2Value == PersonCurrentAddressLocationModel.AdminLevel2Value
            && PersonEmploymentAddressLocationModel.SettlementType == PersonCurrentAddressLocationModel.SettlementType
            && PersonEmploymentAddressLocationModel.AdminLevel3Value == PersonCurrentAddressLocationModel.AdminLevel3Value
            && PersonEmploymentAddressLocationModel.AdminLevel1Text == PersonCurrentAddressLocationModel.AdminLevel1Text
            && PersonEmploymentAddressLocationModel.AdminLevel2Text == PersonCurrentAddressLocationModel.AdminLevel2Text
            && PersonEmploymentAddressLocationModel.AdminLevel3Text == PersonCurrentAddressLocationModel.AdminLevel3Text
            && PersonEmploymentAddressLocationModel.PostalCodeText == PersonCurrentAddressLocationModel.PostalCodeText
            && PersonEmploymentAddressLocationModel.StreetText == PersonCurrentAddressLocationModel.StreetText
            && PersonEmploymentAddressLocationModel.House == PersonCurrentAddressLocationModel.House
            && PersonEmploymentAddressLocationModel.Building == PersonCurrentAddressLocationModel.Building
            && PersonEmploymentAddressLocationModel.Apartment == PersonCurrentAddressLocationModel.Apartment
            )
            {
                WorkAddressSameAsCurrentAddress = true;
            }

            //School Address
            SchoolName = personDetail.SchoolName;
            DateOfLastPresenceAtSchool = personDetail.SchoolDateLastAttended;
            SchoolPhoneNumber = personDetail.SchoolPhone;
            IsForeignSchoolAddress = personDetail.SchoolForeignAddressIndicator ?? false;
            ForeignSchoolCountryID = personDetail.SchoolidfsCountry;
            ForeignSchoolAddress = personDetail.SchoolForeignAddressString;

            PersonSchoolAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
            PersonSchoolAddressLocationModel.AdminLevel1Value = personDetail.SchoolidfsRegion;
            PersonSchoolAddressLocationModel.AdminLevel2Value = personDetail.SchoolidfsRayon;
            PersonSchoolAddressLocationModel.SettlementType = personDetail.SchoolAltidfsSettlementType;
            PersonSchoolAddressLocationModel.AdminLevel3Value = personDetail.SchoolidfsSettlement;

            PersonSchoolAddressLocationModel.AdminLevel1Text = personDetail.SchoolRegion;
            PersonSchoolAddressLocationModel.AdminLevel2Text = personDetail.SchoolRayon;
            PersonSchoolAddressLocationModel.AdminLevel3Text = personDetail.SchoolSettlement;

            PersonSchoolAddressLocationModel.PostalCodeText = personDetail.SchoolstrPostalCode;
            PersonSchoolAddressLocationModel.StreetText = personDetail.SchoolstrStreetName;
            PersonSchoolAddressLocationModel.House = personDetail.SchoolstrHouse;
            PersonSchoolAddressLocationModel.Building = personDetail.SchoolstrBuilding;
            PersonSchoolAddressLocationModel.Apartment = personDetail.SchoolstrApartment;
            PersonSchoolAddressLocationModel.EnableAdminLevel2 = !IsReadOnly && personDetail.SchoolidfsRegion != null;
            PersonSchoolAddressLocationModel.EnableAdminLevel3 = !IsReadOnly && personDetail.SchoolidfsRayon != null;
            PersonSchoolAddressLocationModel.EnableSettlementType = !IsReadOnly && personDetail.SchoolidfsRayon != null;
            PersonSchoolAddressLocationModel.EnableAdminLevel4 = !IsReadOnly && personDetail.SchoolidfsSettlement != null;
            PersonSchoolAddressLocationModel.EnablePostalCode = !IsReadOnly && personDetail.SchoolstrPostalCode != null || personDetail.SchoolidfsSettlement != null;
            PersonSchoolAddressLocationModel.EnableStreet = !IsReadOnly && personDetail.SchoolstrStreetName != null || personDetail.SchoolidfsSettlement != null;
            PersonSchoolAddressLocationModel.EnableHouse = !IsReadOnly && personDetail.SchoolstrHouse != null || personDetail.SchoolidfsSettlement != null;
            PersonSchoolAddressLocationModel.EnableBuilding = !IsReadOnly && personDetail.SchoolstrBuilding != null || personDetail.SchoolidfsSettlement != null;
            PersonSchoolAddressLocationModel.EnableApartment = !IsReadOnly && personDetail.SchoolstrApartment != null || personDetail.SchoolidfsSettlement != null;

            // Toggle Display of School Address                       
            IsSchoolHidden = personDetail.IsStudentTypeID != Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes);
        }
        
        private LocationViewModel CreateAddressModelBasedOnPermissions(long countryId, bool showMap = true, bool requireBaseAddressLevelOneAndTwo = true, long? defaultRegionId = null, long? defaultRayonId = null)
        {
            return new LocationViewModel
            {
                OperationType = IsReadOnly ? LocationViewOperationType.ReadOnly : LocationViewOperationType.Edit,
                AlwaysDisabled = IsReadOnly,
                IsHorizontalLayout = true,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = true,
                ShowSettlementType = true,
                ShowStreet = true,
                ShowBuilding = true,
                ShowApartment = true,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = showMap,
                ShowLongitude = showMap,
                ShowMap = showMap,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableAdminLevel1 = !IsReadOnly,
                EnableHouse = false,
                EnableApartment = false,
                EnableStreet = false,
                EnablePostalCode = false,
                EnableBuilding = false,
                EnabledLatitude = false,
                EnabledLongitude = false,
                IsDbRequiredAdminLevel1 = requireBaseAddressLevelOneAndTwo,
                IsDbRequiredAdminLevel2 = requireBaseAddressLevelOneAndTwo,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = countryId,
                AdminLevel1Value = defaultRegionId,
                AdminLevel2Value = defaultRayonId
            };
        }
        
        public void UpdateAge(DateTime? dob, DateTime? dod)
        {
            if (dob == null &&  ReportedAgeUOMID != null && ReportedAge > 0)
            {
                return;
            }
            
            if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
            {
                if (PersonalIDType == (long)PersonalIDTypeEnum.PIN)
                {
                    IsFindPINDisabled = false;
                }

                int age = 0;
                long ageType = 0;

                AgeCalculationHelper.GetDOBandAgeForPerson(dob, dod ?? DateTime.Now, ref age, ref ageType);

                ReportedAgeUOMID = ageType;
                ReportedAge = age;
            }
            else
            {
                ReportedAgeUOMID = null;
                ReportedAge = null;
                DateOfBirth = null;
                DateOfDeath = null;
                IsFindPINDisabled = true;
            }
        }

    }
}
