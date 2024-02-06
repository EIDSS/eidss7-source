using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Outbreak;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Services
{
    public class PersonStateContainer
    {
        #region Private Members

        private string eIDSSPersonID;
        private string personID;        
        private string personalID;
        private long? humanMasterID;
        private string personLastName;
        private string personFirstName;
        private string personMiddleName;
        private long? personalIDType;
        private DateTime? dateOfBirth;
        private int? reportedAge;
        private long? reportedAgeUOMID;        
        private long? genderType;
        private long? citizenshipType;
        private string passportNumber;        
        private string phoneNumber;
        private string phoneNumber2;
        private string employerPhoneNumber;
        private long? phoneNumberType;
        private long? phoneNumber2Type;
        private long? occupationType;
        private string employerName;
        private DateTime? dateOfLastPresenceAtWork;
        private bool workAddressSameAsCurrentAddress;
        private bool permanentAddressSameAsCurrentAddress;
        private bool isForeignWorkAddress;
        private bool isForeignAlternateAddress;
        private bool isDiseaseReportHidden;
        private bool isOutbreakReportHidden;
        private long? foreignAlternateCountryID;
        private long? foreignWorkCountryID;
        private long? foreignSchoolCountryID;
        private long? humanGeoLocationID;
        private long? humanPermGeoLocationID;
        private long? humanAltGeoLocationID;
        private long? schoolGeoLocationID;
        private long? employerGeoLocationID;        
        private long? isStudentTypeID;
        private string workPhone;
        private string homePhone;
        private string foreignWorkAddress;
        private string foreignSchoolAddress;
        private string foreignAlternateAddress;
        private string schoolName;
        private DateTime? dateOfLastPresenceAtSchool;
        private string schoolPhoneNumber;
        private bool isForeignSchoolAddress;       
        private DateTime? dateEntered;
        private DateTime? dateModified;        
        private string contactPhone;
        private long? contactPhoneTypeID;
        private string contactPhone2;
        private long? contactPhone2TypeID;
        private string isAnotherPhone;
        private string isAnotherAddress;
        private bool isAnotherPhoneNumberHidden = true;
        private int isAnotherPhoneNumberHiddenValue;
        private bool isAnotherAddressHidden = true;
        private int isAnotherAddressHiddenValue;
        private bool isEmploymentHidden = true;
        private int isEmploymentHiddenValue;
        private long? isEmployedTypeID;
        private long? isAnotherPhoneTypeID;
        private long? isAnotherAddressTypeID;
        private bool isSchoolHidden = true;
        private int isSchoolHiddenValue;
        private bool isReadOnly;
        private bool isReview;
        private bool isHeaderVisible;
        private bool isFindPINDisabled;
        private LocationViewModel personCurrentAddressLocationModel;
        private LocationViewModel personPermanentAddressLocationModel;
        private LocationViewModel personAlternateAddressLocationModel;
        private LocationViewModel personEmploymentAddressLocationModel;
        private LocationViewModel personSchoolAddressLocationModel;
        private UserPermissions personAddSessionPermissions;
        private UserPermissions humanDiseaseReportPermissions;
        private List<CaseGetListViewModel> outbreakCases;
        private List<HumanDiseaseReportViewModel> diseaseReports;
        private List<PersonViewModel> pinSearchResults;
        private bool isHumanAgeTypeRequired;
        private bool? isDateOfBirthRequired;
        private bool isDOBErrorMessageVisible;

        #endregion

        public PersonStateContainer()
        {
            PersonCurrentAddressLocationModel = new();
            PersonPermanentAddressLocationModel = new();
            PersonAlternateAddressLocationModel = new();
            PersonEmploymentAddressLocationModel = new();
            PersonSchoolAddressLocationModel = new();
            HumanDiseaseReportPermissions = new();
            //FarmAddSessionPermissions = new();

        }

        #region Drop Down Collections

        public List<BaseReferenceViewModel> SessionStatuses { get; set; }
        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public List<BaseReferenceAdvancedListResponseModel> Species { get; set; }
        public List<BaseReferenceViewModel> SpeciesTypes { get; set; }
        public List<DiseaseSampleTypeByDiseaseResponseModel> SampleTypes { get; set; }

        #endregion region

        #region Properties  

        public string EIDSSPersonID { get => eIDSSPersonID; set { eIDSSPersonID = value; NotifyStateChanged("EIDSSPersonID"); } }
        public string PersonID { get => personID; set { personID = value; NotifyStateChanged("PersonID"); } }
        public long? HumanMasterID { get => humanMasterID; set { humanMasterID = value; NotifyStateChanged("HumanMasterID"); } }       
        public long? PersonalIDType { get => personalIDType; set { personalIDType = value; NotifyStateChanged("PersonalIDType"); } }
        public string PersonalID { get => personalID; set { personalID = value; NotifyStateChanged("PersonalID"); } }
        public string PersonLastName { get => personLastName; set { personLastName = value; NotifyStateChanged("PersonLastName"); } }
        public string PersonFirstName { get => personFirstName; set { personFirstName = value; NotifyStateChanged("PersonFirstName"); } }
        public string PersonMiddleName { get => personMiddleName; set { personMiddleName = value; NotifyStateChanged("PersonMiddleName"); } }
        public DateTime? DateOfBirth { get => dateOfBirth; set { dateOfBirth = value; NotifyStateChanged("DateOfBirth"); } }
        public int? ReportedAge { get => reportedAge; set { reportedAge = value; NotifyStateChanged("ReportedAge"); } }
        public long? ReportedAgeUOMID { get => reportedAgeUOMID; set { reportedAgeUOMID = value; NotifyStateChanged("ReportedAgeUOMID"); } }        
        public long? GenderType { get => genderType; set { genderType = value; NotifyStateChanged("GenderType"); } }
        public long? CitizenshipType { get => citizenshipType; set { citizenshipType = value; NotifyStateChanged("CitizenshipType"); } }
        public string PassportNumber { get => passportNumber; set { passportNumber = value; NotifyStateChanged("PassportNumber"); } }        
        public string PhoneNumber { get => phoneNumber; set { phoneNumber = value; NotifyStateChanged("PhoneNumber"); } }
        public string PhoneNumber2 { get => phoneNumber2; set { phoneNumber2 = value; NotifyStateChanged("PhoneNumber2"); } }
        public string EmployerPhoneNumber { get => employerPhoneNumber; set { employerPhoneNumber = value; NotifyStateChanged("EmployerPhoneNumber"); } }
        public long? PhoneNumberType { get => phoneNumberType; set { phoneNumberType = value; NotifyStateChanged("PhoneNumberType"); } }
        public long? PhoneNumber2Type { get => phoneNumber2Type; set { phoneNumber2Type = value; NotifyStateChanged("PhoneNumber2Type"); } }
        public long? OccupationType { get => occupationType; set { occupationType = value; NotifyStateChanged("OccupationType"); } }
        public string EmployerName { get => employerName; set { employerName = value; NotifyStateChanged("EmployerName"); } }
        public DateTime? DateOfLastPresenceAtWork { get => dateOfLastPresenceAtWork; set { dateOfLastPresenceAtWork = value; NotifyStateChanged("DateOfLastPresenceAtWork"); } }
        public bool WorkAddressSameAsCurrentAddress { get => workAddressSameAsCurrentAddress; set { workAddressSameAsCurrentAddress = value; NotifyStateChanged("WorkAddressSameAsCurrentAddress"); } }
        public bool PermanentAddressSameAsCurrentAddress { get => permanentAddressSameAsCurrentAddress; set { permanentAddressSameAsCurrentAddress = value; NotifyStateChanged("PermanentAddressSameAsCurrentAddress"); } }
        public bool IsForeignWorkAddress { get => isForeignWorkAddress; set { isForeignWorkAddress = value; NotifyStateChanged("IsForeignWorkAddress"); } }
        public bool IsForeignAlternateAddress { get => isForeignAlternateAddress; set { isForeignAlternateAddress = value; NotifyStateChanged("IsForeignAlternateAddress"); } }
        public bool IsDiseaseReportHidden { get => isDiseaseReportHidden; set { isDiseaseReportHidden = value; NotifyStateChanged("IsDiseaseReportHidden"); } }
        public bool IsOutbreakReportHidden { get => isOutbreakReportHidden; set { isOutbreakReportHidden = value; NotifyStateChanged("IsOutbreakReportHidden"); } }
        public string ForeignAlternateAddress { get => foreignAlternateAddress; set { foreignAlternateAddress = value; NotifyStateChanged("ForeignAlternateAddress"); } }        
        public string ForeignWorkAddress { get => foreignWorkAddress; set { foreignWorkAddress = value; NotifyStateChanged("ForeignWorkAddress"); } }
        public string ForeignSchoolAddress { get => foreignSchoolAddress; set { foreignSchoolAddress = value; NotifyStateChanged("ForeignSchoolAddress"); } }
        public string SchoolName { get => schoolName; set { schoolName = value; NotifyStateChanged("SchoolName"); } }
        public DateTime? DateOfLastPresenceAtSchool { get => dateOfLastPresenceAtSchool; set { dateOfLastPresenceAtSchool = value; NotifyStateChanged("DateOfLastPresenceAtSchool"); } }
        public string SchoolPhoneNumber { get => schoolPhoneNumber; set { schoolPhoneNumber = value; NotifyStateChanged("SchoolPhoneNumber"); } }
        public bool IsForeignSchoolAddress { get => isForeignSchoolAddress; set { isForeignSchoolAddress = value; NotifyStateChanged("IsForeignSchoolAddress"); } }        
        public long? ForeignAlternateCountryID { get => foreignAlternateCountryID; set { foreignAlternateCountryID = value; NotifyStateChanged("ForeignAlternateCountryID"); } }
        public long? ForeignWorkCountryID { get => foreignWorkCountryID; set { foreignWorkCountryID = value; NotifyStateChanged("ForeignWorkCountryID"); } }
        public long? ForeignSchoolCountryID { get => foreignSchoolCountryID; set { foreignSchoolCountryID = value; NotifyStateChanged("ForeignSchoolCountryID"); } }
        public DateTime? DateEntered { get => dateEntered; set { dateEntered = value; NotifyStateChanged("DateEntered"); } }
        public DateTime? DateModified { get => dateModified; set { dateModified = value; NotifyStateChanged("DateModified"); } }        
        public bool IsReadOnly { get => isReadOnly; set { isReadOnly = value; NotifyStateChanged("IsReadOnly"); } }
        public bool IsReview { get => isReview; set { isReview = value; NotifyStateChanged("IsReview"); } }
        public bool IsHeaderVisible { get => isHeaderVisible; set { isHeaderVisible = value; NotifyStateChanged("IsHeaderVisible"); } }
        public bool IsFindPINDisabled { get => isFindPINDisabled; set { isFindPINDisabled = value; NotifyStateChanged("IsFindPINDisabled"); } }
        public LocationViewModel PersonCurrentAddressLocationModel { get => personCurrentAddressLocationModel; set { personCurrentAddressLocationModel = value; NotifyStateChanged("PersonCurrentAddressLocationModel"); } }
        public LocationViewModel PersonPermanentAddressLocationModel { get => personPermanentAddressLocationModel; set { personPermanentAddressLocationModel = value; NotifyStateChanged("PersonPermanentAddressLocationModel"); } }
        public LocationViewModel PersonAlternateAddressLocationModel { get => personAlternateAddressLocationModel; set { personAlternateAddressLocationModel = value; NotifyStateChanged("PersonAlternateAddressLocationModel"); } }
        public LocationViewModel PersonEmploymentAddressLocationModel { get => personEmploymentAddressLocationModel; set { personEmploymentAddressLocationModel = value; NotifyStateChanged("PersonEmploymentAddressLocationModel"); } }
        public LocationViewModel PersonSchoolAddressLocationModel { get => personSchoolAddressLocationModel; set { personSchoolAddressLocationModel = value; NotifyStateChanged("PersonSchoolAddressLocationModel"); } }
        public UserPermissions PersonAddSessionPermissions { get => personAddSessionPermissions; set { personAddSessionPermissions = value; NotifyStateChanged("PersonAddSessionPermissions"); } }
        public UserPermissions HumanDiseaseReportPermissions { get => humanDiseaseReportPermissions; set { humanDiseaseReportPermissions = value; NotifyStateChanged("HumanDiseaseReportPermissions"); } }
        public List<CaseGetListViewModel> OutbreakCases { get => outbreakCases; set { outbreakCases = value; NotifyStateChanged("OutbreakCases"); } }
        public List<HumanDiseaseReportViewModel> DiseaseReports { get => diseaseReports; set { diseaseReports = value; NotifyStateChanged("DiseaseReports"); } }        
        public long? HumanGeoLocationID { get => humanGeoLocationID; set { humanGeoLocationID = value; NotifyStateChanged("HumanGeoLocationID"); } }
        public long? HumanPermGeoLocationID { get => humanPermGeoLocationID; set { humanPermGeoLocationID = value; NotifyStateChanged("HumanPermGeoLocationID"); } }
        public long? HumanAltGeoLocationID { get => humanAltGeoLocationID; set { humanAltGeoLocationID = value; NotifyStateChanged("HumanAltGeoLocationID"); } }
        public long? SchoolGeoLocationID { get => schoolGeoLocationID; set { schoolGeoLocationID = value; NotifyStateChanged("SchoolGeoLocationID"); } }
        public long? EmployerGeoLocationID { get => employerGeoLocationID; set { employerGeoLocationID = value; NotifyStateChanged("EmployerGeoLocationID"); } }        
        public long? IsStudentTypeID { get => isStudentTypeID; set { isStudentTypeID = value; NotifyStateChanged("IsStudentTypeID"); } }
        public long? IsAnotherPhoneTypeID { get => isAnotherPhoneTypeID; set { isAnotherPhoneTypeID = value; NotifyStateChanged("IsAnotherPhoneTypeID"); } }
        public long? IsAnotherAddressTypeID { get => isAnotherAddressTypeID; set { isAnotherAddressTypeID = value; NotifyStateChanged("IsAnotherAddressTypeID"); } }
        public string WorkPhone { get => workPhone; set { workPhone = value; NotifyStateChanged("WorkPhone"); } }
        public string HomePhone { get => homePhone; set { homePhone = value; NotifyStateChanged("HomePhone"); } }
        public string ContactPhone { get => contactPhone; set { contactPhone = value; NotifyStateChanged("ContactPhone"); } }
        public long? ContactPhoneTypeID { get => contactPhoneTypeID; set { contactPhoneTypeID = value; NotifyStateChanged("ContactPhoneTypeID"); } }
        public string ContactPhone2 { get => contactPhone2; set { contactPhone2 = value; NotifyStateChanged("ContactPhone2"); } }
        public long? ContactPhone2TypeID { get => contactPhone2TypeID; set { contactPhone2TypeID = value; NotifyStateChanged("ContactPhone2TypeID"); } }
        public string IsAnotherPhone { get => isAnotherPhone; set { isAnotherPhone = value; NotifyStateChanged("IsAnotherPhone"); } }
        public string IsAnotherAddress { get => isAnotherAddress; set { isAnotherAddress = value; NotifyStateChanged("IsAnotherAddress"); } }
        public bool IsAnotherPhoneNumberHidden { get => isAnotherPhoneNumberHidden; set { isAnotherPhoneNumberHidden = value; NotifyStateChanged("IsAnotherPhoneNumberHidden"); } }
        public int IsAnotherPhoneNumberHiddenValue { get => isAnotherPhoneNumberHiddenValue; set { isAnotherPhoneNumberHiddenValue = value; NotifyStateChanged("IsAnotherPhoneNumberHiddenValue"); } }
        public bool IsAnotherAddressHidden { get => isAnotherAddressHidden; set { isAnotherAddressHidden = value; NotifyStateChanged("IsAnotherAddressHidden"); } }
        public int IsAnotherAddressHiddenValue { get => isAnotherAddressHiddenValue; set { isAnotherAddressHiddenValue = value; NotifyStateChanged("IsAnotherAddressHiddenValue"); } }
        public bool IsEmploymentHidden { get => isEmploymentHidden; set { isEmploymentHidden = value; NotifyStateChanged("IsEmploymentHidden"); } }
        public int IsEmploymentHiddenValue { get => isEmploymentHiddenValue; set { isEmploymentHiddenValue = value; NotifyStateChanged("IsEmploymentHiddenValue"); } }
        public long? IsEmployedTypeID { get => isEmployedTypeID; set { isEmployedTypeID = value; NotifyStateChanged("IsEmployedTypeID"); } }
        public bool IsSchoolHidden { get => isSchoolHidden; set { isSchoolHidden = value; NotifyStateChanged("IsSchoolHidden"); } }
        public int IsSchoolHiddenValue { get => isSchoolHiddenValue; set { isSchoolHiddenValue = value; NotifyStateChanged("IsSchoolHiddenValue"); } }
        public bool PersonHeaderSectionValidIndicator { get; set; } 
        public bool PersonInformationSectionValidIndicator { get; set; }
        public bool PersonAddressSectionValidIndicator { get; set; }
        public bool PersonEmploymentSchoolSectionValidIndicator { get; set; }        
        public bool PersonReviewSectionValidIndicator { get; set; }
        public List<PersonViewModel> PINSearchResults { get => pinSearchResults; set { pinSearchResults = value; NotifyStateChanged("PINSearchResults"); } }
        public bool IsHumanAgeTypeRequired { get => isHumanAgeTypeRequired; set { isHumanAgeTypeRequired = value; NotifyStateChanged("IsHumanAgeTypeRequired"); } }
        public bool? IsDateOfBirthRequired { get => isDateOfBirthRequired; set { isDateOfBirthRequired = value; NotifyStateChanged("IsDateOfBirthRequired"); } }
        public bool IsDOBErrorMessageVisible { get => isDOBErrorMessageVisible; set { isDOBErrorMessageVisible = value; NotifyStateChanged("IsDOBErrorMessageVisible"); } }

        #endregion

        #region Collections

        //public IList<NotificationsSaveRequestModel> PendingSaveNotifications { get; set; }

        #endregion

        #region Events

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        #endregion

        #region Private Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);

        #endregion
    }
}
