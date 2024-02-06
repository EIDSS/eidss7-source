#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Components.Human.SearchPerson;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Human.Person;
using Microsoft.Extensions.Localization;
using static System.String;
using EIDSS.Web.Components.Human.ActiveSurveillanceSession;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmInformationSectionBase : FarmBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] public ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private ILogger<FarmInformationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenTextBox EidssFarmIdControl { get; set; }
        protected RadzenTextBox DateEnteredControl { get; set; }
        protected RadzenTextBox LegacyIdControl { get; set; }
        protected RadzenTextBox FarmOwnerIdControl { get; set; }
        protected RadzenTextBox FarmNameControl { get; set; }
        protected RadzenCheckBoxList<long> FarmTypeCheckBoxList { get; set; }
        protected RadzenTextBox PhoneControl { get; set; }
        protected RadzenTextBox FaxControl { get; set; }
        protected RadzenTextBox EmailControl { get; set; }
        protected RadzenTemplateForm<FarmStateContainer> Form { get; set; }
        protected List<BaseReferenceViewModel> FarmTypes { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        private const string DialogWidth = "700px";
        private const string DialogHeight = "775px";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

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
                await JsRuntime.InvokeVoidAsync("FarmInformationSection.SetDotNetReference", _token, dotNetReference);

                await GetFarmTypesAsync();

                if (StateContainer.DiseaseReports is null)
                {
                    if (StateContainer.FarmMasterID != null)
                    {
                        var request = new VeterinaryDiseaseReportSearchRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            FarmMasterID = StateContainer.FarmMasterID.Value,
                            Page = 1,
                            PageSize = 10,
                            SortColumn = "ReportID",
                            SortOrder = EIDSSConstants.SortConstants.Descending,
                            IncludeSpeciesListIndicator = true,
                            ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           ((long)SiteTypes.ThirdLevel),
                            UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                            UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                            UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId)
                        };
                        StateContainer.DiseaseReports = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, _token);
                        StateContainer.DiseaseReports = StateContainer.DiseaseReports.DistinctBy(r => r.ReportID).ToList();
                    }
                    else
                        StateContainer.DiseaseReports =
                            new List<Domain.ViewModels.Veterinary.VeterinaryDiseaseReportViewModel>();
                }

                if (StateContainer.DiseaseReports.Any())
                {
                    RadzenCheckBoxListItem<long> item = new();
                    item.Text = FarmTypes[0].Name;
                    item.Disabled =
                        StateContainer.DiseaseReports.Any(x => x.ReportCategoryTypeID == (long)CaseTypeEnum.Avian);
                    item.Value = FarmTypes[0].IdfsBaseReference;

                    FarmTypeCheckBoxList.AddItem(item);

                    item = new RadzenCheckBoxListItem<long>();
                    item.Text = FarmTypes[1].Name;
                    item.Disabled =
                        StateContainer.DiseaseReports.Any(x => x.ReportCategoryTypeID == (long)CaseTypeEnum.Livestock);
                    item.Value = FarmTypes[1].IdfsBaseReference;
                    FarmTypeCheckBoxList.AddItem(item);

                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    if (FarmTypes is null)
                        await GetFarmTypesAsync();
                    RadzenCheckBoxListItem<long> item = new();
                    item.Text = FarmTypes[0].Name;
                    item.Disabled = false;
                    item.Value = FarmTypes[0].IdfsBaseReference;

                    FarmTypeCheckBoxList.AddItem(item);

                    item = new RadzenCheckBoxListItem<long>();
                    item.Text = FarmTypes[1].Name;
                    item.Disabled = false;
                    item.Value = FarmTypes[1].IdfsBaseReference;
                    FarmTypeCheckBoxList.AddItem(item);
                }
            }
        }

        public void Dispose()
        {
            if (StateContainer != null)
                StateContainer.OnChange -= async _ => await OnStateContainerChangeAsync().ConfigureAwait(false);

            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Data Loading and Events

        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetFarmTypesAsync()
        {
            var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                EIDSSConstants.BaseReferenceConstants.AccessoryList, EIDSSConstants.HACodeList.AllHACode);
            FarmTypes = results.Where(t => t.IdfsBaseReference is EIDSSConstants.HACodeBaseReferenceIds.Livestock
                or EIDSSConstants.HACodeBaseReferenceIds.Avian).ToList();
        }

        /// <summary>
        ///
        /// </summary>
        protected void OnFarmTypeChange()
        {
            if (StateContainer.SelectedFarmTypes != null && StateContainer.SelectedFarmTypes.Any())
            {
                if (StateContainer.SelectedFarmTypes.Contains(EIDSSConstants.HACodeBaseReferenceIds.Avian) &&
                    StateContainer.SelectedFarmTypes.Contains(EIDSSConstants.HACodeBaseReferenceIds.Livestock))
                {
                    // farm is both
                    StateContainer.FarmTypeID = EIDSSConstants.HACodeBaseReferenceIds.All;
                    StateContainer.IsAvianDisabled = false;
                    StateContainer.IsOwnershipDisabled = false;
                }
                else
                {
                    StateContainer.FarmTypeID = StateContainer.SelectedFarmTypes.First();
                    switch (StateContainer.FarmTypeID)
                    {
                        case EIDSSConstants.HACodeBaseReferenceIds.Avian:
                            StateContainer.IsOwnershipDisabled = true;
                            StateContainer.IsAvianDisabled = false;
                            StateContainer.OwnershipStructureTypeID = null;
                            break;

                        case EIDSSConstants.HACodeBaseReferenceIds.Livestock:
                            StateContainer.IsOwnershipDisabled = false;
                            StateContainer.IsAvianDisabled = true;
                            StateContainer.AvianFarmTypeID = null;
                            StateContainer.NumberOfBirdsPerBuilding = null;
                            StateContainer.NumberOfBirdsPerBuilding = null;
                            break;
                    }
                }
            }
            else
            {
                StateContainer.IsAvianDisabled = true;
                StateContainer.IsOwnershipDisabled = true;
            }
        }

        protected async Task OnPersonSearchClicked()
        {
            try
            {
                var result = await DiagService.OpenAsync<SearchPerson>(
                    Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                    new Dictionary<string, object>()
                    {
                        {"Mode", SearchModeEnum.SelectNoRedirect}
                    },
                    new DialogOptions
                    {
                        Width = DialogWidth,
                        AutoFocusFirstElement = false,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                switch (result)
                {
                    case PersonViewModel person:
                        StateContainer.FarmOwner = $"{(person?.LastOrSurname?.Trim())}" +
                                                   $"{(IsNullOrEmpty(person?.FirstOrGivenName?.Trim()) ? Empty : ", ")}" +
                                                   $"{person?.FirstOrGivenName?.Trim()}{person?.SecondName?.Trim()}{(IsNullOrEmpty(person?.PersonalID?.Trim()) ? Empty : " - ")}{person?.PersonalID?.Trim()}";
                        StateContainer.FarmOwnerID = person?.HumanMasterID;
                        StateContainer.FarmOwnerFirstName = person?.FirstOrGivenName?.Trim();
                        StateContainer.FarmOwnerLastName = person?.LastOrSurname?.Trim();

                        if (Mode != SearchModeEnum.SelectNoRedirect)
                        {
                            DiagService.Close();
                        }

                        await InvokeAsync(StateHasChanged);
                        break;

                    case string when result == "Cancelled":
                        break;

                    case string when result == "Add":
                        _source?.Cancel();
                        await AddPerson().ConfigureAwait(false);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        /// <summary>
        /// Loads the Add Person in a dialog and
        /// captures the new person result.
        /// </summary>
        /// <returns></returns>
        protected async Task AddPerson()
        {
            //reset the cancellation token
            var source = new CancellationTokenSource();
            var token = source.Token;

            try
            {
                var result = await DiagService.OpenAsync<PersonSections>(
                    Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                    new Dictionary<string, object>()
                    {
                        { "ShowInDialog", true }
                    },
                    new DialogOptions
                    {
                        Style = EIDSSConstants.LaboratoryModuleCSSClassConstants.AddPersonDialog,
                        AutoFocusFirstElement = true,
                        //MJK - Height is set globally for dialogs
                        //Height = EIDSSConstants.CSSClassConstants.LargeDialogHeight,
                        Width = EIDSSConstants.CSSClassConstants.LargeDialogWidth,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                switch (result)
                {
                    case PersonViewModel person:

                        StateContainer.FarmOwnerID = person.HumanMasterID;
                        StateContainer.FarmOwnerFirstName = person.FirstOrGivenName;
                        StateContainer.FarmOwnerLastName = person.LastOrSurname;
                        StateContainer.FarmOwnerSecondName = person.SecondName;
                        StateContainer.EidssFarmOwnerID = person.EIDSSPersonID;
                        StateContainer.FarmOwner = $"{(person?.LastOrSurname?.Trim())}" +
                                                   $"{(IsNullOrEmpty(person?.FirstOrGivenName?.Trim()) ? Empty : ", ")}" +
                                                   $"{person?.FirstOrGivenName?.Trim()}{person?.SecondName?.Trim()}{(IsNullOrEmpty(person?.PersonalID?.Trim()) ? Empty : " - ")}{person?.PersonalID?.Trim()}";

                        await InvokeAsync(StateHasChanged);
                        break;

                    case string when result == "Cancelled":
                        _source?.Cancel();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
            finally
            {
                source?.Cancel();
                source?.Dispose();
            }
        }

        #endregion

        #region Phone/Fax Text Box Change Event

        /// <summary>
        ///
        /// </summary>
        protected async Task OnPhoneFaxTextBoxChange()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection(bool isReview)
        {
            await InvokeAsync(StateHasChanged);

            StateContainer.FarmInformationSectionValidIndicator = Form.EditContext.Validate();

            StateContainer.IsReview = isReview;

            if (StateContainer.IsReview)
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = true;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel2 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel3 = false;
                StateContainer.FarmLocationModel.EnableApartment = false;
                StateContainer.FarmLocationModel.EnableBuilding = false;
                StateContainer.FarmLocationModel.EnableHouse = false;
                StateContainer.FarmLocationModel.EnablePostalCode = false;
                StateContainer.FarmLocationModel.EnableSettlement = false;
                StateContainer.FarmLocationModel.EnableSettlementType = false;
                StateContainer.FarmLocationModel.EnableStreet = false;
                StateContainer.FarmLocationModel.OperationType = LocationViewOperationType.ReadOnly;
            }
            else
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = false;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = true;
                StateContainer.FarmLocationModel.EnableApartment = true;
                StateContainer.FarmLocationModel.EnableBuilding = true;
                StateContainer.FarmLocationModel.EnableHouse = true;
                StateContainer.FarmLocationModel.EnabledLatitude = true;
                StateContainer.FarmLocationModel.EnabledLongitude = true;
                StateContainer.FarmLocationModel.OperationType = null;
            }

            StateContainer.FarmInformationSectionChangedIndicator = Form.EditContext.IsModified();

            return StateContainer.FarmInformationSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            Form.EditContext?.MarkAsUnmodified();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion
    }
}