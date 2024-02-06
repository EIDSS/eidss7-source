using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.ApiClients.PIN;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Enumerations;
using Microsoft.Extensions.Localization;

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected PersonStateContainer StateContainer { get; set; }

        [Inject]
        protected IPersonClient PersonClient { get; set; }

        [Inject]
        protected IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        protected IOutbreakClient OutbreakClient { get; set; }

        [Inject]
        protected IPINClient PINClient { get; set; }

        [Inject]
        protected IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        protected IJSRuntime JsRuntime { get; set; }

        [Inject]
        protected ILogger<PersonBaseComponent> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SearchModeEnum Mode { get; set; }
        [Parameter] public LocalizedString ReturnButtonResourceString { get; set; }
        [Parameter] public EventCallback<long?> PersonAddEditComplete { get; set; }
        [Parameter] public bool ShowInDialog { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new();
            _token = _source.Token;

            return base.OnInitializedAsync();
        }

        #endregion

        #region Person Header Section Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public bool ValidatePersonHeaderSection()
        {
            StateContainer.PersonHeaderSectionValidIndicator = true;
            return true;
        }

        #endregion

        #region Person Information Section Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public bool ValidatePersonInformationSection()
        {
            StateContainer.PersonInformationSectionValidIndicator = true;
            return true;
        }

        #endregion

        #region Person Address Section Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public bool ValidatePersonAddressSection()
        {
            StateContainer.PersonAddressSectionValidIndicator = true;
            return true;
        }

        public bool ValidatePersonEmploymentSchoolSection()
        {
            StateContainer.PersonEmploymentSchoolSectionValidIndicator = true;
            return true;
        }

        #endregion

        #region Person Review Section Methods

        protected bool ValidateMinimumPersonFields()
        {
            bool isValid = true;

            if(string.IsNullOrEmpty(StateContainer.PersonLastName) 
                || StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value is null
                || StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value is null)
            {
                isValid = false;
            }
            else if(StateContainer.PersonalIDType != (long)PersonalIDTypeEnum.Unknown && string.IsNullOrEmpty(StateContainer.PersonalID))
            {
                isValid = false;
            }

            if (isValid)
            {
                StateContainer.PersonInformationSectionValidIndicator = true;
                StateContainer.PersonAddressSectionValidIndicator = true;
                StateContainer.PersonEmploymentSchoolSectionValidIndicator = true;
            }

            return isValid;

        }
        #endregion

        #region Save Person Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        protected async Task<PersonSaveResponseModel> SavePerson()
        {
            try
            {
                Logger.LogInformation("Save Person Started");
                PersonSaveRequestModel request = new();
                PersonSaveResponseModel response = new();

                var systemPreferences = ConfigurationService.SystemPreferences;                                

                if (StateContainer.PersonInformationSectionValidIndicator
                    && StateContainer.PersonAddressSectionValidIndicator
                    && StateContainer.PersonEmploymentSchoolSectionValidIndicator)
                {
                    request.HumanMasterID = StateContainer.HumanMasterID;                                        
                    request.CopyToHumanIndicator = false;
                    request.PersonalIDType = StateContainer.PersonalIDType;

                    request.EIDSSPersonID = StateContainer.EIDSSPersonID; 
                    request.PersonalID = StateContainer.PersonalID;
                    request.FirstName = StateContainer.PersonFirstName;
                    request.SecondName = StateContainer.PersonMiddleName;
                    request.LastName = StateContainer.PersonLastName;

                    if (StateContainer.DateOfBirth == DateTime.MinValue) StateContainer.DateOfBirth = null;
                    else request.DateOfBirth = StateContainer.DateOfBirth;

                    request.ReportedAge = StateContainer.ReportedAge;
                    request.ReportAgeUOMID = StateContainer.ReportedAgeUOMID;
                    request.HumanGenderTypeID = StateContainer.GenderType;
                    request.CitizenshipTypeID = StateContainer.CitizenshipType;
                    request.PassportNumber = StateContainer.PassportNumber;

                    // Current Address Info
                    request.HumanGeoLocationID = StateContainer.HumanGeoLocationID; 
                    request.HumanidfsLocation = GetLowestLocationID(StateContainer.PersonCurrentAddressLocationModel);
                    request.HumanstrStreetName = StateContainer.PersonCurrentAddressLocationModel.StreetText;
                    request.HumanstrApartment = StateContainer.PersonCurrentAddressLocationModel.Apartment;
                    request.HumanstrBuilding = StateContainer.PersonCurrentAddressLocationModel.Building;
                    request.HumanstrHouse = StateContainer.PersonCurrentAddressLocationModel.House;
                    request.HumanidfsPostalCode = StateContainer.PersonCurrentAddressLocationModel.PostalCodeText;
                    request.HumanstrLatitude = StateContainer.PersonCurrentAddressLocationModel.Latitude;
                    request.HumanstrLongitude = StateContainer.PersonCurrentAddressLocationModel.Longitude;
                    

                    if(StateContainer.IsAnotherAddressTypeID == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
                    {
                        // Permanent Address Info                        
                        request.HumanPermGeoLocationID = StateContainer.HumanPermGeoLocationID;
                        request.HumanPermidfsLocation = GetLowestLocationID(StateContainer.PersonPermanentAddressLocationModel);
                        request.HumanPermstrStreetName = StateContainer.PersonPermanentAddressLocationModel.StreetText;
                        request.HumanPermstrApartment = StateContainer.PersonPermanentAddressLocationModel.Apartment;
                        request.HumanPermstrBuilding = StateContainer.PersonPermanentAddressLocationModel.Building;
                        request.HumanPermstrHouse = StateContainer.PersonPermanentAddressLocationModel.House;
                        request.HumanPermidfsPostalCode = StateContainer.PersonPermanentAddressLocationModel.PostalCodeText;
                        //request.HumanstrLatitude = StateContainer.PersonPermanentAddressLocationModel.Latitude;
                        //request.HumanstrLongitude = StateContainer.PersonPermanentAddressLocationModel.Longitude;

                        // Alternate Address Info
                        request.HumanAltGeoLocationID = StateContainer.HumanAltGeoLocationID;
                        request.HumanAltForeignAddressIndicator = StateContainer.IsForeignAlternateAddress;
                        request.HumanAltForeignAddressString = StateContainer.ForeignAlternateAddress;

                        if (request.HumanAltForeignAddressIndicator == true)
                            request.HumanAltidfsLocation = StateContainer.ForeignAlternateCountryID;
                        else
                            request.HumanAltidfsLocation = GetLowestLocationID(StateContainer.PersonAlternateAddressLocationModel);

                        request.HumanAltstrStreetName = StateContainer.PersonAlternateAddressLocationModel.StreetText;
                        request.HumanAltstrApartment = StateContainer.PersonAlternateAddressLocationModel.Apartment;
                        request.HumanAltstrBuilding = StateContainer.PersonAlternateAddressLocationModel.Building;
                        request.HumanAltstrHouse = StateContainer.PersonAlternateAddressLocationModel.House;
                        request.HumanAltidfsPostalCode = StateContainer.PersonAlternateAddressLocationModel.PostalCodeText;

                        request.HomePhone = StateContainer.HomePhone;
                        request.WorkPhone = StateContainer.WorkPhone;
                    }
                    
                    // Phone Number 1 
                    request.ContactPhoneCountryCode = null;
                    request.ContactPhone = StateContainer.ContactPhone;
                    request.ContactPhoneTypeID = StateContainer.ContactPhoneTypeID;

                    // Phone Number 2
                    request.ContactPhone2CountryCode = null;
                    if (StateContainer.IsAnotherPhoneTypeID == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
                    {                        
                        request.ContactPhone2 = StateContainer.ContactPhone2;
                        request.ContactPhone2TypeID = StateContainer.ContactPhone2TypeID;
                    }
                  
                    // Employment Information
                    request.IsEmployedTypeID = StateContainer.IsEmployedTypeID;
                    if (StateContainer.IsEmployedTypeID == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
                    {
                        request.OccupationTypeID = StateContainer.OccupationType;
                        request.EmployerName = StateContainer.EmployerName;
                        
                        //request.EmployedDateLastPresent = StateContainer.DateOfLastPresenceAtWork;
                        if (StateContainer.DateOfLastPresenceAtWork == DateTime.MinValue) StateContainer.DateOfLastPresenceAtWork = null;
                        else request.EmployedDateLastPresent = StateContainer.DateOfLastPresenceAtWork;

                        request.EmployerForeignAddressIndicator = StateContainer.IsForeignWorkAddress;
                        request.EmployerForeignAddressString = StateContainer.ForeignWorkAddress;
                        request.EmployerGeoLocationID = StateContainer.EmployerGeoLocationID;

                        if (request.EmployerForeignAddressIndicator == true)
                            request.EmployeridfsLocation = StateContainer.ForeignWorkCountryID;
                        else
                            request.EmployeridfsLocation = GetLowestLocationID(StateContainer.PersonEmploymentAddressLocationModel);

                        request.EmployerstrStreetName = StateContainer.PersonEmploymentAddressLocationModel.StreetText;
                        request.EmployerstrApartment = StateContainer.PersonEmploymentAddressLocationModel.Apartment;
                        request.EmployerstrBuilding = StateContainer.PersonEmploymentAddressLocationModel.Building;
                        request.EmployerstrHouse = StateContainer.PersonEmploymentAddressLocationModel.House;
                        request.EmployeridfsPostalCode = StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText;
                        request.EmployerPhone = StateContainer.EmployerPhoneNumber;
                    }                  
                    
                    // School Information
                    request.IsStudentTypeID = StateContainer.IsStudentTypeID;
                    if (StateContainer.IsStudentTypeID == Convert.ToInt64(EIDSSConstants.YesNoValueList.Yes))
                    {
                        request.SchoolName = StateContainer.SchoolName;

                        //request.SchoolDateLastAttended = StateContainer.DateOfLastPresenceAtSchool;
                        if (StateContainer.DateOfLastPresenceAtSchool == DateTime.MinValue) StateContainer.DateOfLastPresenceAtSchool = null;
                        else request.SchoolDateLastAttended = StateContainer.DateOfLastPresenceAtSchool;

                        request.SchoolForeignAddressIndicator = StateContainer.IsForeignSchoolAddress;
                        request.SchoolForeignAddressString = StateContainer.ForeignSchoolAddress;
                        request.SchoolGeoLocationID = StateContainer.SchoolGeoLocationID;

                        if (request.SchoolForeignAddressIndicator == true)
                            request.SchoolidfsLocation = StateContainer.ForeignSchoolCountryID;
                        else
                            request.SchoolidfsLocation = GetLowestLocationID(StateContainer.PersonSchoolAddressLocationModel);

                        request.SchoolstrStreetName = StateContainer.PersonSchoolAddressLocationModel.StreetText;
                        request.SchoolstrApartment = StateContainer.PersonSchoolAddressLocationModel.Apartment;
                        request.SchoolstrBuilding = StateContainer.PersonSchoolAddressLocationModel.Building;
                        request.SchoolstrHouse = StateContainer.PersonSchoolAddressLocationModel.House;
                        request.SchoolidfsPostalCode = StateContainer.PersonSchoolAddressLocationModel.PostalCodeText;
                        request.SchoolPhone = StateContainer.SchoolPhoneNumber;
                    }

                    // Audit User
                    request.AuditUser = authenticatedUser.UserName;

                    Logger.LogInformation("Save Person Before Api call");


                    //Save!
                    response = await PersonClient.SavePerson(request);

                    Logger.LogInformation("Save Person after Api call");

                    Logger.LogInformation("Save Person Completed");

                    return response;
                }
                //else
                //{
                //    if (!StateContainer.PersonInformationSectionValidIndicator)
                //    {
                //        await JsRuntime.InvokeVoidAsync("navigateToReviewStep", 0);
                //    }
                //}
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return new PersonSaveResponseModel();
        }

        #endregion

        #region Delete Person Methods

        #endregion

        #region Helper Methods
        
        //private long? GetLowestLocationID(long? level0, long? level1, long? level2, long? level3)
        //{
        //    long? idfsLocation = null;

        //    //Get lowest administrative level.
        //    if (level3 != null)
        //        idfsLocation = level3;
        //    else if (level2 != null)
        //        idfsLocation = level2;
        //    else if (level1 != null)
        //        idfsLocation = level1;
        //    else
        //        idfsLocation = level0;

        //    return idfsLocation;
        //}

        private long? GetLowestLocationID(LocationViewModel locationViewModel)
        {
            //var LocationViewModel = 
            if (locationViewModel.AdministrativeLevelId is null)
            {
                //Get lowest administrative level for location
                if (locationViewModel.AdminLevel5Value.HasValue)
                    return locationViewModel.AdminLevel5Value.Value;

                else if (locationViewModel.AdminLevel4Value.HasValue)
                    return locationViewModel.AdminLevel4Value.Value;

                else if (locationViewModel.AdminLevel3Value.HasValue)
                    return locationViewModel.AdminLevel3Value.Value;

                else if (locationViewModel.AdminLevel2Value.HasValue)
                    return locationViewModel.AdminLevel2Value.Value;

                else if (locationViewModel.AdminLevel1Value.HasValue)
                    return locationViewModel.AdminLevel1Value.Value;
            }
            return locationViewModel.AdministrativeLevelId;
            
        }
       

        #endregion

        #endregion
    }
}
