#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Human.ActiveSurveillanceSession;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonInformationSectionBase : PersonBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] public ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] public IPersonalIdentificationTypeMatrixClient PersonalIdentificationTypeMatrixClient { get; set; }
        [Inject] private ILogger<PersonInformationSectionBase> PersonInformationSectionLogger { get; set; }

        #endregion Dependencies

        #region Properties

        protected IList<PersonalIdentificationTypeMatrixViewModel> PersonalIdentificationTypeMatrices { get; set; }
        protected IEnumerable<BaseReferenceViewModel> PersonalIdTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> HumanAgeTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> GenderTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> CitizenshipTypes { get; set; }
        protected RadzenTemplateForm<PersonStateContainer> Form { get; set; }
        private bool IsReview { get; set; }
        protected bool IsAgeInputDisabled { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        protected RadzenDatePicker<DateTime?> dobPicker;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = PersonInformationSectionLogger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async _ => await OnStateContainerChangeAsync();

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
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonInformationSection.SetDotNetReference", _token, dotNetReference);

                if (StateContainer.PersonalIDType != (long)PersonalIDTypeEnum.PIN)
                    StateContainer.IsFindPINDisabled = true;

                SetDOBRequired();

                await GetPersonalIdentificationTypeConfigurationMatrices();
            }

            if (IsReview)
            {
                await JsRuntime.InvokeAsync<string>("PersonAddEdit.showReview", _token).ConfigureAwait(false);
                IsReview = false;
            }
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
            if (StateContainer != null)
                StateContainer.OnChange -= async _ => await OnStateContainerChangeAsync().ConfigureAwait(false);
        }

        #endregion

        #region Data Loading and Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetPersonalIdTypes(LoadDataArgs args)
        {
            try
            {
                PersonalIdTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.PersonalIDType, null);

                if (!IsNullOrEmpty(args.Filter))
                    PersonalIdTypes = PersonalIdTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetPersonalIdentificationTypeConfigurationMatrices()
        {
            try
            {
                PersonalIdentificationTypeMatrixGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "Name",
                    SortOrder = SortConstants.Ascending
                };
                PersonalIdentificationTypeMatrices =
                    await PersonalIdentificationTypeMatrixClient.GetPersonalIdentificationTypeMatrixList(request);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnPersonalIDTypeChange(object value)
        {
            SetDOBRequired();
            switch (value)
            {
                case (long)PersonalIDTypeEnum.PIN:
                    StateContainer.IsFindPINDisabled = ((StateContainer.DateOfBirth == null) ? true : false);
                    break;

                case (long)PersonalIDTypeEnum.Unknown:
                    StateContainer.IsFindPINDisabled = true;
                    StateContainer.PersonalID = null;
                    break;

                default:
                    StateContainer.IsFindPINDisabled = true;
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetHumanAgeTypes(LoadDataArgs args)
        {
            try
            {
                HumanAgeTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.HumanAgeType, null);

                if (!IsNullOrEmpty(args.Filter))
                    HumanAgeTypes = HumanAgeTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        //protected void OnHumanAgeTypeDropDownChange()
        //{
        //}

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetGenderTypes(LoadDataArgs args)
        {
            try
            {
                GenderTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.HumanGender, null);

                if (!IsNullOrEmpty(args.Filter))
                    GenderTypes = GenderTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetCitizenshipTypes(LoadDataArgs args)
        {
            try
            {
                CitizenshipTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.NationalityList, null);

                if (!IsNullOrEmpty(args.Filter))
                    CitizenshipTypes = CitizenshipTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnFindPINClick()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<PINSearch>(Localizer.GetString(HeadingResourceKeyConstants.PersonInformationHeading),
                   new Dictionary<string, object>() { { "PersonalID", StateContainer.PersonalID }, { "DateOfBirth", StateContainer.DateOfBirth } },
                   new DialogOptions() { Width = "900px", Resizable = true, Draggable = false });

                if (result is null)
                {
                    return;
                }

                PersonViewModel person = (PersonViewModel)result;
                StateContainer.PersonFirstName = person.FirstOrGivenName;
                StateContainer.PersonMiddleName = person.SecondName;
                StateContainer.PersonLastName = person.LastOrSurname;
                StateContainer.DateOfBirth = person.DateOfBirth;
                StateContainer.PersonalID = person.PersonalID;
                await UpdateAge(StateContainer.DateOfBirth);

                if (person.GenderTypeName == "Male")
                {
                    BaseReferenceViewModel male = GenderTypes.Where(gender => gender.StrDefault == "Male").First();
                    StateContainer.GenderType = male.IdfsBaseReference;
                }
                else if (person.GenderTypeName == "Female")
                {
                    BaseReferenceViewModel male = GenderTypes.Where(gender => gender.StrDefault == "Female").First();
                    StateContainer.GenderType = male.IdfsBaseReference;
                }
                //else if (person.GenderTypeName == "Unknown")
                //{
                //    BaseReferenceViewModel male = GenderTypes.Where(gender => gender.Name == "Unknown").First();
                //    StateContainer.GenderType = male.IdfsBaseReference;
                //}
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task UpdateAge(DateTime? dob)
        {
            if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
            {
                if (StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.PIN)
                {
                    StateContainer.IsFindPINDisabled = false;
                }

                TimeSpan ageInYears = DateTime.Now - Convert.ToDateTime(dob);
                if (ageInYears.Days > 365)
                {
                    StateContainer.ReportedAgeUOMID = Convert.ToInt64(HumanAgeTypeConstants.Years);
                    StateContainer.ReportedAge = ageInYears.Days / 365;
                }
                else if (ageInYears.Days == 365)
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

                await CheckDOBGreaterThan100Years();

                IsAgeInputDisabled = true;
            }
            else
            {
                StateContainer.ReportedAgeUOMID = null;
                StateContainer.ReportedAge = null;
                StateContainer.DateOfBirth = null;
                StateContainer.IsFindPINDisabled = true;
                IsAgeInputDisabled = false;
            }
        }

        public async Task CheckDOBGreaterThan100Years()
        {
            if (StateContainer.ReportedAge > 100 && StateContainer.ReportedAge < 200 && StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Years))
            {
                //dynamic result = 
                await DiagService.OpenAsync<VerifyAgeModal>(Localizer.GetString(HeadingResourceKeyConstants.PersonInformationHeading),
                null,
                new DialogOptions() { Width = "900px", Height = "230px", Resizable = false, Draggable = false });
            }
        }

        public void SetDOBRequired()
        {
            StateContainer.IsDateOfBirthRequired = (StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.PIN) ? true : null;
        }

        public async Task SetHumanAgeTypeRequired()
        {
            if (StateContainer.ReportedAge is not null && StateContainer.ReportedAge > 0) StateContainer.IsHumanAgeTypeRequired = true;
            else StateContainer.IsHumanAgeTypeRequired = false;

            await CheckDOBGreaterThan100Years();
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection(bool isReview)
        {
            bool isValid = false;
            bool isDOBValid = true;

            try
            {
                await InvokeAsync(StateHasChanged);

                isValid = Form.EditContext.Validate();

                DateTime? dob = StateContainer.DateOfBirth;

                // check if dob or years is over 200 years
                if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Years))
                {                    
                    if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
                    {
                        TimeSpan span = DateTime.Now - Convert.ToDateTime(dob);
                        DateTime zeroTime = new DateTime(1, 1, 1);
                        int years = (zeroTime + span).Year - 1;
                        if (years > 200) isDOBValid = false;
                    }
                    else
                    {
                        if (StateContainer.ReportedAge > 200) isDOBValid = false;
                    }
                }
                // check if months is over 60
                else if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Months) && StateContainer.ReportedAge > 60)
                {
                    isDOBValid = false;
                }
                // check if days is over 31
                else if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Days) && StateContainer.ReportedAge > 31)
                {
                    isDOBValid = false;
                }

                if (!isDOBValid) StateContainer.IsDOBErrorMessageVisible = true;
                else StateContainer.IsDOBErrorMessageVisible = false;

                StateContainer.PersonInformationSectionValidIndicator = isValid && isDOBValid;

                if (!Form.IsValid && isReview)
                    IsReview = true;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
            }

            //StateContainer.PersonInformationSectionValidIndicator = isValid;
            return StateContainer.PersonInformationSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region SetPersonDisabledIndicator
        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetPersonDisabledIndicator")]
        public async Task SetPersonDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 3) //review section
            {
                StateContainer.IsReadOnly = true;
                StateContainer.IsReview = true;
                await InvokeAsync(StateHasChanged);
            }
            else
            {
                StateContainer.IsReadOnly = false;
                StateContainer.IsReview = false;
                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion SetPersonDisabledIndicators

        #endregion
    }
}