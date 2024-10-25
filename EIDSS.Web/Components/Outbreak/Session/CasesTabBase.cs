#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Human.SearchDiseaseReport;
using EIDSS.Web.Components.Outbreak.Case;
using EIDSS.Web.Components.Veterinary.SearchDiseaseReport;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;
using EIDSS.Web.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.Components.CrossCutting;

#endregion

namespace EIDSS.Web.Components.Outbreak.Session
{
    public class CasesTabBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CasesTabBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long OutbreakId { get; set; }
        [Parameter] public OutbreakTypeEnum CaseType { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public bool IsCaseMonitoringsLoading { get; set; }
        public IList<CaseGetListViewModel> Cases { get; set; }
        public IList<CaseGetListViewModel> SelectedCases { get; set; }
        protected List<CaseGetListViewModel> PendingSaveCases { get; set; }
        public long SelectedClassificationTypeId { get; set; }
        public long SelectedStatusTypeId { get; set; }
        protected List<CaseMonitoringGetListViewModel> CaseMonitorings { get; set; }
        protected List<CaseMonitoringGetListViewModel> PendingSaveCaseMonitorings { get; set; }
        public bool WritePermissionIndicator { get; set; }
        protected RadzenDataGrid<CaseGetListViewModel> CasesGrid { get; set; }
        protected RadzenDataGrid<CaseMonitoringGetListViewModel> CaseMonitoringsGrid { get; set; }
        public CaseGetDetailViewModel Case { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }
        public string SearchTerm { get; set; }
        public bool TodaysFollowupsIndicator { get; set; }
        public bool SaveDisabledIndicator { get; set; }
        public IEnumerable<BaseReferenceViewModel> CaseStatusTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ClassificationTypes { get; set; }
        protected bool IsCreateDisabled { get; set; } = true;
        protected bool IsImportDisabled { get; set; } = true;
        private long? OriginalPrimaryCaseIdentifier { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private int _databaseQueryCount;
        private int _lastPage = 1;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "EIDSSCaseID";

        #endregion

        #endregion

        #region Constructors

        public CasesTabBase(CancellationToken token) : base(token)
        {
        }

        protected CasesTabBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _userPermissions = CaseType switch
            {
                OutbreakTypeEnum.Human => GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData),
                OutbreakTypeEnum.Veterinary => GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData),
                _ => GetUserPermissions(PagePermission.AccessToOutbreakVectorData)
            };

            WritePermissionIndicator = _userPermissions.Write;

            SelectedCases = new List<CaseGetListViewModel>();

            await DetermineDisabledObjects(OutbreakId, CaseType);

            IsCreateDisabled = CreateDisabled || !_userPermissions.Create;
            IsImportDisabled = ImportDisabled;

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
                await JsRuntime.InvokeVoidAsync("CasesTab.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));

                IsLoading = true;
                SaveDisabledIndicator = true;

                CaseStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakCaseStatus, HACodeList.NoneHACode);

                ClassificationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseClassification, HACodeList.NoneHACode);

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadCaseData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (CasesGrid.PageSize != 0)
                    pageSize = CasesGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (Cases is null ||
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

                        Cases = await GetCases(OutbreakId, SearchTerm, TodaysFollowupsIndicator, page, pageSize,
                                sortColumn, sortOrder)
                            .ConfigureAwait(false);
                        _databaseQueryCount = !Cases.Any() ? 0 : Cases.First().RowCount;
                    }
                    else if (Cases != null)
                    {
                        _databaseQueryCount = Cases.Count;
                    }

                    Count = _databaseQueryCount;

                    _lastPage = page;
                }

                if (Cases != null && Cases.Any(x => x.PrimaryCaseIndicator == 1))
                    OriginalPrimaryCaseIdentifier = Cases.First(x => x.PrimaryCaseIndicator == 1).CaseID;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsLoading = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Cases is null)
                    return false;

                if (SelectedCases is {Count: > 0})
                    if (Cases.Any(item => SelectedCases.Any(x => x.CaseID == item.CaseID)))
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
        protected void HeaderRecordSelectionChange(bool? value)
        {
            try
            {
                if (value == false)
                    foreach (var item in Cases)
                    {
                        if (SelectedCases.All(x => x.CaseID != item.CaseID)) continue;
                        {
                            var selected = SelectedCases.First(x => x.CaseID == item.CaseID);

                            SelectedCases.Remove(selected);
                        }
                    }
                else
                    foreach (var item in Cases)
                        SelectedCases.Add(item);
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
        protected bool IsRecordSelected(CaseGetListViewModel item)
        {
            try
            {
                if (SelectedCases is not null && SelectedCases.Any(x => x.CaseID == item.CaseID))
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
        protected void RecordSelectionChange(bool? value, CaseGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedCases.First(x => x.CaseID == item.CaseID);

                    SelectedCases.Remove(item);
                }
                else
                {
                    SelectedCases.Add(item);
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
        /// <param name="record"></param>
        protected void OnRowRender(RowRenderEventArgs<CaseGetListViewModel> record)
        {
            try
            {
                var cssClass = Empty;

                if (record.Data.PrimaryCaseIndicator == 1)
                    cssClass += OutbreakModuleCSSClassConstants.PrimaryCaseIndicator;

                if (record.Data.RowAction is (int)RowActionTypeEnum.Insert or (int)RowActionTypeEnum.Update)
                    cssClass += " " + record.Data.RowAction switch
                    {
                        (int)RowActionTypeEnum.Update => LaboratoryModuleCSSClassConstants.SavePending,
                        _ => LaboratoryModuleCSSClassConstants.NoSavePending
                    };

                record.Attributes.Add("class", cssClass);
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
        protected void OnCaseMonitoringRowRender(RowRenderEventArgs<CaseMonitoringGetListViewModel> record)
        {
            try
            {
                var cssClass = Empty;

                record.Attributes.Add("class", cssClass);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="outbreakCase"></param>
        /// <returns></returns>
        public async Task OnCasesRowExpand(CaseGetListViewModel outbreakCase)
        {
            try
            {
                IsCaseMonitoringsLoading = true;
                await GetCaseMonitoringsByCaseId(outbreakCase);
                
                var caseDetail = await OutbreakClient
                    .GetCaseDetail(GetCurrentLanguage(), outbreakCase.CaseID, _token)
                    .ConfigureAwait(false);
                Case = caseDetail.First();

                if (Case.OutbreakId != null)
                {
                    dynamic request = new OutbreakSessionDetailRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        idfsOutbreak = (long) Case.OutbreakId
                    };
                    List<OutbreakSessionDetailsResponseModel> session = OutbreakClient.GetSessionDetail(request).Result;

                    var sessionSpeciesParameters = OutbreakClient.GetSessionParametersList(request).Result;
                    foreach (var parameter in sessionSpeciesParameters)
                        switch (parameter.OutbreakSpeciesTypeID)
                        {
                            case (long) OutbreakSpeciesTypeEnum.Avian:
                                session.First().AvianCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().AvianCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().AvianContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long) OutbreakSpeciesTypeEnum.Human:
                                session.First().HumanCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().HumanCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().HumanContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long) OutbreakSpeciesTypeEnum.Livestock:
                                session.First().LivestockCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().LivestockCaseQuestionaireTemplateID =
                                    parameter.CaseQuestionaireTemplateID;
                                session.First().LivestockContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                        }

                    Case.Session = session.First();
                }

                IsCaseMonitoringsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="outbreakCase"></param>
        /// <returns></returns>
        private async Task GetCaseMonitoringsByCaseId(CaseGetListViewModel outbreakCase)
        {
            if (outbreakCase.HumanDiseaseReportID is not null || outbreakCase.VeterinaryDiseaseReportID is not null)
            {
                var diseaseReportId =
                    outbreakCase.HumanDiseaseReportID ?? (long) outbreakCase.VeterinaryDiseaseReportID;
                CaseMonitorings =
                    await GetCaseMonitorings(diseaseReportId, 1, MaxValue - 1,
                            "MonitoringDate", SortConstants.Ascending)
                        .ConfigureAwait(false);

                for (var index = 0; index < CaseMonitorings.Count; index++)
                    if (PendingSaveCaseMonitorings != null &&
                        PendingSaveCaseMonitorings.Any(x =>
                            x.CaseMonitoringId == CaseMonitorings[index].CaseMonitoringId))
                        CaseMonitorings[index] =
                            PendingSaveCaseMonitorings.First(x =>
                                x.CaseMonitoringId == CaseMonitorings[index].CaseMonitoringId);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveCases(CaseGetListViewModel record,
            CaseGetListViewModel originalRecord)
        {
            PendingSaveCases ??= new List<CaseGetListViewModel>();

            if (PendingSaveCases.Any(x => x.CaseID == record.CaseID))
            {
                var index = PendingSaveCases.IndexOf(originalRecord);
                PendingSaveCases[index] = record;
            }
            else
            {
                PendingSaveCases.Add(record);
            }

            SaveDisabledIndicator = false;
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveCaseMonitorings(CaseMonitoringGetListViewModel record,
            CaseMonitoringGetListViewModel originalRecord)
        {
            PendingSaveCaseMonitorings ??= new List<CaseMonitoringGetListViewModel>();

            if (PendingSaveCaseMonitorings.Any(x => x.CaseMonitoringId == record.CaseMonitoringId))
            {
                var index = PendingSaveCaseMonitorings.IndexOf(originalRecord);
                PendingSaveCaseMonitorings[index] = record;
            }
            else
            {
                PendingSaveCaseMonitorings.Add(record);
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
                if (Case is not null)
                    Case.CaseMonitorings = CaseMonitorings;

                FlexFormQuestionnaireGetRequestModel caseMonitoringFlexFormRequest = new()
                {
                    idfsDiagnosis = Case?.DiseaseId,
                    LangID = GetCurrentLanguage()
                };

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
                        {"Case", Case},
                        {"DiseaseReportId", Case.HumanDiseaseReportId ?? Case.VeterinaryDiseaseReportId}
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
                    CaseMonitorings.Add(model);

                    Cases.First(x => x.CaseID == Case.CaseId).RowAction = (int) RowActionTypeEnum.Update;

                    TogglePendingSaveCases(Cases.First(x => x.CaseID == Case.CaseId), Cases.First(x => x.CaseID == Case.CaseId));
                    TogglePendingSaveCaseMonitorings(model, null);

                    await CasesGrid.Reload();
                    await CaseMonitoringsGrid.Reload();
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
                if (((CaseMonitoringGetListViewModel)caseMonitoring).CaseMonitoringFlexFormRequest is {idfsFormTemplate: { }})
                {
                    var formTemplateId = ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringFlexFormRequest
                        .idfsFormTemplate;
                    if (formTemplateId != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringObservationParameters,
                            idfsFormTemplate = (long) formTemplateId,
                            idfObservation = ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringFlexFormRequest.idfObservation,
                            User = ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringFlexFormRequest.User
                        };
                        var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                        ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringFlexFormRequest.idfObservation =
                            flexFormResponse.idfObservation;
                        ((CaseMonitoringGetListViewModel) caseMonitoring).ObservationId = flexFormResponse.idfObservation;

                        await InvokeAsync(StateHasChanged);

                        ((CaseMonitoringGetListViewModel) caseMonitoring).ObservationId = flexFormResponse.idfObservation;
                    }
                }

                var result = await DiagService.OpenAsync<CaseMonitoring>(
                    Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseCaseMonitoringHeading),
                    new Dictionary<string, object>
                    {
                        {"Model", ((CaseMonitoringGetListViewModel) caseMonitoring).ShallowCopy()},
                        {"Case", Case},
                        {"DiseaseReportId", Case.HumanDiseaseReportId ?? Case.VeterinaryDiseaseReportId}
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
                    if (CaseMonitorings.Any(x =>
                            x.CaseMonitoringId == ((CaseMonitoringGetListViewModel) result).CaseMonitoringId))
                    {
                        var index = CaseMonitorings.IndexOf((CaseMonitoringGetListViewModel) caseMonitoring);
                        CaseMonitorings[index] = model;

                        Cases.First(x => x.CaseID == Case.CaseId).RowAction = (int) RowActionTypeEnum.Update;

                        TogglePendingSaveCases(Cases.First(x => x.CaseID == Case.CaseId), Cases.First(x => x.CaseID == Case.CaseId));
                        TogglePendingSaveCaseMonitorings(model, (CaseMonitoringGetListViewModel) caseMonitoring);
                    }

                    await CasesGrid.Reload();
                    await CaseMonitoringsGrid.Reload();
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
                        if (CaseMonitorings.Any(x =>
                                x.CaseMonitoringId ==
                                ((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringId))
                        {
                            if (((CaseMonitoringGetListViewModel) caseMonitoring).CaseMonitoringId <= 0)
                            {
                                CaseMonitorings.Remove((CaseMonitoringGetListViewModel) caseMonitoring);
                                PendingSaveCaseMonitorings.Remove(
                                    (CaseMonitoringGetListViewModel) caseMonitoring);
                            }
                            else
                            {
                                result = ((CaseMonitoringGetListViewModel) caseMonitoring).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                CaseMonitorings.Remove((CaseMonitoringGetListViewModel) caseMonitoring);
                                Count--;

                                TogglePendingSaveCaseMonitorings(result,
                                    (CaseMonitoringGetListViewModel) caseMonitoring);
                            }
                        }

                        await CaseMonitoringsGrid.Reload().ConfigureAwait(false);

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

        #region Case Status Type Click Event

        /// <summary>
        /// </summary>
        /// <param name="statusTypeId"></param>
        /// <returns></returns>
        public async Task OnCaseStatusTypeClick(long statusTypeId)
        {
            try
            {
                var caseIdentifiers = "";
                foreach (var outbreakCase in SelectedCases)
                {
                    if (!IsNullOrEmpty(caseIdentifiers))
                        caseIdentifiers += ",";
                    caseIdentifiers += outbreakCase.CaseID;

                    TogglePendingSaveCases(outbreakCase, outbreakCase);
                }

                SelectedStatusTypeId = statusTypeId;
                SelectedCases = new List<CaseGetListViewModel>();
                await CasesGrid.Reload();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Case Classification Type Click Event

        /// <summary>
        /// </summary>
        /// <param name="classificationTypeId"></param>
        /// <returns></returns>
        public async Task OnCaseClassificationTypeClick(long classificationTypeId)
        {
            try
            {
                var caseIdentifiers = "";
                foreach (var outbreakCase in SelectedCases)
                {
                    if (!IsNullOrEmpty(caseIdentifiers))
                        caseIdentifiers += ",";
                    caseIdentifiers += outbreakCase.CaseID;

                    TogglePendingSaveCases(outbreakCase, outbreakCase);
                }

                SelectedClassificationTypeId = classificationTypeId;
                SelectedCases = new List<CaseGetListViewModel>();
                await CasesGrid.Reload();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Save Cases Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSaveCasesButtonClick()
        {
            try
            {
                var caseIdentifiers = "";
                foreach (var outbreakCase in SelectedCases)
                {
                    if (!IsNullOrEmpty(caseIdentifiers))
                        caseIdentifiers += ",";
                    caseIdentifiers += outbreakCase.CaseID;
                }

                PendingSaveCaseMonitorings ??= new List<CaseMonitoringGetListViewModel>();
                foreach (var caseMonitoring in PendingSaveCaseMonitorings)
                {
                    if (caseMonitoring.CaseMonitoringFlexFormRequest?.idfsFormTemplate is null) continue;
                    FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                    {
                        Answers = caseMonitoring.CaseMonitoringObservationParameters,
                        idfsFormTemplate = (long) caseMonitoring.CaseMonitoringFlexFormRequest.idfsFormTemplate,
                        idfObservation = caseMonitoring.CaseMonitoringFlexFormRequest.idfObservation,
                        User = caseMonitoring.CaseMonitoringFlexFormRequest.User
                    };
                    var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                    caseMonitoring.CaseMonitoringFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                    caseMonitoring.ObservationId = flexFormResponse.idfObservation;

                    await InvokeAsync(StateHasChanged);

                    caseMonitoring.ObservationId = flexFormResponse.idfObservation;
                }

                CaseQuickSaveRequestModel request = new()
                {
                    CaseIdentifiers = caseIdentifiers,
                    ClassificationTypeId = SelectedClassificationTypeId,
                    StatusTypeId = SelectedStatusTypeId,
                    CaseMonitorings = JsonConvert.SerializeObject(BuildCaseMonitoringParameters(PendingSaveCaseMonitorings)),
                    Events = null
                };
                await OutbreakClient.QuickSaveCase(request);

                SelectedCases = new List<CaseGetListViewModel>();
                Cases = null;
                PendingSaveCaseMonitorings = new List<CaseMonitoringGetListViewModel>();
                await CasesGrid.Reload();
                SaveDisabledIndicator = true;

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
        /// <param name="caseMonitorings"></param>
        /// <returns></returns>
        private static List<CaseMonitoringSaveRequestModel> BuildCaseMonitoringParameters(
            IList<CaseMonitoringGetListViewModel> caseMonitorings)
        {
            List<CaseMonitoringSaveRequestModel> requests = new();

            if (caseMonitorings is null)
                return new List<CaseMonitoringSaveRequestModel>();

            foreach (var caseMonitoring in caseMonitorings)
            {
                var request = new CaseMonitoringSaveRequestModel();
                {
                    if (caseMonitoring.CaseMonitoringId != null)
                        request.CaseMonitoringID = (long) caseMonitoring.CaseMonitoringId;
                    request.HumanDiseaseReportID = caseMonitoring.HumanCaseId;
                    request.VeterinaryDiseaseReportID = caseMonitoring.VeterinaryCaseId;
                    request.AdditionalComments = caseMonitoring.AdditionalComments;
                    request.InvestigatedByOrganizationID = caseMonitoring.InvestigatedByOrganizationId;
                    request.InvestigatedByPersonID = caseMonitoring.InvestigatedByPersonId;
                    request.MonitoringDate = caseMonitoring.MonitoringDate;
                    request.ObservationID = caseMonitoring.ObservationId;
                    request.RowStatus = caseMonitoring.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Today's Followup Indicator Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnTodaysFollowupsIndicatorChanged()
        {
            Cases = null;
            await CasesGrid.Reload();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchButtonClick()
        {
            Cases = null;
            await CasesGrid.Reload();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Print Button Click Event

        protected async Task OnPrintButtonClick()
        {
            try
            {
                int nGridCount = CasesGrid.Count;

                ReportViewModel reportModel = new();
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.OutbreakCaseInvestigationCaseQuestionnaireHeading));
                reportModel.AddParameter("OutbreakID", OutbreakId.ToString());
                reportModel.AddParameter("SearchTerm", SearchTerm);
                reportModel.AddParameter("HumanMasterID", "");
                reportModel.AddParameter("FarmMasterID", "");
                reportModel.AddParameter("TodaysFollowUpsIndicator", TodaysFollowupsIndicator.ToString());
                reportModel.AddParameter("PageSize", "9999");
                reportModel.AddParameter("PageNumber", "1");
                reportModel.AddParameter("SortColumn", "EIDSSCaseID");
                reportModel.AddParameter("SortOrder", "DESC");

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.CommonHeadingsPrintHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "SearchForOutbreakCases"}, {"Parameters", reportModel.Parameters}},
                    new DialogOptions
                    {
                        Style = EIDSSConstants.ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                        Top = "150",
                        Left = "150",
                        Resizable = true,
                        Draggable = false,
                        Width = "1050px"
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Clear Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearButtonClick()
        {
            SearchTerm = null;
            TodaysFollowupsIndicator = false;
            Cases = null;
            await CasesGrid.Reload();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Read Only Case Hyperlink Click Event

        protected void OnCaseClick(object outbreakCase)
        {
            OnEditCaseClick(outbreakCase, true);
        }
        #endregion
        #region Edit Case Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="outbreakCase"></param>
        protected void OnEditCaseClick(object outbreakCase, bool readOnly = false)
        {
            try
            {
                
                var outbreakTypeId = ((CaseGetListViewModel) outbreakCase).OutbreakTypeID;
                if (outbreakTypeId == null) return;
                var path = (OutbreakTypeEnum) outbreakTypeId switch
                {
                    OutbreakTypeEnum.Human => "Outbreak/HumanCase/Edit",
                    OutbreakTypeEnum.Veterinary => "Outbreak/OutbreakCases/VeterinaryDetails",
                    _ => Empty
                };

                var query = $"?outbreakId={OutbreakId}&caseId={((CaseGetListViewModel) outbreakCase).CaseID}" + (readOnly ? "&readOnly=true" : string.Empty);
                var uri = $"{NavManager.BaseUri}{path}{query}";

                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Import Human Disease Report Method

        /// <summary>
        /// </summary>
        /// <param name="callbackKey"></param>
        /// <param name="callBackUrl"></param>
        /// <param name="cancelUrl"></param>
        /// <param name="diseaseId"></param>
        /// <returns></returns>
        [JSInvokable("OnImportHumanDiseaseReport")]
        public async Task OnImportHumanDiseaseReport(string callbackKey, string callBackUrl, string cancelUrl, string diseaseId)
        {
            try
            {
                await DiagService.OpenAsync<SearchHumanDiseaseReport>(
                    Localizer.GetString(HeadingResourceKeyConstants
                        .OutbreakCasesImportHumanDiseaseReportHeading),
                    new Dictionary<string, object>
                    {
                        { "Mode", SearchModeEnum.Import },
                        { "callbackKey", Convert.ToInt64(callbackKey) }, 
                        { "CallbackUrl", callBackUrl },
                        { "CancelUrl", cancelUrl }, 
                        { "DiseaseId", Convert.ToInt64(diseaseId) }
                    },
                    new DialogOptions
                    {
                        Style = OutbreakModuleCSSClassConstants.ImportCaseDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Import Veterinary Disease Report Method

        /// <summary>
        /// </summary>
        /// <param name="callbackKey"></param>
        /// <param name="callBackUrl"></param>
        /// <param name="cancelUrl"></param>
        /// <param name="diseaseId"></param>
        /// <returns></returns>
        [JSInvokable("OnImportVeterinaryDiseaseReport")]
        public async Task OnImportVeterinaryDiseaseReport(string callbackKey, string callBackUrl, string cancelUrl, string diseaseId)
        {
            try
            {
                await DiagService.OpenAsync<SearchVeterinaryDiseaseReport>(
                    Localizer.GetString(HeadingResourceKeyConstants
                        .OutbreakCasesImportVeterinaryDiseaseReportHeading),
                    new Dictionary<string, object>
                    {
                        { "Mode", SearchModeEnum.Import },
                        { "callbackKey", Convert.ToInt64(callbackKey) }, 
                        { "CallbackUrl", callBackUrl },
                        { "CancelUrl", cancelUrl }, 
                        { "DiseaseId", Convert.ToInt64(diseaseId) }
                    },
                    new DialogOptions
                    {
                        Style = OutbreakModuleCSSClassConstants.ImportCaseDialog,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}