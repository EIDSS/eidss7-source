using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Administration.ViewModels.Administration;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.ViewModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Security.UserGroup
{
    public class SearchUsersAndGroupsBase : UsersAndGroupsBaseComponent, IDisposable
    {
        #region Dependency Injection
        [Inject]
        private ILogger<SearchUsersAndGroupsBase> Logger { get; set; }
        [Inject]
        private IUserGroupClient UserGroupClient { get; set; }
        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        #endregion Dependency Injection

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public SearchEmployeeActorViewModel SearchModel { get; set; }

        #endregion Parameters

        #region Protected and Public Fields

        protected RadzenDataGrid<EmployeesForUserGroupViewModel> _grid;
        protected RadzenAccordion _radAccordion;
        protected RadzenTemplateForm<SearchEmployeeActorViewModel> _form;
        protected int count;
        protected bool shouldRender = true;
        protected bool isLoading;
        protected bool showPrintButton;
        protected bool showCancelButton;
        protected bool showClearButton;
        protected bool showSearchButton;
        protected bool showSelectButton;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool expandSearchResults;
        protected bool showCriteria;
        protected bool showResults;
        protected IEnumerable<EmployeesForUserGroupViewModel> SearchResults { get; set; }
        protected SearchEmployeeActorViewModel model;
        public List<BaseReferenceViewModel> types { get; set; }

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool searchSubmitted;
        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion Private Fields and Properties

        #region Lifecycle Methods

        protected override void OnInitialized()
        {
            base.OnInitialized();

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            //reset the cancellation token
            source = new();
            token = source.Token;

            // Wire up laboratory state container service
            UserGroupService.OnChange += StateHasChanged;

            //wire up dialog events
            DiagService.OnClose += DialogClose;

            //initialize model
            InitializeModel();

            //set grid for not loaded
            isLoading = false;

            //set up the accordions
            showCriteria = true;
            expandSearchCriteria = true;
            showResults = false;
            SetButtonStates();
        }

        //protected async override Task OnAfterRenderAsync(bool firstRender)
        //{
        //    if (firstRender)
        //    {
        //        if (model.Permissions.Read)
        //        {
        //            if (UserGroupService.SelectedUsersAndGroups == null)
        //                UserGroupService.SelectedUsersAndGroups = new List<EmployeesForUserGroupViewModel>();
        //        }
        //        else
        //        {
        //            var buttons = new List<DialogButton>();
        //            var okButton = new DialogButton()
        //            {
        //                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
        //                ButtonType = DialogButtonType.OK
        //            };
        //            buttons.Add(okButton);
        //            var dialogParams = new Dictionary<string, object>
        //            {
        //                { nameof(EIDSSDialog.DialogButtons), buttons },
        //                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage) }
        //            };
        //            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
        //        }
        //    }
        //}

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            try
            {
                //source?.Cancel();
                //source?.Dispose();
                //DiagService.OnClose -= DialogClose;
            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion Lifecycle Methods

        #region Protected Methods and Delegates

        protected async Task PrintSearchResults()
        {
            if (_form.IsValid)
            {
                try
                {
                    ReportViewModel reportModel = new();

                    // get lowest administrative level for location
                    long? LocationID = null;
                    //if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                    //    LocationID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    //else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                    //    LocationID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    //else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                    //    LocationID = model.SearchLocationViewModel.AdminLevel1Value.Value;
                    //else
                    //    LocationID = null;

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LanguageID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportSummarySearchHeading)); // "Weekly Reporting List"); 
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                    // optional parameters
                    //reportModel.AddParameter("ReportKey", model.SearchCriteria.PersonalIDType.ToString());
                    //reportModel.AddParameter("ReportID", model.SearchCriteria.PersonalID);
                    //reportModel.AddParameter("LegacyReportID", model.SearchCriteria.FirstOrGivenName);
                    //reportModel.AddParameter("@SessionKey", model.SearchCriteria.SecondName);
                    //reportModel.AddParameter("LastOrSurname", model.SearchCriteria.LastOrSurname);
                    //reportModel.AddParameter("DateOfBirthFrom", model.SearchCriteria.DateOfBirthFrom.ToString());
                    //reportModel.AddParameter("DateOfBirthTo", model.SearchCriteria.DateOfBirthTo.ToString());
                    //reportModel.AddParameter("GenderTypeID", model.SearchCriteria.GenderTypeID.ToString());
                    //reportModel.AddParameter("EIDSSPersonID", model.SearchCriteria.EIDSSPersonID);
                    //reportModel.AddParameter("idfsLocation", LocationID.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForPersonRecord"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px",
                            //Height = "600px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }
        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModel();

            //set grid for not loaded
            isLoading = false;

            //reset the cancellation token
            source = new();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            showCriteria = true;
            expandSearchCriteria = true;
            expandAdvancedSearchCriteria = false;
            expandSearchResults = false;
            showResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearch()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    DiagService.Close(new DialogReturnResult() { ButtonResultText = DialogResultConstants.Yes });
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception)
            {
                throw;
            }
        }
        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:

                    if (expandSearchResults && expandSearchCriteria == false)
                    {
                        expandSearchResults = !expandSearchResults;
                    }
                    expandSearchCriteria = !expandSearchCriteria;
                    break;

                //search results toggle
                case 1:

                    expandSearchResults = !expandSearchResults;
                    break;

                default:
                    break;
            }
            SetButtonStates();
        }

        protected async Task ShowNoSearchCriteriaDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "NoCriteria");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.EnterAtLeastOneParameterMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "NarrowSearch");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString("Search timed out, try narrowing your search criteria."));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }
        protected void DialogClose(dynamic result)
        {
            if (result is DialogReturnResult)
            {
                var dialogResult = result as DialogReturnResult;

                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    ResetSearch();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    source?.Cancel();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    showResults = false;
                    expandSearchResults = false;
                    showCriteria = true;
                    expandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            else
            {
                //DiagService.Close(result);

                source?.Dispose();
            }

            SetButtonStates();
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;

                    var request = new EmployeesForUserGroupGetRequestModel();
                    request.idfEmployeeGroup = model.SearchCriteria.idfEmployeeGroup;
                    request.langId = GetCurrentLanguage();

                    //paging
                    if (args.Skip.HasValue && args.Skip.Value > 0 && model.SearchCriteria.Name == null)
                    {
                        request.pageNo = (args.Skip.Value / _grid.PageSize) + 1;
                    }
                    else
                    {
                        request.pageNo = 1;
                    }
                    request.pageSize = _grid.PageSize != 0 ? _grid.PageSize : 10;
                    //sorting
                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "Name";
                    request.SortOrder = args.Sorts.FirstOrDefault() != null ? SortConstants.Ascending : SortConstants.Descending;
                    request.Type = model.SearchCriteria.Type;
                    request.Name = model.SearchCriteria.Name;
                    request.Organization = model.SearchCriteria.Organization;
                    request.Description = model.SearchCriteria.Description;
                    request.idfsSite = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                    request.user = "Search";

                    var result = await UserGroupClient.GetEmployeesForUserGroupList(request);

                    if (source?.IsCancellationRequested == false)
                    {
                        SearchResults = result;
                        UserGroupService.SearchUsersAndGroups = result;
                        //UserGroupService.SelectedUsersAndGroups = result;
                        count = SearchResults.FirstOrDefault() != null ? SearchResults.First().TotalRowCount : 0;
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (e.HResult == -2146233088 || source?.IsCancellationRequested == true)
                    {
                        await ShowNarrowSearchCriteriaDialog();
                    }
                }
                finally
                {
                    isLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                SearchResults = new List<EmployeesForUserGroupViewModel>();
                count = 0;
                isLoading = false;
            }
        }
        protected async Task HandleValidSearchSubmit(SearchEmployeeActorViewModel model)
        {
            if (_form.IsValid)
            {
                //if (_form.EditContext.IsModified())
                //{
                    searchSubmitted = true;
                    showResults = true;
                    expandSearchResults = true;
                    expandSearchCriteria = false;
                    expandAdvancedSearchCriteria = false;
                    showCriteria = false;
                    SetButtonStates();

                    if (_grid != null)
                    {
                        await _grid.Reload();
                    }
                //}
                //else
                //{
                //    //no search criteria entered - display the EIDSS dialog component
                //    searchSubmitted = false;
                //    //await ShowNoSearchCriteriaDialog();
                //}
            }
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?  
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void OnSelectReports()
        {
            //DiagService.Close(null);
            DiagService.Close(new DialogReturnResult() { ButtonResultText = DialogResultConstants.Select });
        }

        protected async Task GetTypes()
        {
            types = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.EmployeeType, 0).ConfigureAwait(false);
            //timeIntervalCount = timeIntervalUnits.Count();
            //await InvokeAsync(StateHasChanged);
        }

        #endregion Protected Methods and Delegates

        #region Private Methods

        private void SetButtonStates()
        {
            if (expandSearchResults)
            {
                showCancelButton = true;
                showSelectButton = true;
                showClearButton = true;
                showSearchButton = true;
            }
            else
            {
                showCancelButton = true;
                showSelectButton = false;
                showClearButton = true;
                showSearchButton = true;
            }
        }

        private void InitializeModel()
        {
            if (SearchModel != null)
            {
                model = SearchModel;
            }
            else
            {
                model = new SearchEmployeeActorViewModel();
                //if (ReportType == AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport)
                //    model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateDiseaseReports);
                //else
                //    model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateActions);
                //model.RecordSelectionIndicator = true;
                model.SearchCriteria = new();
                model.SearchCriteria.SortColumn = "Name";
                model.SearchCriteria.SortOrder = "ASC";
            }

            if (UserGroupService.UsersAndGroups != null)
            {
                isLoading = true;
                SearchResults = UserGroupService.SearchUsersAndGroups;
                count = SearchResults.FirstOrDefault() != null ? SearchResults.First().TotalRowCount : 0;
                showCriteria = true;
                expandSearchCriteria = true;
                expandSearchResults = true;
                SetButtonStates();
            }
        }

        #endregion Private Methods





    }
}
