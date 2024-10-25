#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Shared
{
    public class SearchActorBase : SearchComponentBase<SearchActorViewModel>,
        IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SearchActorBase> Logger { get; set; }

        #endregion

        #region Parameters

        #endregion

        #region Private Members

        protected UserPermissions Permissions;
        private readonly string _indicatorKey;
        private readonly string _modelKey;

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<ActorGetListViewModel> Grid;
        protected RadzenTemplateForm<SearchActorViewModel> Form;
        protected SearchActorViewModel Model;
        protected IList<BaseReferenceViewModel> ActorTypes;
        public IList<ActorGetListViewModel> SelectedActors { get; set; } = new List<ActorGetListViewModel>();

        private bool _isSelected;
        public bool IsSelected
        {
            get
            {
                _isSelected = false;
                if (Model.SearchResults != null)
                    _isSelected = Model.SearchResults.Any(i => SelectedActors != null && SelectedActors.Contains(i));

                return _isSelected;
            }
        }

        public bool AllowSelectionIndicator { get; set; }

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            var indicatorResult = await BrowserStorage.GetAsync<bool>(_indicatorKey);
            var searchPerformedIndicator = indicatorResult.Success && indicatorResult.Value;
            if (searchPerformedIndicator)
            {
                var searchModelResult =
                    await BrowserStorage.GetAsync<SearchActorViewModel>(_modelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;
                    if (Model.SearchResults != null)
                        count = Model.SearchResults.Count;

                    // set up the accordions
                    expandSearchCriteria = false;
                    showSearchCriteriaButtons = false;
                    showSearchResults = true;

                    isLoading = false;
                }
            }
            else
            {
                // set grid for not loading
                isLoading = false;

                // set up the accordions
                expandSearchCriteria = true;
                showSearchCriteriaButtons = true;
                showSearchResults = false;
            }

            SetButtonStates();

            await base.OnInitializedAsync();
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }

        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:
                    expandSearchCriteria = !expandSearchCriteria;
                    break;
            }

            SetButtonStates();
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                //search timed out, narrow search criteria
                source?.Cancel();
                source = new CancellationTokenSource();
                token = source.Token;
                expandSearchCriteria = true;
                SetButtonStates();
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new ActorGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseFiltrationSearchIndicator = true,
                    ActorTypeID = Model.SearchCriteria.ActorTypeID == null
                        ? null
                        : Convert.ToInt64(Model.SearchCriteria.ActorTypeID),
                    ActorName = Model.SearchCriteria.ActorName == ""
                        ? null
                        : Model.SearchCriteria.ActorName,
                    OrganizationName = Model.SearchCriteria.OrganizationName == ""
                        ? null
                        : Model.SearchCriteria.OrganizationName,
                    UserGroupDescription =
                        Model.SearchCriteria.UserGroupDescription == ""
                            ? null
                            : Model.SearchCriteria.UserGroupDescription,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    //sorting
                    SortColumn = !IsNullOrEmpty(args.OrderBy)
                        ? args.Sorts.FirstOrDefault()?.Property
                        : "ActorName",
                    SortOrder = args.Sorts.FirstOrDefault() != null
                        ? args.Sorts.FirstOrDefault()?.SortOrder.ToString() == "Ascending" ? SortConstants.Ascending : SortConstants.Descending
                        : SortConstants.Descending
                };

                //paging
                if (args.Skip is > 0)
                    request.Page = args.Skip.Value / Grid.PageSize + 1;
                else
                    request.Page = 1;
                request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                var result = await CrossCuttingClient.GetActorList(request);
                if (source.IsCancellationRequested == false)
                {
                    Model.SearchResults = result;
                    count = Model.SearchResults.FirstOrDefault() != null
                        ? Model.SearchResults.First().RecordCount
                        : 0;
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch timeout exception
                if (e.Message.Contains("Timeout"))
                {
                    if (source?.IsCancellationRequested == false) source?.Cancel();
                    await ShowNarrowSearchCriteriaDialog();
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
        }

        protected async Task HandleValidSearchSubmit(SearchActorViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                searchSubmitted = true;
                expandSearchCriteria = false;
                SetButtonStates();

                if (Grid != null) await Grid.Reload();
            }
            else
            {
                //no search criteria entered
                searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        protected async Task CancelSearchClicked()
        {
            await CancelSearchAsync();
        }

        protected void ResetSearch()
        {
            //initialize new model
            InitializeModel();

            //set grid for not loaded
            isLoading = false;

            //reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            expandSearchCriteria = true;
            showSearchResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearch()
        {
            var buttons = new List<DialogButton>();
            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);
            buttons.Add(noButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)}
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                //cancel search and user said yes
                source?.Cancel();
                shouldRender = false;
                var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                //cancel search but user said no so leave everything alone and cancel thread
                source?.Cancel();
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Model.SearchResults is null)
                    return false;

                if (SelectedActors is {Count: > 0})
                    if (Model.SearchResults.Any(item => SelectedActors.Any(x => x.ActorID == item.ActorID)))
                        return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnHeaderRecordSelectionChange(bool? value)
        {
            try
            {
                if (value == false)
                    foreach (var item in Model.SearchResults)
                    {
                        if (SelectedActors.All(x => x.ActorID != item.ActorID)) continue;
                        {
                            var selected = SelectedActors.First(x => x.ActorID == item.ActorID);

                            SelectedActors.Remove(selected);
                        }
                    }
                else
                    foreach (var item in Model.SearchResults)
                        SelectedActors.Add(item);

                AllowSelectionIndicator = SelectedActors.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(ActorGetListViewModel item)
        {
            try
            {
                if (SelectedActors != null && SelectedActors.Any(x => x.ActorID == item.ActorID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected void OnRecordSelectionChange(bool? value, ActorGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedActors.First(x => x.ActorID == item.ActorID);

                    SelectedActors.Remove(item);
                }
                else
                {
                    SelectedActors.Add(item);
                }

                AllowSelectionIndicator = SelectedActors.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task GetActorTypes()
        {
            try
            {
                ActorTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.EmployeeType, (int)AccessoryCodes.NoneHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;
        }

        private void InitializeModel()
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            Mode = SearchModeEnum.Select;

            Model = new SearchActorViewModel
            {
                SearchCriteria = new ActorGetRequestModel
                {
                    //model.Permissions = _permissions;
                    SortColumn = "ActorName",
                    SortOrder = SortConstants.Descending
                }
            };
        }

        private static bool HasCriteria(SearchActorViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties()
                .Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
                if (prop.GetValue(model.SearchCriteria) != null)
                {
                    if (prop.PropertyType == typeof(string))
                    {
                        var value = prop.GetValue(model.SearchCriteria)?.ToString()?.Trim();
                        if (!IsNullOrWhiteSpace(value)) return true;
                        if (!IsNullOrEmpty(value)) return true;
                    }
                    else
                    {
                        return true;
                    }
                }

            return false;
        }

        #endregion

        #region Submit Click Event

        /// <summary>
        /// </summary>
        /// <param name="selectAllIndicator"></param>
        protected void OnSubmit(bool selectAllIndicator)
        {
            try
            {
                if (selectAllIndicator)
                {
                    if (Model.SearchResults is not null)
                        DiagService.Close(Model.SearchResults);
                }
                else
                    DiagService.Close(SelectedActors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}