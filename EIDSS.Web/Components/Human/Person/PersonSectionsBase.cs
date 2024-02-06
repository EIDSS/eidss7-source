#region Usings

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonSectionsBase : PersonBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<PersonSectionsBase> PersonSectionLogger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long? HumanMasterID { get; set; }
        [Parameter] public bool IsReadOnly { get; set; }
        [Parameter] public bool IsReview { get; set; }
       
        #endregion

        #region Member Variables

        protected bool IsProcessing;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected PersonAddressSection PersonAddressSectionComponent;
        protected PersonEmploymentSchool PersonEmploymentSchoolComponent;


        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = PersonSectionLogger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async _ => await OnStateContainerChangeAsync();

            InitializeModel();

            if (HumanMasterID != null)
            {
                StateContainer.HumanMasterID = HumanMasterID.Value;
                StateContainer.IsReadOnly = IsReadOnly;
                StateContainer.IsReview = IsReview;
                StateContainer.IsHeaderVisible = true;
                if (StateContainer.HumanMasterID != null)
                {
                    HumanPersonDetailsRequestModel request = new()
                    {
                        HumanMasterID = (long)StateContainer.HumanMasterID,
                        LangID = GetCurrentLanguage()
                    };

                    var personDetailList = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request);

                    if (personDetailList is { Count: > 0 })
                    {
                        var personDetail = personDetailList.FirstOrDefault();

                        if (personDetail != null)
                        {
                            //StateContainer.HumanMasterID = personDetail.HumanActualId;
                            StateContainer.EIDSSPersonID = personDetail.EIDSSPersonID;

                            //Person Header
                            var usFormat = new CultureInfo("en-US", false).DateTimeFormat;
                            var customFormat = new CultureInfo(GetCurrentLanguage(), false).DateTimeFormat;
                            var strDateEntered = Convert.ToDateTime(personDetail.EnteredDate, usFormat).ToString(customFormat.ShortDatePattern);
                            var strDateModified = Convert.ToDateTime(personDetail.ModificationDate, usFormat).ToString(customFormat.ShortDatePattern);
                            StateContainer.DateEntered = Convert.ToDateTime(strDateEntered);
                            StateContainer.DateModified = Convert.ToDateTime(strDateModified);

                            //Person Information
                            StateContainer.PersonFirstName = personDetail.FirstOrGivenName;
                            StateContainer.PersonMiddleName = personDetail.SecondName;
                            StateContainer.PersonLastName = personDetail.LastOrSurname;
                            StateContainer.PersonalIDType = personDetail.PersonalIDType;
                            StateContainer.PersonalID = personDetail.PersonalID;
                            var strDateOfBirth = Convert.ToDateTime(personDetail.DateOfBirth, usFormat).ToString(customFormat.ShortDatePattern);
                            StateContainer.DateOfBirth = string.IsNullOrEmpty(personDetail.DateOfBirth) ? null : Convert.ToDateTime(strDateOfBirth);
                            StateContainer.GenderType = personDetail.GenderTypeID;
                            StateContainer.CitizenshipType = personDetail.CitizenshipTypeID;
                            StateContainer.PassportNumber = personDetail.PassportNumber;
                            StateContainer.HumanGeoLocationID = personDetail.HumanGeoLocationID;
                            StateContainer.HumanPermGeoLocationID = personDetail.HumanPermGeoLocationID;
                            StateContainer.HumanAltGeoLocationID = personDetail.HumanAltGeoLocationID;
                            StateContainer.SchoolGeoLocationID = personDetail.SchoolGeoLocationID;
                            StateContainer.EmployerGeoLocationID = personDetail.EmployerGeoLocationID;
                            StateContainer.IsEmployedTypeID = personDetail.IsEmployedTypeID;
                            StateContainer.IsStudentTypeID = personDetail.IsStudentTypeID;
                            StateContainer.WorkPhone = personDetail.WorkPhone;
                            StateContainer.HomePhone = personDetail.HomePhone;
                            StateContainer.ContactPhone = personDetail.ContactPhone;
                            StateContainer.ContactPhoneTypeID = personDetail.ContactPhoneTypeID;
                            StateContainer.ContactPhone2 = personDetail.ContactPhone2;
                            StateContainer.ContactPhone2TypeID = personDetail.ContactPhone2TypeID;
                            //StateContainer.ReportedAge = personDetail.ReportedAge;
                            //StateContainer.ReportedAgeUOMID = personDetail.ReportedAgeUOMID; 
                            await UpdateAge(StateContainer.DateOfBirth, personDetail.ReportedAge, personDetail.ReportedAgeUOMID);
                            StateContainer.IsAnotherPhone = personDetail.IsAnotherPhone;
                            StateContainer.IsAnotherAddress = personDetail.YNAnotherAddress;

                            // Toggle Display of Secondary Phone Number section
                            StateContainer.IsAnotherPhoneNumberHidden = personDetail.IsAnotherPhone != "Yes";
                            if (personDetail.IsAnotherPhone == "Yes")
                            {
                                StateContainer.IsAnotherPhoneNumberHidden = false;
                                StateContainer.IsAnotherPhoneTypeID = Convert.ToInt64(YesNoValueList.Yes);
                            }
                            else
                            {
                                StateContainer.IsAnotherPhoneNumberHidden = true;
                                StateContainer.IsAnotherPhoneTypeID = Convert.ToInt64(YesNoValueList.No);
                            }

                            ////////////////////////////////////////
                            //Current Address
                            ////////////////////////////////////////
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value = personDetail.HumanidfsRegion;
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value = personDetail.HumanidfsRayon;
                            StateContainer.PersonCurrentAddressLocationModel.SettlementType = personDetail.HumanidfsSettlementType;
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value = personDetail.HumanidfsSettlement;

                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text = personDetail.HumanRegion;
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text = personDetail.HumanRayon;
                            StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text = personDetail.HumanSettlement;

                            StateContainer.PersonCurrentAddressLocationModel.PostalCodeText = personDetail.HumanstrPostalCode;
                            StateContainer.PersonCurrentAddressLocationModel.Latitude = personDetail.HumanstrLatitude;
                            StateContainer.PersonCurrentAddressLocationModel.Longitude = personDetail.HumanstrLongitude;
                            StateContainer.PersonCurrentAddressLocationModel.StreetText = personDetail.HumanstrStreetName;
                            StateContainer.PersonCurrentAddressLocationModel.House = personDetail.HumanstrHouse;
                            StateContainer.PersonCurrentAddressLocationModel.Building = personDetail.HumanstrBuilding;
                            StateContainer.PersonCurrentAddressLocationModel.Apartment = personDetail.HumanstrApartment;


                            // Toggle Display of Permanent Address and Alternate Address sections
                            StateContainer.IsAnotherAddressHidden = personDetail.YNAnotherAddress != "Yes";
                            if (StateContainer.IsAnotherAddress == "Yes")
                            {
                                StateContainer.IsAnotherAddressHidden = false;
                                StateContainer.IsAnotherAddressTypeID = Convert.ToInt64(YesNoValueList.Yes);
                            }
                            else
                            {
                                StateContainer.IsAnotherAddressHidden = true;
                                StateContainer.IsAnotherAddressTypeID = Convert.ToInt64(YesNoValueList.No);
                            }

                            //////////////////////////////////////
                            //Permanent Address
                            //////////////////////////////////////
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = personDetail.HumanPermidfsRegion;
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = personDetail.HumanPermidfsRayon;
                            StateContainer.PersonPermanentAddressLocationModel.SettlementType = personDetail.HumanPermidfsSettlementType;
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = personDetail.HumanPermidfsSettlement;

                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = personDetail.HumanPermRegion;
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = personDetail.HumanPermRayon;
                            StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = personDetail.HumanPermSettlement;

                            StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = personDetail.HumanPermstrPostalCode;
                            StateContainer.PersonPermanentAddressLocationModel.StreetText = personDetail.HumanPermstrStreetName;
                            StateContainer.PersonPermanentAddressLocationModel.House = personDetail.HumanPermstrHouse;
                            StateContainer.PersonPermanentAddressLocationModel.Building = personDetail.HumanPermstrBuilding;
                            StateContainer.PersonPermanentAddressLocationModel.Apartment = personDetail.HumanPermstrApartment;

                            if (StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value
                            && StateContainer.PersonPermanentAddressLocationModel.SettlementType == StateContainer.PersonCurrentAddressLocationModel.SettlementType
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text
                            && StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text
                            && StateContainer.PersonPermanentAddressLocationModel.PostalCodeText == StateContainer.PersonCurrentAddressLocationModel.PostalCodeText
                            && StateContainer.PersonPermanentAddressLocationModel.StreetText == StateContainer.PersonCurrentAddressLocationModel.StreetText
                            && StateContainer.PersonPermanentAddressLocationModel.House == StateContainer.PersonCurrentAddressLocationModel.House
                            && StateContainer.PersonPermanentAddressLocationModel.Building == StateContainer.PersonCurrentAddressLocationModel.Building
                            && StateContainer.PersonPermanentAddressLocationModel.Apartment == StateContainer.PersonCurrentAddressLocationModel.Apartment
                            )
                            {
                                StateContainer.PermanentAddressSameAsCurrentAddress = true;
                            }

                            //////////////////////////////////////
                            //Alternate Address
                            //////////////////////////////////////
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel1Value = personDetail.HumanAltidfsRegion;
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel2Value = personDetail.HumanAltidfsRayon;
                            StateContainer.PersonAlternateAddressLocationModel.SettlementType = personDetail.HumanAltidfsSettlementType;
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel3Value = personDetail.HumanAltidfsSettlement;

                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel1Text = personDetail.HumanAltRegion;
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel2Text = personDetail.HumanAltRayon;
                            StateContainer.PersonAlternateAddressLocationModel.AdminLevel3Text = personDetail.HumanAltSettlement;

                            StateContainer.PersonAlternateAddressLocationModel.PostalCodeText = personDetail.HumanAltstrPostalCode;
                            StateContainer.PersonAlternateAddressLocationModel.StreetText = personDetail.HumanAltstrStreetName;
                            StateContainer.PersonAlternateAddressLocationModel.House = personDetail.HumanAltstrHouse;
                            StateContainer.PersonAlternateAddressLocationModel.Building = personDetail.HumanAltstrBuilding;
                            StateContainer.PersonAlternateAddressLocationModel.Apartment = personDetail.HumanAltstrApartment;

                            //////////////////////////////////////
                            //Work Address
                            //////////////////////////////////////
                            StateContainer.EmployerName = personDetail.EmployerName;
                            StateContainer.OccupationType = personDetail.OccupationTypeID;
                            StateContainer.DateOfLastPresenceAtWork = personDetail.EmployedDateLastPresent;
                            StateContainer.EmployerPhoneNumber = personDetail.EmployerPhone;

                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value = personDetail.EmployeridfsRegion;
                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value = personDetail.EmployeridfsRayon;
                            StateContainer.PersonEmploymentAddressLocationModel.SettlementType = personDetail.EmployeridfsSettlementType;
                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value = personDetail.EmployeridfsSettlement;

                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text = personDetail.EmployerRegion;
                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text = personDetail.EmployerRayon;
                            StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text = personDetail.EmployerSettlement;

                            StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText = personDetail.EmployerstrPostalCode;
                            StateContainer.PersonEmploymentAddressLocationModel.StreetText = personDetail.EmployerstrStreetName;
                            StateContainer.PersonEmploymentAddressLocationModel.House = personDetail.EmployerstrHouse;
                            StateContainer.PersonEmploymentAddressLocationModel.Building = personDetail.EmployerstrBuilding;
                            StateContainer.PersonEmploymentAddressLocationModel.Apartment = personDetail.EmployerstrApartment;

                            if (StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value
                            && StateContainer.PersonEmploymentAddressLocationModel.SettlementType == StateContainer.PersonCurrentAddressLocationModel.SettlementType
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text
                            && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text
                            && StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText == StateContainer.PersonCurrentAddressLocationModel.PostalCodeText
                            && StateContainer.PersonEmploymentAddressLocationModel.StreetText == StateContainer.PersonCurrentAddressLocationModel.StreetText
                            && StateContainer.PersonEmploymentAddressLocationModel.House == StateContainer.PersonCurrentAddressLocationModel.House
                            && StateContainer.PersonEmploymentAddressLocationModel.Building == StateContainer.PersonCurrentAddressLocationModel.Building
                            && StateContainer.PersonEmploymentAddressLocationModel.Apartment == StateContainer.PersonCurrentAddressLocationModel.Apartment
                            )
                            {
                                StateContainer.WorkAddressSameAsCurrentAddress = true;
                            }

                            // Toggle Display of Employment Address                   
                            StateContainer.IsEmploymentHidden = personDetail.IsEmployedTypeID != Convert.ToInt64(YesNoValueList.Yes);

                            //////////////////////////////////////
                            //School Address
                            //////////////////////////////////////
                            StateContainer.SchoolName = personDetail.SchoolName;
                            StateContainer.DateOfLastPresenceAtSchool = personDetail.SchoolDateLastAttended;
                            StateContainer.SchoolPhoneNumber = personDetail.SchoolPhone;

                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel1Value = personDetail.SchoolidfsRegion;
                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel2Value = personDetail.SchoolidfsRayon;
                            StateContainer.PersonSchoolAddressLocationModel.SettlementType = personDetail.SchoolAltidfsSettlementType;
                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel3Value = personDetail.SchoolidfsSettlement;

                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel1Text = personDetail.SchoolRegion;
                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel2Text = personDetail.SchoolRayon;
                            StateContainer.PersonSchoolAddressLocationModel.AdminLevel3Text = personDetail.SchoolSettlement;

                            //StateContainer.PersonSchoolAddressLocationModel.SettlementId = personDetail.SchoolidfsSettlement;

                            StateContainer.PersonSchoolAddressLocationModel.PostalCodeText = personDetail.SchoolstrPostalCode;
                            StateContainer.PersonSchoolAddressLocationModel.StreetText = personDetail.SchoolstrStreetName;
                            StateContainer.PersonSchoolAddressLocationModel.House = personDetail.SchoolstrHouse;
                            StateContainer.PersonSchoolAddressLocationModel.Building = personDetail.SchoolstrBuilding;
                            StateContainer.PersonSchoolAddressLocationModel.Apartment = personDetail.SchoolstrApartment;

                            // Toggle Display of School Address                       
                            StateContainer.IsSchoolHidden = personDetail.IsStudentTypeID != Convert.ToInt64(YesNoValueList.Yes);
                          
                         //  await PersonEmploymentSchoolComponent.RefreshComponent();


                            await InvokeAsync(StateHasChanged);
                        }
                    }
                }
            }
            if (PersonAddressSectionComponent != null)
                await PersonAddressSectionComponent.RefreshComponent();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.SetDotNetReference", _token, dotNetReference);

                //if (HumanMasterID != null)
                //{
                //    StateContainer.HumanMasterID = HumanMasterID.Value;
                //    StateContainer.IsReadOnly = IsReadOnly;
                //    StateContainer.IsReview = IsReview;
                //    StateContainer.IsHeaderVisible = true;

                //    await GetPersonDetails();
                //}

                await JsRuntime.InvokeAsync<string>("PersonAddEdit.initializePersonSidebar", _token,
                    Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage).ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                if (StateContainer.IsReadOnly || StateContainer.IsReview)
                    await JsRuntime.InvokeVoidAsync("PersonAddEdit.navigateToReviewStep", _token);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>   
        /// </summary>
        /// <returns></returns>
        private async Task OnStateContainerChangeAsync()
        {
            //if (property == "IsDiseaseReportHidden" || property == "IsOutbreakReportHidden")
            //{
            await InvokeAsync(StateHasChanged);
            //await InvokeAsync(StateHasChanged);
            //}
        }

        public async Task RefreshChildComponent()
        {
           await PersonAddressSectionComponent.RefreshComponent();
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
            if (StateContainer != null)
                StateContainer.OnChange -= async property => await OnStateContainerChangeAsync();
        }

        #endregion

        #region Load Person Data

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task GetPersonDetails()
        {
            if (StateContainer.HumanMasterID != null)
            {
                HumanPersonDetailsRequestModel request = new()
                {
                    HumanMasterID = (long) StateContainer.HumanMasterID,
                    LangID = GetCurrentLanguage()
                };

                var personDetailList = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request);

                if (personDetailList is {Count: > 0})
                {
                    var personDetail = personDetailList.FirstOrDefault();

                    if (personDetail != null)
                    {
                        //StateContainer.HumanMasterID = personDetail.HumanActualId;
                        StateContainer.EIDSSPersonID = personDetail.EIDSSPersonID;

                        //Person Header
                        DateTimeFormatInfo usFormat = new CultureInfo("en-US", false).DateTimeFormat;
                        DateTimeFormatInfo customFormat = new CultureInfo(GetCurrentLanguage(), false).DateTimeFormat;
                        string strDateEntered = Convert.ToDateTime(personDetail.EnteredDate, usFormat).ToString(customFormat.ShortDatePattern);
                        string strDateModified = Convert.ToDateTime(personDetail.ModificationDate, usFormat).ToString(customFormat.ShortDatePattern);
                        StateContainer.DateEntered = Convert.ToDateTime(strDateEntered);
                        StateContainer.DateModified = Convert.ToDateTime(strDateModified);                        

                        //Person Information
                        StateContainer.PersonFirstName = personDetail.FirstOrGivenName;
                        StateContainer.PersonMiddleName = personDetail.SecondName;
                        StateContainer.PersonLastName = personDetail.LastOrSurname;
                        StateContainer.PersonalIDType = personDetail.PersonalIDType;
                        StateContainer.PersonalID = personDetail.PersonalID;
                        string strDateOfBirth = Convert.ToDateTime(personDetail.DateOfBirth, usFormat).ToString(customFormat.ShortDatePattern);
                        StateContainer.DateOfBirth = string.IsNullOrEmpty(personDetail.DateOfBirth) ? null : Convert.ToDateTime(strDateOfBirth);
                        StateContainer.GenderType = personDetail.GenderTypeID;
                        StateContainer.CitizenshipType = personDetail.CitizenshipTypeID;
                        StateContainer.PassportNumber = personDetail.PassportNumber;
                        StateContainer.HumanGeoLocationID = personDetail.HumanGeoLocationID;
                        StateContainer.HumanPermGeoLocationID = personDetail.HumanPermGeoLocationID;
                        StateContainer.HumanAltGeoLocationID = personDetail.HumanAltGeoLocationID;
                        StateContainer.SchoolGeoLocationID = personDetail.SchoolGeoLocationID;
                        StateContainer.EmployerGeoLocationID = personDetail.EmployerGeoLocationID;
                        StateContainer.IsEmployedTypeID = personDetail.IsEmployedTypeID;
                        StateContainer.IsStudentTypeID = personDetail.IsStudentTypeID;
                        StateContainer.WorkPhone = personDetail.WorkPhone;
                        StateContainer.HomePhone = personDetail.HomePhone;
                        StateContainer.ContactPhone = personDetail.ContactPhone;
                        StateContainer.ContactPhoneTypeID = personDetail.ContactPhoneTypeID;
                        StateContainer.ContactPhone2 = personDetail.ContactPhone2;
                        StateContainer.ContactPhone2TypeID = personDetail.ContactPhone2TypeID;
                        //StateContainer.ReportedAge = personDetail.ReportedAge;
                        //StateContainer.ReportedAgeUOMID = personDetail.ReportedAgeUOMID; 
                        await UpdateAge(StateContainer.DateOfBirth, personDetail.ReportedAge, personDetail.ReportedAgeUOMID);
                        StateContainer.IsAnotherPhone = personDetail.IsAnotherPhone;
                        StateContainer.IsAnotherAddress = personDetail.YNAnotherAddress;

                        // Toggle Display of Secondary Phone Number section
                        StateContainer.IsAnotherPhoneNumberHidden = personDetail.IsAnotherPhone != "Yes";
                        if (personDetail.IsAnotherPhone == "Yes")
                        {
                            StateContainer.IsAnotherPhoneNumberHidden = false;
                            StateContainer.IsAnotherPhoneTypeID = Convert.ToInt64(YesNoValueList.Yes);
                        }
                        else
                        {
                            StateContainer.IsAnotherPhoneNumberHidden = true;
                            StateContainer.IsAnotherPhoneTypeID = Convert.ToInt64(YesNoValueList.No);
                        }

                        ////////////////////////////////////////
                        //Current Address
                        ////////////////////////////////////////
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value = personDetail.HumanidfsRegion;
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value = personDetail.HumanidfsRayon;
                        StateContainer.PersonCurrentAddressLocationModel.SettlementType = personDetail.HumanidfsSettlementType;
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value = personDetail.HumanidfsSettlement;                        

                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text = personDetail.HumanRegion;                        
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text = personDetail.HumanRayon;
                        StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text = personDetail.HumanSettlement;                        

                        StateContainer.PersonCurrentAddressLocationModel.PostalCodeText = personDetail.HumanstrPostalCode;
                        StateContainer.PersonCurrentAddressLocationModel.Latitude = personDetail.HumanstrLatitude;
                        StateContainer.PersonCurrentAddressLocationModel.Longitude = personDetail.HumanstrLongitude;
                        StateContainer.PersonCurrentAddressLocationModel.StreetText = personDetail.HumanstrStreetName;
                        StateContainer.PersonCurrentAddressLocationModel.House = personDetail.HumanstrHouse;
                        StateContainer.PersonCurrentAddressLocationModel.Building = personDetail.HumanstrBuilding;
                        StateContainer.PersonCurrentAddressLocationModel.Apartment = personDetail.HumanstrApartment;
                        
                        
                        // Toggle Display of Permanent Address and Alternate Address sections
                        StateContainer.IsAnotherAddressHidden = personDetail.YNAnotherAddress != "Yes";
                        if (StateContainer.IsAnotherAddress == "Yes")
                        {
                            StateContainer.IsAnotherAddressHidden = false;
                            StateContainer.IsAnotherAddressTypeID = Convert.ToInt64(YesNoValueList.Yes);
                        }
                        else
                        {
                            StateContainer.IsAnotherAddressHidden = true;
                            StateContainer.IsAnotherAddressTypeID = Convert.ToInt64(YesNoValueList.No);
                        }

                        //////////////////////////////////////
                        //Permanent Address
                        //////////////////////////////////////
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value = personDetail.HumanPermidfsRegion;
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value = personDetail.HumanPermidfsRayon;
                        StateContainer.PersonPermanentAddressLocationModel.SettlementType = personDetail.HumanPermidfsSettlementType;
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value = personDetail.HumanPermidfsSettlement;

                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text = personDetail.HumanPermRegion;                        
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text = personDetail.HumanPermRayon;
                        StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text = personDetail.HumanPermSettlement;                        

                        StateContainer.PersonPermanentAddressLocationModel.PostalCodeText = personDetail.HumanPermstrPostalCode;
                        StateContainer.PersonPermanentAddressLocationModel.StreetText = personDetail.HumanPermstrStreetName;
                        StateContainer.PersonPermanentAddressLocationModel.House = personDetail.HumanPermstrHouse;
                        StateContainer.PersonPermanentAddressLocationModel.Building = personDetail.HumanPermstrBuilding;
                        StateContainer.PersonPermanentAddressLocationModel.Apartment = personDetail.HumanPermstrApartment;

                        if(StateContainer.PersonPermanentAddressLocationModel.AdminLevel0Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value
                        && StateContainer.PersonPermanentAddressLocationModel.SettlementType == StateContainer.PersonCurrentAddressLocationModel.SettlementType
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel1Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel2Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text
                        && StateContainer.PersonPermanentAddressLocationModel.AdminLevel3Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text
                        && StateContainer.PersonPermanentAddressLocationModel.PostalCodeText == StateContainer.PersonCurrentAddressLocationModel.PostalCodeText
                        && StateContainer.PersonPermanentAddressLocationModel.StreetText == StateContainer.PersonCurrentAddressLocationModel.StreetText
                        && StateContainer.PersonPermanentAddressLocationModel.House == StateContainer.PersonCurrentAddressLocationModel.House
                        && StateContainer.PersonPermanentAddressLocationModel.Building == StateContainer.PersonCurrentAddressLocationModel.Building
                        && StateContainer.PersonPermanentAddressLocationModel.Apartment == StateContainer.PersonCurrentAddressLocationModel.Apartment
                        )
                        {
                            StateContainer.PermanentAddressSameAsCurrentAddress = true;
                        }

                        //////////////////////////////////////
                        //Alternate Address
                        //////////////////////////////////////
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel1Value = personDetail.HumanAltidfsRegion;
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel2Value = personDetail.HumanAltidfsRayon;
                        StateContainer.PersonAlternateAddressLocationModel.SettlementType = personDetail.HumanAltidfsSettlementType;
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel3Value = personDetail.HumanAltidfsSettlement;

                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel1Text = personDetail.HumanAltRegion;                        
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel2Text = personDetail.HumanAltRayon;
                        StateContainer.PersonAlternateAddressLocationModel.AdminLevel3Text = personDetail.HumanAltSettlement;                                                

                        StateContainer.PersonAlternateAddressLocationModel.PostalCodeText = personDetail.HumanAltstrPostalCode;
                        StateContainer.PersonAlternateAddressLocationModel.StreetText = personDetail.HumanAltstrStreetName;
                        StateContainer.PersonAlternateAddressLocationModel.House = personDetail.HumanAltstrHouse;
                        StateContainer.PersonAlternateAddressLocationModel.Building = personDetail.HumanAltstrBuilding;
                        StateContainer.PersonAlternateAddressLocationModel.Apartment = personDetail.HumanAltstrApartment;

                        //////////////////////////////////////
                        //Work Address
                        //////////////////////////////////////
                        StateContainer.EmployerName = personDetail.EmployerName;
                        StateContainer.OccupationType = personDetail.OccupationTypeID;
                        StateContainer.DateOfLastPresenceAtWork = personDetail.EmployedDateLastPresent;
                        StateContainer.EmployerPhoneNumber = personDetail.EmployerPhone;

                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value = personDetail.EmployeridfsRegion;
                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value = personDetail.EmployeridfsRayon;
                        StateContainer.PersonEmploymentAddressLocationModel.SettlementType = personDetail.EmployeridfsSettlementType;
                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value = personDetail.EmployeridfsSettlement;

                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text = personDetail.EmployerRegion;                        
                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text = personDetail.EmployerRayon;
                        StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text = personDetail.EmployerSettlement;                        

                        StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText = personDetail.EmployerstrPostalCode;
                        StateContainer.PersonEmploymentAddressLocationModel.StreetText = personDetail.EmployerstrStreetName;
                        StateContainer.PersonEmploymentAddressLocationModel.House = personDetail.EmployerstrHouse;
                        StateContainer.PersonEmploymentAddressLocationModel.Building = personDetail.EmployerstrBuilding;
                        StateContainer.PersonEmploymentAddressLocationModel.Apartment = personDetail.EmployerstrApartment;

                        if (StateContainer.PersonEmploymentAddressLocationModel.AdminLevel0Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel0Value
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Value
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Value
                        && StateContainer.PersonEmploymentAddressLocationModel.SettlementType == StateContainer.PersonCurrentAddressLocationModel.SettlementType
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Value == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Value
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel1Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel1Text
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel2Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel2Text
                        && StateContainer.PersonEmploymentAddressLocationModel.AdminLevel3Text == StateContainer.PersonCurrentAddressLocationModel.AdminLevel3Text
                        && StateContainer.PersonEmploymentAddressLocationModel.PostalCodeText == StateContainer.PersonCurrentAddressLocationModel.PostalCodeText
                        && StateContainer.PersonEmploymentAddressLocationModel.StreetText == StateContainer.PersonCurrentAddressLocationModel.StreetText
                        && StateContainer.PersonEmploymentAddressLocationModel.House == StateContainer.PersonCurrentAddressLocationModel.House
                        && StateContainer.PersonEmploymentAddressLocationModel.Building == StateContainer.PersonCurrentAddressLocationModel.Building
                        && StateContainer.PersonEmploymentAddressLocationModel.Apartment == StateContainer.PersonCurrentAddressLocationModel.Apartment
                        )
                        {
                            StateContainer.WorkAddressSameAsCurrentAddress = true;
                        }

                        // Toggle Display of Employment Address                   
                        StateContainer.IsEmploymentHidden = personDetail.IsEmployedTypeID != Convert.ToInt64(YesNoValueList.Yes);

                        //////////////////////////////////////
                        //School Address
                        //////////////////////////////////////
                        StateContainer.SchoolName = personDetail.SchoolName;
                        StateContainer.DateOfLastPresenceAtSchool = personDetail.SchoolDateLastAttended;
                        StateContainer.SchoolPhoneNumber = personDetail.SchoolPhone;

                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel0Value = personDetail.HumanidfsCountry;
                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel1Value = personDetail.SchoolidfsRegion;
                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel2Value = personDetail.SchoolidfsRayon;
                        StateContainer.PersonSchoolAddressLocationModel.SettlementType = personDetail.SchoolAltidfsSettlementType;
                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel3Value = personDetail.SchoolidfsSettlement;

                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel1Text = personDetail.SchoolRegion;                        
                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel2Text = personDetail.SchoolRayon;
                        StateContainer.PersonSchoolAddressLocationModel.AdminLevel3Text = personDetail.SchoolSettlement;

                        //StateContainer.PersonSchoolAddressLocationModel.SettlementId = personDetail.SchoolidfsSettlement;

                        StateContainer.PersonSchoolAddressLocationModel.PostalCodeText = personDetail.SchoolstrPostalCode;
                        StateContainer.PersonSchoolAddressLocationModel.StreetText = personDetail.SchoolstrStreetName;
                        StateContainer.PersonSchoolAddressLocationModel.House = personDetail.SchoolstrHouse;
                        StateContainer.PersonSchoolAddressLocationModel.Building = personDetail.SchoolstrBuilding;
                        StateContainer.PersonSchoolAddressLocationModel.Apartment = personDetail.SchoolstrApartment;

                        // Toggle Display of School Address                       
                        StateContainer.IsSchoolHidden = personDetail.IsStudentTypeID != Convert.ToInt64(YesNoValueList.Yes);

                        await InvokeAsync(StateHasChanged);
                    }
                }
            }
        }

        #endregion

        #region Initializa Defaults

        /// <summary>
        /// </summary>
        private void InitializeModel()
        {
            //var systemPreferences = ConfigurationService.SystemPreferences;
            var userPreferences =
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            //var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            StateContainer.PersonAddSessionPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
            StateContainer.HumanDiseaseReportPermissions =
                GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

            // Current Address Location Model
            StateContainer.PersonCurrentAddressLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowLatitude = true,
                ShowLongitude = true,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableHouse = true,
                EnableApartment = true,
                EnableStreet = true,
                EnablePostalCode = true,
                EnableBuilding = true,
                EnabledLatitude = true,
                EnabledLongitude = true,                
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null
            };

            // Permanent Address Location Model
            StateContainer.PersonPermanentAddressLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableHouse = true,
                EnableApartment = true,
                EnableStreet = true,
                EnablePostalCode = true,
                EnableBuilding = true,
                EnabledLatitude = false,
                EnabledLongitude = false,
                IsDbRequiredAdminLevel1 = !ShowInDialog,
                IsDbRequiredAdminLevel2 = !ShowInDialog,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null
            };

            // Alternate Address Location Model
            StateContainer.PersonAlternateAddressLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableHouse = true,
                EnableApartment = true,
                EnableStreet = true,
                EnablePostalCode = true,
                EnableBuilding = true,
                EnabledLatitude = false,
                EnabledLongitude = false,
                IsDbRequiredAdminLevel1 = !ShowInDialog,
                IsDbRequiredAdminLevel2 = !ShowInDialog,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null
            };

            // Employment Address Location Model
            StateContainer.PersonEmploymentAddressLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableHouse = true,
                EnableApartment = true,
                EnableStreet = true,
                EnablePostalCode = true,
                EnableBuilding = true,
                EnabledLatitude = false,
                EnabledLongitude = false,
                IsDbRequiredAdminLevel1 = !ShowInDialog,
                IsDbRequiredAdminLevel2 = !ShowInDialog,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null
            };

            // School Address Location Model
            StateContainer.PersonSchoolAddressLocationModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
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
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                EnableHouse = true,
                EnableApartment = true,
                EnableStreet = true,
                EnablePostalCode = true,
                EnableBuilding = true,
                EnabledLatitude = false,
                EnabledLongitude = false,
                IsDbRequiredAdminLevel1 = !ShowInDialog,
                IsDbRequiredAdminLevel2 = !ShowInDialog,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(CountryID),
                AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : null,
                AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : null
            };
        }

        #endregion

        #region Submit Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnSubmit")]
        public async Task OnSubmit()
        {
            try
            {
                IsProcessing = true;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                var response = await SavePerson();

                Logger.LogInformation("Save Person OnSubmit starts");

                if (response.ReturnCode == 0)
                {
                    dynamic result;

                    Logger.LogInformation("Save Person OnSubmit ReturnCode 0");

                    if (StateContainer.HumanMasterID is 0 or null)
                    {
                        Logger.LogInformation("Save Person OnSubmit before ShowInDialog");
                        if (ShowInDialog)
                        {
                            Logger.LogInformation("Save Person OnSubmit inside if ShowInDialog");
                            result = new PersonViewModel
                            {
                                HumanMasterID = response.HumanMasterID.GetValueOrDefault(),
                                EIDSSPersonID = response.EIDSSPersonID,
                                PersonalID = StateContainer.PersonalID,
                                FullName = StateContainer.PersonLastName +
                                           (string.IsNullOrEmpty(StateContainer.PersonFirstName)
                                               ? ""
                                               : ", " + StateContainer.PersonFirstName),
                                FirstOrGivenName = StateContainer.PersonFirstName,
                                LastOrSurname = StateContainer.PersonLastName,
                                SecondName = StateContainer.PersonMiddleName

                            };

                            Logger.LogInformation("Save Person OnSubmit inside if before PersonAddEdit.stopProcessing");

                            await JsRuntime.InvokeVoidAsync("PersonAddEdit.stopProcessing", _token);

                            DiagService.Close(result);
                        }
                        else
                        {
                            var message = Localizer.GetString(MessageResourceKeyConstants
                                              .RecordSavedSuccessfullyMessage) +
                                          $"{Localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage)}: {response.EIDSSPersonID}";

                            Logger.LogInformation("Save Person OnSubmit inside if before ShowSuccessDialog");

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.ReturnToDashboardButton,
                                ButtonResourceKeyConstants.PersonReturnToPersonRecordButtonText);

                            Logger.LogInformation("Save Person OnSubmit inside if after ShowSuccessDialog");
                        }
                    }
                    else
                    {
                        Logger.LogInformation("Save Person OnSubmit inside if else before ShowSuccessDialog");
                        Logger.LogInformation("Save Person OnSubmit before ShowInDialog else" );
                        result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.PersonReturnToPersonRecordButtonText);
                        Logger.LogInformation("Save Person OnSubmit inside if else after ShowSuccessDialog");
                    }

                    if (result is DialogReturnResult returnResult)
                    {
                        Logger.LogInformation("Save Person OnSubmit inside returnResult");
                        if (returnResult.ButtonResultText ==
                            Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                        {
                            DiagService.Close();

                            _source?.Cancel();

                            var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                            NavManager.NavigateTo(uri, true);
                        }
                        else
                        {
                            IsProcessing = false;
                            if (StateContainer.HumanMasterID is 0 or null)
                                StateContainer.HumanMasterID = response.HumanMasterID;

                            DiagService.Close();

                            const string path = "Human/Person/Details";
                            var query = $"?id={StateContainer.HumanMasterID}&isReview=true";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsProcessing = false;
            }
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnCancel")]
        public async Task OnCancel()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        if (ShowInDialog == false)
                        {
                            var uri = $"{NavManager.BaseUri}Human/Person";

                            NavManager.NavigateTo(uri, true);
                        }
                    }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Click Event
        #endregion

        #region Review Section Validation

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("ValidatePersonReviewSection")]
        public bool ValidatePersonReviewSection()
        {
            // nothing to validate on this header
            StateContainer.PersonHeaderSectionValidIndicator = true;

            // validate the entire record before save
            if (ValidateMinimumPersonFields() &&
                StateContainer.PersonHeaderSectionValidIndicator &&
                StateContainer.PersonInformationSectionValidIndicator &&
                StateContainer.PersonAddressSectionValidIndicator)
                StateContainer.PersonReviewSectionValidIndicator = true;

            return StateContainer.PersonReviewSectionValidIndicator;
        }

        public async Task UpdateAge(DateTime? dob, int? reportedAge, long? reportedAgeUOMID)
        {
            if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
            {
                if (StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.PIN)
                {
                    StateContainer.IsFindPINDisabled = false;
                }

                var ageInYears = DateTime.Now - Convert.ToDateTime(dob);
                if (ageInYears.Days > 365)
                {
                    StateContainer.ReportedAgeUOMID = Convert.ToInt64(HumanAgeTypeConstants.Years);
                    StateContainer.ReportedAge = ageInYears.Days / 365;
                }
                else if (ageInYears.Days < 7)
                {
                    StateContainer.ReportedAgeUOMID = Convert.ToInt64(HumanAgeTypeConstants.Days);
                    StateContainer.ReportedAge = ageInYears.Days;
                }
                else if (ageInYears.Days < 31)
                {
                    StateContainer.ReportedAgeUOMID = Convert.ToInt64(HumanAgeTypeConstants.Weeks);
                    StateContainer.ReportedAge = ageInYears.Days / 7;
                }
                else if (ageInYears.Days < 365)
                {
                    StateContainer.ReportedAgeUOMID = Convert.ToInt64(HumanAgeTypeConstants.Months);
                    StateContainer.ReportedAge = ageInYears.Days / 30;
                }
            }
            else
            {
                StateContainer.ReportedAge = reportedAge;
                StateContainer.ReportedAgeUOMID = reportedAgeUOMID;                
                StateContainer.DateOfBirth = null;
                StateContainer.IsFindPINDisabled = true;
            }
        }
        #endregion


        #endregion
    }
}