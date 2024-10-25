#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
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
using static System.GC;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case
{
    /// <summary>
    /// </summary>
    public class CaseMonitoringSectionBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseMonitoringSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Model { get; set; }
        [Parameter] public DiseaseReportGetDetailViewModel VeterinaryDiseaseReport { get; set; }
        [Parameter] public long? DiseaseReportId { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public bool IsHumanCase { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<CaseMonitoringGetListViewModel> CaseMonitoringGrid { get; set; }
        public FlexForm.FlexForm CaseMonitoring { get; set; }
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

        private const string DefaultSortColumn = "MonitoringDate";

        #endregion

        #endregion

        #region Constructors

        public CaseMonitoringSectionBase(CancellationToken token) : base(token)
        {
        }

        protected CaseMonitoringSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (IsHumanCase)
            {
                JsRuntime?.InvokeAsync<string>("SetCaseMonitoringData", Model.CaseMonitorings);
            }

            await base.OnInitializedAsync();
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
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
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
                if (!IsHumanCase)
                    await JsRuntime.InvokeVoidAsync("CaseMonitoringSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this));
                else
                {
                    //await InvokeAsync(() =>
                    //{
                    //    _ = LoadCaseMonitoringData(new LoadDataArgs() { Top = 1, Skip = 10 });
                    //    StateHasChanged();
                    //});

                    //StateHasChanged();
                    await LoadCaseMonitoringData(new LoadDataArgs() { Top = 10, Skip = 0 });
                    StateHasChanged();
                    IsLoading = false;
                }
            }
            //else
            //{
            //    if (IsHumanCase && IsLoading)
            //    {
            //        await LoadCaseMonitoringData(new LoadDataArgs() { Top = 10, Skip = 0 });
            //        StateHasChanged();
            //        IsLoading = false;
            //    }
            //}
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadCaseMonitoringData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (CaseMonitoringGrid.PageSize != 0)
                    pageSize = CaseMonitoringGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (Model.CaseMonitorings is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        if (DiseaseReportId is null)
                            Model.CaseMonitorings = new List<CaseMonitoringGetListViewModel>();
                        else
                            Model.CaseMonitorings =
                                await GetCaseMonitorings((long)DiseaseReportId, page, pageSize,
                                        sortColumn, sortOrder)
                                    .ConfigureAwait(false);

                        if (Model.CaseMonitorings != null)
                            _databaseQueryCount = Model.CaseMonitorings != null && !Model.CaseMonitorings.Any()
                                ? 0
                                : Model.CaseMonitorings.First().TotalRowCount;
                    }
                    else if (Model.CaseMonitorings != null)
                    {
                        _databaseQueryCount = Model.CaseMonitorings.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.CaseMonitoringId < 0)
                            ? 0
                            : Model.CaseMonitorings.First(x => x.CaseMonitoringId > 0).TotalRowCount;
                    }

                    if (Model.CaseMonitorings != null)
                        for (var index = 0; index < Model.CaseMonitorings.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.CaseMonitorings[index].CaseMonitoringId < 0)
                            {
                                Model.CaseMonitorings.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveCaseMonitorings == null || index < 0 ||
                                Model.CaseMonitorings.Count == 0 ||
                                Model.PendingSaveCaseMonitorings.All(x =>
                                    x.CaseMonitoringId != Model.CaseMonitorings[index].CaseMonitoringId)) continue;
                            {
                                if (Model.PendingSaveCaseMonitorings
                                        .First(x => x.CaseMonitoringId == Model.CaseMonitorings[index].CaseMonitoringId)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    Model.CaseMonitorings.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.CaseMonitorings[index] = Model.PendingSaveCaseMonitorings.First(x =>
                                        x.CaseMonitoringId == Model.CaseMonitorings[index].CaseMonitoringId);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveCaseMonitorings != null &&
                            Model.PendingSaveCaseMonitorings.Any(x => x.CaseMonitoringId < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveCaseMonitorings.Where(x => x.CaseMonitoringId < 0).ToList();
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
                                pageSize = remainderNewRecords;
                                Model.CaseMonitorings?.Clear();
                            }
                            else
                            {
                                Model.CaseMonitorings?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.CaseMonitorings?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.CaseMonitorings != null)
                            Model.CaseMonitorings = Model.CaseMonitorings.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

                foreach (var caseMonitoring in Model.CaseMonitorings)
                {
                    FlexFormQuestionnaireGetRequestModel caseMonitoringFlexFormRequest = new()
                    {
                        idfsDiagnosis = Model.DiseaseId,
                        LangID = GetCurrentLanguage(),
                        idfObservation = caseMonitoring.ObservationId
                    };

                    if (IsHumanCase)
                    {
                        caseMonitoringFlexFormRequest.idfsFormType = (long)FlexibleFormTypeEnum.HumanOutbreakCaseMonitoring;
                        caseMonitoringFlexFormRequest.idfsFormTemplate = Model.Session.HumanCaseMonitoringTemplateID;
                    }
                    else
                    {
                        switch (VeterinaryDiseaseReport.ReportCategoryTypeID)
                        {
                            case 0:
                                continue;
                            case (long)CaseTypeEnum.Avian:
                                caseMonitoringFlexFormRequest.idfsFormType = (long)FlexibleFormTypeEnum.AvianOutbreakCaseMonitoring;
                                caseMonitoringFlexFormRequest.idfsFormTemplate = Model.Session.AvianCaseMonitoringTemplateID;
                                break;
                            default:
                                caseMonitoringFlexFormRequest.idfsFormType = (long)FlexibleFormTypeEnum.LivestockOutbreakCaseMonitoring;
                                caseMonitoringFlexFormRequest.idfsFormTemplate = Model.Session.LivestockCaseMonitoringTemplateID;
                                break;
                        }
                    }
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
        protected void TogglePendingSaveCaseMonitorings(CaseMonitoringGetListViewModel record,
            CaseMonitoringGetListViewModel originalRecord)
        {
            Model.PendingSaveCaseMonitorings ??= new List<CaseMonitoringGetListViewModel>();

            if (Model.PendingSaveCaseMonitorings.Any(x => x.CaseMonitoringId == record.CaseMonitoringId))
            {
                var index = Model.PendingSaveCaseMonitorings.IndexOf(originalRecord);
                Model.PendingSaveCaseMonitorings[index] = record;
            }
            else
            {
                Model.PendingSaveCaseMonitorings.Add(record);
            }
        }

        #endregion

        #region Add Case Monitoring Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddCaseMonitoringClick()
        {
            try
            {
                FlexFormQuestionnaireGetRequestModel caseMonitoringFlexFormRequest = new()
                {
                    idfsDiagnosis = Model.DiseaseId,
                    LangID = GetCurrentLanguage()
                };

                if (IsHumanCase)
                {
                    caseMonitoringFlexFormRequest.idfsFormType =
                        (long)FlexibleFormTypeEnum.HumanOutbreakCaseMonitoring;
                    caseMonitoringFlexFormRequest.idfsFormTemplate = Model.Session.HumanCaseMonitoringTemplateID;
                }
                else
                {
                    if (VeterinaryDiseaseReport.ReportCategoryTypeID != 0)
                    {
                        if (VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                        {
                            caseMonitoringFlexFormRequest.idfsFormType =
                                (long)FlexibleFormTypeEnum.AvianOutbreakCaseMonitoring;
                            caseMonitoringFlexFormRequest.idfsFormTemplate =
                                Model.Session.AvianCaseMonitoringTemplateID;
                        }
                        else
                        {
                            caseMonitoringFlexFormRequest.idfsFormType =
                                (long)FlexibleFormTypeEnum.LivestockOutbreakCaseMonitoring;
                            caseMonitoringFlexFormRequest.idfsFormTemplate =
                                Model.Session.LivestockCaseMonitoringTemplateID;
                        }
                    }
                }

                var result = await DiagService.OpenAsync<CaseMonitoring>(
                    Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseCaseMonitoringHeading),
                    new Dictionary<string, object>
                    {
                        {
                            "Model",
                            new CaseMonitoringGetListViewModel
                            {
                                MonitoringDate = DateTime.Now,
                                CaseMonitoringFlexFormRequest = caseMonitoringFlexFormRequest,
                                InvestigatedByOrganizationId = authenticatedUser.OfficeId,
                                InvestigatedByPersonId = Convert.ToInt64(authenticatedUser.PersonId)
                            }
                        },
                        {"Case", Model},
                        {"DiseaseReportId", DiseaseReportId}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is CaseMonitoringGetListViewModel model)
                {
                    _newRecordCount += 1;

                    Model.CaseMonitorings.Add(model);

                    TogglePendingSaveCaseMonitorings(model, null);

                    if (IsHumanCase)
                    {
                        JsRuntime.InvokeAsync<string>("SetCaseMonitoringData", Model.CaseMonitorings);
                    }
                    await CaseMonitoringGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Case Monitoring Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="caseMonitoring"></param>
        protected async Task OnEditCaseMonitoringClick(object caseMonitoring)
        {
            try
            {
                if (((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest is { idfsFormTemplate: { } })
                {
                    var formTemplateId = ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest
                        .idfsFormTemplate;
                    if (formTemplateId != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringObservationParameters,
                            idfsFormTemplate = (long)formTemplateId,
                            idfObservation = ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest.idfObservation,
                            User = ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest.User
                        };

                        if (flexFormRequest.idfsFormTemplate != 0 && flexFormRequest.idfsFormTemplate != null)
                        {
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest.idfObservation =
                                flexFormResponse.idfObservation;
                            ((CaseMonitoringGetListViewModel)caseMonitoring).ObservationId = flexFormResponse.idfObservation;

                            await InvokeAsync(StateHasChanged);

                            ((CaseMonitoringGetListViewModel)caseMonitoring).ObservationId = flexFormResponse.idfObservation;
                        }
                    }
                }

                var result = await DiagService.OpenAsync<CaseMonitoring>(
                    Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseCaseMonitoringHeading),
                    new Dictionary<string, object>
                    {
                        {"Model", ((CaseMonitoringGetListViewModel) caseMonitoring).ShallowCopy()},
                        {"Case", Model},
                        {"DiseaseReportId", DiseaseReportId}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is CaseMonitoringGetListViewModel model)
                {
                    if (Model.CaseMonitorings.Any(x =>
                            x.CaseMonitoringId == ((CaseMonitoringGetListViewModel)result).CaseMonitoringId))
                    {
                        var index = Model.CaseMonitorings.IndexOf((CaseMonitoringGetListViewModel)caseMonitoring);
                        Model.CaseMonitorings[index] = model;

                        TogglePendingSaveCaseMonitorings(model, (CaseMonitoringGetListViewModel)caseMonitoring);
                    }

                    if (IsHumanCase)
                    {
                        JsRuntime.InvokeAsync<string>("SetCaseMonitoringData", Model.CaseMonitorings);
                    }

                    await CaseMonitoringGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Case Monitoring Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="caseMonitoring"></param>
        protected async Task OnDeleteCaseMonitoringClick(object caseMonitoring)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.CaseMonitorings.Any(x =>
                                x.CaseMonitoringId ==
                                ((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringId))
                        {
                            if (((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringId <= 0)
                            {
                                Model.CaseMonitorings.Remove((CaseMonitoringGetListViewModel)caseMonitoring);
                                Model.PendingSaveCaseMonitorings.Remove(
                                    (CaseMonitoringGetListViewModel)caseMonitoring);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((CaseMonitoringGetListViewModel)caseMonitoring).ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                Model.CaseMonitorings.Remove((CaseMonitoringGetListViewModel)caseMonitoring);
                                Count--;

                                TogglePendingSaveCaseMonitorings(result,
                                    (CaseMonitoringGetListViewModel)caseMonitoring);
                            }
                        }

                        if (IsHumanCase)
                        {
                            JsRuntime.InvokeAsync<string>("SetCaseMonitoringData", Model.PendingSaveCaseMonitorings);
                        }

                        await CaseMonitoringGrid.Reload().ConfigureAwait(false);

                        DiagService.Close(result);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            try
            {
                Model.CaseMonitoringSectionValidIndicator = true;

                if (!Model.CaseMonitoringSectionValidIndicator)
                    return Model.CaseMonitoringSectionValidIndicator = true;

                foreach (var caseMonitoring in Model.CaseMonitorings)
                {
                    if (caseMonitoring.CaseMonitoringFlexFormRequest?.idfsFormTemplate is null) continue;
                    FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                    {
                        Answers = caseMonitoring.CaseMonitoringObservationParameters,
                        idfsFormTemplate = (long)caseMonitoring.CaseMonitoringFlexFormRequest.idfsFormTemplate,
                        idfObservation = caseMonitoring.CaseMonitoringFlexFormRequest.idfObservation,
                        User = caseMonitoring.CaseMonitoringFlexFormRequest.User
                    };

                    if (flexFormRequest.idfsFormTemplate != 0 && flexFormRequest.idfsFormTemplate != null)
                    {
                        var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                        caseMonitoring.CaseMonitoringFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                        caseMonitoring.ObservationId = flexFormResponse.idfObservation;

                        await InvokeAsync(StateHasChanged);

                        caseMonitoring.ObservationId = flexFormResponse.idfObservation;
                    }
                }

                return Model.CaseMonitoringSectionValidIndicator = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(() =>
            {
                StateHasChanged();
                Model.CaseMonitorings = null;
                CaseMonitoringGrid.Reload();
            });
        }

        #endregion

        #endregion
    }
}