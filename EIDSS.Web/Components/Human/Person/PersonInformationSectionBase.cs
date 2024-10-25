using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Helpers;
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

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonInformationSectionBase : PersonBaseComponent
    {
        protected PersonHeader PersonHeaderComponent;
        
        [Parameter]
        public Func<DateTime?> CollectEndDateOfAgeCalculationHandler { get; set; }
        
        [Parameter]
        public Func<DateTime?, Task> OnDateOnBirthChange { get; set; }
        
        [Parameter]
        public bool HdrDateOfBirthDisabled { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IPersonalIdentificationTypeMatrixClient PersonalIdentificationTypeMatrixClient { get; set; }

        [Inject]
        private IPersonalIDClient PersonalIDClient { get; set; }

        [Inject]
        private ILogger<PersonInformationSectionBase> PersonInformationSectionLogger { get; set; }

        protected IList<PersonalIdentificationTypeMatrixViewModel> PersonalIdentificationTypeMatrices { get; set; }

        protected IEnumerable<BaseReferenceViewModel> PersonalIdTypes { get; set; }

        protected IEnumerable<BaseReferenceViewModel> HumanAgeTypes { get; set; }

        protected IEnumerable<BaseReferenceViewModel> GenderTypes { get; set; }

        protected IEnumerable<BaseReferenceViewModel> CitizenshipTypes { get; set; }

        protected RadzenTemplateForm<PersonStateContainer> Form { get; set; }

        private bool IsReview { get; set; }

        protected bool IsPersonalIDTypeExists
        {
            get
            {
                return StateContainer.PersonalIDType is not null &&
                    PersonalIdentificationTypeMatrices is not null &&
                    PersonalIdentificationTypeMatrices.Any(x => x.IdfPersonalIDType == (long)StateContainer.PersonalIDType);
            }
        }

        protected bool IsPersonalIDTypeUndefined
        {
            get
            {
                return !StateContainer.PersonalIDType.HasValue ||
                    StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.Unknown;
            }
        }

        protected bool IsPersonalIDTypeNumeric
        {
            get
            {
                var fieldType = PersonalIdentificationTypeMatrices.FirstOrDefault(x => x.IdfPersonalIDType == (long)StateContainer.PersonalIDType)?.StrFieldType;
                return fieldType is not null && fieldType.Equals(PersonalIDTypeMatriceAttributeTypes.Numeric, StringComparison.OrdinalIgnoreCase);
            }
        }

        protected int? PersonalIDLength
        {
            get
            {
                return PersonalIdentificationTypeMatrices.FirstOrDefault(x => x.IdfPersonalIDType == (long)StateContainer.PersonalIDType)?.Length;
            }
        }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();
            
            _logger = PersonInformationSectionLogger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;
        }

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

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        public async Task GetPersonalIdTypes(LoadDataArgs args)
        {
            try
            {
                PersonalIdTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.PersonalIDType, null);

                if (!string.IsNullOrEmpty(args.Filter))
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

        protected async Task OnPersonalIDTypeChange(object value)
        {
            SetDOBRequired();
            switch (value)
            {
                case (long)PersonalIDTypeEnum.PIN:
                    StateContainer.IsFindPINDisabled = StateContainer.DateOfBirth == null;
                    break;
                default:
                    StateContainer.IsFindPINDisabled = true;
                    StateContainer.PersonalID = null;
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        public async Task GetHumanAgeTypes(LoadDataArgs args)
        {
            try
            {
                HumanAgeTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.HumanAgeType, null);

                HumanAgeTypes = HumanAgeTypes.Where(c =>
                        c.Name != null && !c.Name.Contains("weeks", StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetGenderTypes(LoadDataArgs args)
        {
            try
            {
                GenderTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.HumanGender, null);

                if (!string.IsNullOrEmpty(args.Filter))
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

        public async Task GetCitizenshipTypes(LoadDataArgs args)
        {
            try
            {
                CitizenshipTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.NationalityList, null);

                if (!string.IsNullOrEmpty(args.Filter))
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
                if (OnDateOnBirthChange != null)
                {
                    await OnDateOnBirthChange(person.DateOfBirth);
                }
                StateContainer.PersonalID = person.PersonalID;
                await UpdateAge();

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
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task DateOfBirthHasChanged(DateTime? dateOfBirth)
        {
            StateContainer.DateOfBirth = dateOfBirth;
            OnDateOnBirthChange?.Invoke(dateOfBirth);
            await UpdateAge();
        }

        public async Task UpdateAge()
        {
            DateTime? dob = StateContainer.DateOfBirth;
            DateTime? dod = null;
            if (CollectEndDateOfAgeCalculationHandler != null)
            {
                dod = CollectEndDateOfAgeCalculationHandler();
            }
            dod ??= StateContainer.DateOfDeath;
            if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
            {
                if (StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.PIN)
                {
                    StateContainer.IsFindPINDisabled = false;
                }


                int age = 0;
                long ageType = 0;

                AgeCalculationHelper.GetDOBandAgeForPerson(dob, dod ?? DateTime.Now, ref age, ref ageType);

                StateContainer.ReportedAgeUOMID = ageType;
                StateContainer.ReportedAge = age;
            }
            else
            {
                StateContainer.ReportedAgeUOMID = null;
                StateContainer.ReportedAge = null;
                StateContainer.DateOfBirth = null;
                StateContainer.IsFindPINDisabled = true;
            }
        }

        public void SetDOBRequired()
        {
            StateContainer.IsDateOfBirthRequired = (StateContainer.PersonalIDType == (long)PersonalIDTypeEnum.PIN) ? true : null;
        }

        public async Task SetHumanAgeTypeRequired()
        {
            if (StateContainer.ReportedAge is not null && StateContainer.ReportedAge > 0)
                StateContainer.IsHumanAgeTypeRequired = true;
            else
                StateContainer.IsHumanAgeTypeRequired = false;
        }

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
                DateTime? dod = StateContainer.DateOfDeath;

                // check if dob or years is over 200 years
                if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Years))
                {
                    if (dob is not null && dob < DateTime.Now.Date.AddDays(1))
                    {
                        TimeSpan span = DateTime.Now - Convert.ToDateTime(dob);
                        DateTime zeroTime = new(1, 1, 1);
                        int years = (zeroTime + span).Year - 1;
                        if (years > 200) isDOBValid = false;
                    }
                    else
                    {
                        if (StateContainer.ReportedAge > 200) isDOBValid = false;
                    }
                }
                // check if months is over 60
                else if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Months) &&
                    StateContainer.ReportedAge > 60)
                {
                    isDOBValid = false;
                }
                // check if days is over 31
                else if (StateContainer.ReportedAgeUOMID == Convert.ToInt64(HumanAgeTypeConstants.Days) &&
                    StateContainer.ReportedAge > 31)
                {
                    isDOBValid = false;
                }

                StateContainer.IsDOBErrorMessageVisible = !isDOBValid;

                StateContainer.PersonInformationSectionValidIndicator = isValid && isDOBValid;

                await ValidatePersonID();

                if (!Form.IsValid && isReview)
                    IsReview = true;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
            }

            return StateContainer.PersonInformationSectionValidIndicator;
        }

        private async Task ValidatePersonID()
        {
            if (string.IsNullOrEmpty(StateContainer.PersonalID) || !StateContainer.IsPersonValidationActive)
            {
                return;
            }

            StateContainer.IsPersonalIDDuplicated = await PersonalIDClient.IsPersonalIDExistsAsync(StateContainer.PersonalID, StateContainer.HumanMasterID);
            StateContainer.PersonInformationSectionValidIndicator = !StateContainer.IsPersonalIDDuplicated;
        }
        
        public async Task RefreshComponent()
        {
            await InvokeAsync(StateHasChanged);
            await PersonHeaderComponent.RefreshComponent();
        }

        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(StateHasChanged);
        }

        [JSInvokable("SetPersonDisabledIndicator")]
        public async Task SetPersonDisabledIndicator(int currentIndex)
        {
            // review section
            if (currentIndex == 3)
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
    }
}