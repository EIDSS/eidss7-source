#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class AnimalsSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AnimalsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<AnimalGetListViewModel> AnimalsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private int _databaseQueryCount;
        private int _newRecordCount;
        private int _lastDatabasePage;
        private int _lastPage = 1;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "EIDSSAnimalID";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AnimalsSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AnimalsSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            // get animals for the surveillance
            // session if any
            LoadSurveillanceData();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
        }

        /// <summary>
        ///     Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                IsLoading = true;

                await JsRuntime.InvokeVoidAsync("AnimalsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        #endregion

        #region Surveillance Linked Report

        private void LoadSurveillanceData()
        {
            if (Model.SessionModel == null) return;
            Model.PendingSaveAnimals ??= new List<AnimalGetListViewModel>();
            Model.SessionModel.Animals.ForEach(a =>
            {
                a.AnimalID = (Model.PendingSaveAnimals.Count + 1) * -1;
                a.RowAction = (int) RowActionTypeEnum.Insert;
                a.RowStatus = (int) RowStatusTypeEnum.Active;
                _newRecordCount++;
                Model.PendingSaveAnimals.Add(a);
            });
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadAnimalData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (AnimalsGrid.PageSize != 0)
                    pageSize = AnimalsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.Animals is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        IsLoading = true;

                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        Model.Animals = await GetAnimals(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                            .ConfigureAwait(false);
                        if (page == 1)
                            _databaseQueryCount = !Model.Animals.Any() ? 0 : Model.Animals.First().TotalRowCount;
                    }
                    else if (Model.Animals != null)
                    {
                        _databaseQueryCount = Model.Animals.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.AnimalID < 0)
                            ? 0
                            : Model.Animals.First(x => x.AnimalID > 0).TotalRowCount;
                    }

                    if (Model.Animals != null)
                        for (var index = 0; index < Model.Animals.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.Animals[index].AnimalID < 0)
                            {
                                Model.Animals.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveAnimals == null || index < 0 || Model.Animals.Count == 0 ||
                                Model.PendingSaveAnimals.All(x =>
                                    x.AnimalID != Model.Animals[index].AnimalID)) continue;
                            {
                                if (Model.PendingSaveAnimals.First(x => x.AnimalID == Model.Animals[index].AnimalID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.Animals.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.Animals[index] = Model.PendingSaveAnimals.First(x =>
                                        x.AnimalID == Model.Animals[index].AnimalID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveAnimals != null &&
                            Model.PendingSaveAnimals.Any(x => x.AnimalID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveAnimals.Where(x => x.AnimalID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _lastDatabasePage;
                            var quotientNewRecords = Math.DivRem(Count, pageSize, out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                Model.Animals?.Clear();
                            }
                            else
                            {
                                Model.Animals?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.Animals?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.Animals != null)
                            Model.Animals = Model.Animals.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAnimals(AnimalGetListViewModel record, AnimalGetListViewModel originalRecord)
        {
            Model.PendingSaveAnimals ??= new List<AnimalGetListViewModel>();

            if (Model.PendingSaveAnimals.Any(x => x.AnimalID == record.AnimalID))
            {
                var index = Model.PendingSaveAnimals.IndexOf(originalRecord);
                Model.PendingSaveAnimals[index] = record;
            }
            else
            {
                Model.PendingSaveAnimals.Add(record);
            }
        }

        #endregion

        #region Add Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddAnimalClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<Animal>(
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportAnimalDetailsModalHeading),
                    new Dictionary<string, object> {{"Model", new AnimalGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true, ShowClose = true
                    });

                if (result is AnimalGetListViewModel model)
                {
                    _newRecordCount += 1;

                    TogglePendingSaveAnimals(model, null);

                    await AnimalsGrid.Reload().ConfigureAwait(false);
                }
                else
                {
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="animal"></param>
        protected async Task OnEditAnimalClick(object animal)
        {
            try
            {
                if (((AnimalGetListViewModel) animal).ClinicalSignsIndicator == (long) YesNoUnknownEnum.Yes &&
                    ((AnimalGetListViewModel) animal).ClinicalSignsFlexFormRequest is {idfsFormTemplate: { }})
                {
                    var formTemplateId = ((AnimalGetListViewModel) animal).ClinicalSignsFlexFormRequest
                        .idfsFormTemplate;
                    if (formTemplateId != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((AnimalGetListViewModel) animal).ClinicalSignsObservationParameters,
                            idfsFormTemplate = (long) formTemplateId,
                            idfObservation = ((AnimalGetListViewModel) animal).ClinicalSignsFlexFormRequest
                                .idfObservation,
                            User = ((AnimalGetListViewModel) animal).ClinicalSignsFlexFormRequest.User
                        };
                        var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                        ((AnimalGetListViewModel) animal).ClinicalSignsFlexFormRequest.idfObservation =
                            flexFormResponse.idfObservation;
                        ((AnimalGetListViewModel) animal).ObservationID = flexFormResponse.idfObservation;

                        await InvokeAsync(StateHasChanged);

                        ((AnimalGetListViewModel) animal).ObservationID = flexFormResponse.idfObservation;
                    }
                }

                var result = await DiagService.OpenAsync<Animal>(
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportAnimalDetailsModalHeading),
                    new Dictionary<string, object>
                        {{"Model", ((AnimalGetListViewModel) animal).ShallowCopy()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is AnimalGetListViewModel model)
                {
                    if (Model.Animals.Any(x =>
                            x.AnimalID == ((AnimalGetListViewModel) result).AnimalID))
                    {
                        var index = Model.Animals.IndexOf((AnimalGetListViewModel) animal);
                        Model.Animals[index] = model;

                        TogglePendingSaveAnimals(model, (AnimalGetListViewModel) animal);
                    }

                    await AnimalsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="animal"></param>
        protected async Task OnDeleteAnimalClick(object animal)
        {
            try
            {
                if (CanDeleteAnimalRecord(((AnimalGetListViewModel) animal).AnimalID))
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (Model.Animals.Any(x => x.AnimalID == ((AnimalGetListViewModel) animal).AnimalID))
                            {
                                if (((AnimalGetListViewModel) animal).AnimalID <= 0)
                                {
                                    Model.Animals.Remove((AnimalGetListViewModel) animal);
                                    Model.PendingSaveAnimals.Remove((AnimalGetListViewModel) animal);
                                    _newRecordCount--;
                                }
                                else
                                {
                                    result = ((AnimalGetListViewModel) animal).ShallowCopy();
                                    result.RowAction = (int) RowActionTypeEnum.Delete;
                                    result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    Model.Animals.Remove((AnimalGetListViewModel) animal);

                                    TogglePendingSaveAnimals(result, (AnimalGetListViewModel) animal);
                                }
                            }

                            await AnimalsGrid.Reload().ConfigureAwait(false);

                            DiagService.Close(result);
                        }
                }
                else
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage, null);

                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="animalId"></param>
        /// <returns></returns>
        private bool CanDeleteAnimalRecord(long animalId)
        {
            StateHasChanged();

            return !Model.Samples.Any(x => x.AnimalID == animalId && x.RowStatus == (int) RowStatusTypeEnum.Active);
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            Model.AnimalsSectionValidIndicator = true;

            if (!Model.AnimalsSectionValidIndicator)
                return Model.AnimalsSectionValidIndicator = true;

            foreach (var animal in Model.Animals)
            {
                if (animal.ClinicalSignsIndicator != (long) YesNoUnknownEnum.Yes
                    || animal.ClinicalSignsFlexFormAnswers is null) continue;
                if (animal.ClinicalSignsFlexFormRequest.idfsFormTemplate == null) continue;
                FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                {
                    Answers = animal.ClinicalSignsObservationParameters,
                    idfsFormTemplate = (long) animal.ClinicalSignsFlexFormRequest.idfsFormTemplate,
                    idfObservation = animal.ClinicalSignsFlexFormRequest.idfObservation,
                    User = animal.ClinicalSignsFlexFormRequest.User
                };
                var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                animal.ClinicalSignsFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                animal.ObservationID = flexFormResponse.idfObservation;

                await InvokeAsync(StateHasChanged);

                animal.ObservationID = flexFormResponse.idfObservation;
            }

            return Model.AnimalsSectionValidIndicator = true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            //TODO: change validation once flex form is ready to go.
            Model.AnimalsSectionValidIndicator = true; // Form.EditContext.Validate();

            return Model.AnimalsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.Animals = null;
            AnimalsGrid.Reload();
        }

        #endregion

        #endregion
    }
}