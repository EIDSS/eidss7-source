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
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Outbreak.Case;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
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
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Session
{
    public class ContactsTabBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ContactsTabBase> Logger { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long OutbreakId { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public IList<ContactGetListViewModel> Contacts { get; set; }
        public IList<ContactGetListViewModel> SelectedContacts { get; set; }
        public IList<ContactGetListViewModel> PendingSaveContacts { get; set; }
        public IEnumerable<BaseReferenceViewModel> CaseStatusTypes { get; set; }
        public bool WritePermissionIndicator { get; set; }
        protected RadzenDataGrid<ContactGetListViewModel> ContactsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }
        public string SearchTerm { get; set; }
        public bool TodaysFollowupsIndicator { get; set; }
        public bool SaveDisabledIndicator { get; set; }
        public CaseGetDetailViewModel Case { get; set; }
        protected FlexForm.FlexForm ContactTracing { get; set; }

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

        private const string DefaultSortColumn = "ContactName";

        #endregion

        #endregion

        #region Constructors

        public ContactsTabBase(CancellationToken token) : base(token)
        {
        }

        protected ContactsTabBase() : base(CancellationToken.None)
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

            _userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryOutbreakContactsDataPerson);

            WritePermissionIndicator = _userPermissions.Write;

            SelectedContacts = new List<ContactGetListViewModel>();

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
                SaveDisabledIndicator = true;

                CaseStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakContactStatus, HACodeList.NoneHACode);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadContactData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (ContactsGrid.PageSize != 0)
                    pageSize = ContactsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (Contacts is null ||
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

                        Contacts = await GetContacts(null, OutbreakId, SearchTerm, TodaysFollowupsIndicator, page,
                            pageSize, sortColumn, sortOrder);
                        _databaseQueryCount = !Contacts.Any() ? 0 : Contacts.First().TotalRowCount;
                    }
                    else if (Contacts != null)
                    {
                        _databaseQueryCount = Contacts.Count;
                    }

                    if (Contacts != null)
                        for (var index = 0; index < Contacts.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Contacts[index].CaseContactID < 0)
                            {
                                Contacts.RemoveAt(index);
                                index--;
                            }

                            if (PendingSaveContacts == null || index < 0 || Contacts.Count == 0 ||
                                PendingSaveContacts.All(x =>
                                    x.CaseContactID != Contacts[index].CaseContactID)) continue;
                            {
                                if (PendingSaveContacts.First(x => x.CaseContactID == Contacts[index].CaseContactID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    Contacts.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Contacts[index] = PendingSaveContacts.First(x =>
                                        x.CaseContactID == Contacts[index].CaseContactID);
                                }
                            }
                        }

                    Count = _databaseQueryCount;

                    if (Contacts != null)
                        foreach (var contact in Contacts)
                            if (contact.ContactTracingFlexFormRequest is null)
                            {
                                FlexFormQuestionnaireGetRequestModel request = new();

                                switch (contact.OutbreakTypeID)
                                {
                                    case (long)OutbreakTypeEnum.Human:
                                        request = new FlexFormQuestionnaireGetRequestModel
                                        {
                                            idfObservation = contact.ContactTracingObservationID,
                                            idfsDiagnosis = contact.DiseaseID,
                                            idfsFormType = (long)FlexibleFormTypeEnum.HumanOutbreakCaseContactTracing,
                                            LangID = GetCurrentLanguage()
                                        };
                                        break;
                                    case (long)OutbreakTypeEnum.Veterinary:
                                        request = new FlexFormQuestionnaireGetRequestModel
                                        {
                                            idfObservation = contact.ContactTracingObservationID,
                                            idfsDiagnosis = contact.DiseaseID,
                                            idfsFormType = contact.VeterinaryDiseaseReportTypeID ==
                                                           (long)CaseTypeEnum.Avian
                                                ? (long)FlexibleFormTypeEnum.AvianOutbreakCaseContactTracing
                                                : (long)FlexibleFormTypeEnum.LivestockOutbreakCaseContactTracing,
                                            LangID = GetCurrentLanguage()
                                        };
                                        break;
                                    case (long)OutbreakTypeEnum.Zoonotic:

                                        break;
                                }

                                contact.ContactTracingFlexFormRequest = request;
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
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Contacts is null)
                    return false;

                if (SelectedContacts is { Count: > 0 })
                    if (Contacts.Any(item => SelectedContacts.Any(x => x.CaseContactID == item.CaseContactID)))
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
                Contacts ??= new List<ContactGetListViewModel>();

                if (value == false)
                    foreach (var item in Contacts)
                    {
                        if (SelectedContacts.All(x => x.CaseContactID != item.CaseContactID)) continue;
                        {
                            var selected = SelectedContacts.First(x => x.CaseContactID == item.CaseContactID);

                            SelectedContacts.Remove(selected);
                        }
                    }
                else
                    foreach (var item in Contacts)
                        SelectedContacts.Add(item);
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
        protected bool IsRecordSelected(ContactGetListViewModel item)
        {
            try
            {
                if (SelectedContacts is not null && SelectedContacts.Any(x => x.CaseContactID == item.CaseContactID))
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
        protected void RecordSelectionChange(bool? value, ContactGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedContacts.First(x => x.CaseContactID == item.CaseContactID);

                    SelectedContacts.Remove(item);
                }
                else
                {
                    SelectedContacts.Add(item);
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
        /// <param name="contact"></param>
        /// <returns></returns>
        public async Task OnRowExpand(ContactGetListViewModel contact)
        {
            try
            {
                var caseDetail = await OutbreakClient
                    .GetCaseDetail(GetCurrentLanguage(), contact.CaseID, _token)
                    .ConfigureAwait(false);
                Case = caseDetail.First();

                if (Case.OutbreakId != null)
                {
                    dynamic request = new OutbreakSessionDetailRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        idfsOutbreak = (long)Case.OutbreakId
                    };
                    List<OutbreakSessionDetailsResponseModel> session = OutbreakClient.GetSessionDetail(request).Result;

                    var sessionSpeciesParameters = OutbreakClient.GetSessionParametersList(request).Result;
                    foreach (var parameter in sessionSpeciesParameters)
                        switch (parameter.OutbreakSpeciesTypeID)
                        {
                            case (long)OutbreakSpeciesTypeEnum.Avian:
                                session.First().AvianCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().AvianCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().AvianContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Human:
                                session.First().HumanCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().HumanCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().HumanContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Livestock:
                                session.First().LivestockCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().LivestockCaseQuestionaireTemplateID =
                                    parameter.CaseQuestionaireTemplateID;
                                session.First().LivestockContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                        }

                    Case.Session = session.First();

                    contact.ContactTracingFlexFormRequest.idfsFormTemplate =
                        Case.CaseTypeId switch
                        {
                            (long)OutbreakSpeciesTypeEnum.Human => Case.Session.HumanCaseMonitoringTemplateID,
                            (long)OutbreakSpeciesTypeEnum.Avian => Case.Session.AvianContactTracingTemplateID,
                            (long)OutbreakSpeciesTypeEnum.Livestock => Case.Session.LivestockContactTracingTemplateID,
                            _ => contact.ContactTracingFlexFormRequest.idfsFormTemplate
                        };

                    ContactTracing ??= new FlexForm.FlexForm();
                    ContactTracing.SetRequestParameter(contact.ContactTracingFlexFormRequest);

                    await InvokeAsync(StateHasChanged);
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
        protected void OnRowRender(RowRenderEventArgs<ContactGetListViewModel> record)
        {
            try
            {
                var cssClass = record.Data.RowAction switch
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
                foreach (var contact in SelectedContacts)
                {
                    contact.ContactStatusID = statusTypeId;
                    contact.RowAction = (int)RowActionTypeEnum.Update;

                    TogglePendingSaveContacts(contact, contact);
                }

                SelectedContacts = new List<ContactGetListViewModel>();
                await ContactsGrid.Reload();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Today's Followup Indicator Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnTodaysFollowupsIndicatorChanged()
        {
            Contacts = null;
            await ContactsGrid.Reload();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchButtonClick()
        {
            Contacts = null;

            await InvokeAsync(() =>
            {
                ContactsGrid.Reload();
                StateHasChanged();
            });
        }

        #endregion

        #region Print Button Click Event

        protected async Task OnPrintButtonClick()
        {
            try
            {
                int nGridCount = ContactsGrid.Count;

                ReportViewModel reportModel = new();
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.OutbreakContactsOutbreakContactsListHeading));
                reportModel.AddParameter("CaseID", Contacts.First().CaseID.ToString());
                reportModel.AddParameter("PageSize", "9999");
                reportModel.AddParameter("PageNumber", "1");
                reportModel.AddParameter("SortColumn", "EIDSSContactID");
                reportModel.AddParameter("SortOrder", "DESC");

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.CommonHeadingsPrintHeading),
                    new Dictionary<string, object> {{"ReportName", "SearchForOutbreakContacts"}, {"Parameters", reportModel.Parameters}},
                    new DialogOptions
                    {
                        Style = EIDSSConstants.ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                        Top = "150",
                        Left = "150",
                        Resizable = true,
                        Draggable = false,
                        Width = "1050px",
                        Height = "600px"
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
            Contacts = null;

            await InvokeAsync(() =>
            {
                ContactsGrid.Reload();
                StateHasChanged();
            });
        }

        #endregion

        #region Edit Contact Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="contact"></param>
        protected async Task OnEditContactClick(object contact)
        {
            try
            {
                var caseDetail = await OutbreakClient
                    .GetCaseDetail(GetCurrentLanguage(), ((ContactGetListViewModel)contact).CaseID, _token)
                    .ConfigureAwait(false);
                Case = caseDetail.First();

                if (Case.OutbreakId != null)
                {
                    dynamic request = new OutbreakSessionDetailRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        idfsOutbreak = (long)Case.OutbreakId
                    };
                    List<OutbreakSessionDetailsResponseModel> session = OutbreakClient.GetSessionDetail(request).Result;

                    var sessionSpeciesParameters = OutbreakClient.GetSessionParametersList(request).Result;
                    foreach (var parameter in sessionSpeciesParameters)
                        switch (parameter.OutbreakSpeciesTypeID)
                        {
                            case (long)OutbreakSpeciesTypeEnum.Avian:
                                session.First().AvianCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().AvianCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().AvianContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Human:
                                session.First().HumanCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().HumanCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().HumanContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Livestock:
                                session.First().LivestockCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().LivestockCaseQuestionaireTemplateID =
                                    parameter.CaseQuestionaireTemplateID;
                                session.First().LivestockContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                        }

                    Case.Session = session.First();

                    ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfsFormTemplate =
                        Case.CaseTypeId switch
                        {
                            (long)OutbreakSpeciesTypeEnum.Human => Case.Session.HumanCaseMonitoringTemplateID,
                            (long)OutbreakSpeciesTypeEnum.Avian => Case.Session.AvianContactTracingTemplateID,
                            (long)OutbreakSpeciesTypeEnum.Livestock => Case.Session.LivestockContactTracingTemplateID,
                            _ => ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfsFormTemplate
                        };
                }

                if (((ContactGetListViewModel)contact).ContactTracingFlexFormRequest is { idfsFormTemplate: { } })
                {
                    var formTemplateId = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest
                        .idfsFormTemplate;
                    if (formTemplateId != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((ContactGetListViewModel)contact).ContactTracingObservationParameters,
                            idfsFormTemplate = (long)formTemplateId,
                            idfObservation = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfObservation,
                            User = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.User
                        };
                        var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                        ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfObservation =
                            flexFormResponse.idfObservation;
                        ((ContactGetListViewModel)contact).ContactTracingObservationID = flexFormResponse.idfObservation;
                    }
                }

                ((ContactGetListViewModel)contact).ContactLocation = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
                    EnableAdminLevel2 = true,
                    EnableAdminLevel3 = true,
                    EnableApartment = true,
                    EnableBuilding = true,
                    EnableHouse = true,
                    EnablePostalCode = true,
                    EnableSettlement = true,
                    EnableSettlementType = true,
                    EnableStreet = true,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = true,
                    ShowAdminLevel4 = false,
                    ShowAdminLevel5 = false,
                    ShowAdminLevel6 = false,
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
                    ShowCoordinates = false,
                    IsDbRequiredAdminLevel0 = true,
                    IsDbRequiredAdminLevel1 = true,
                    IsDbRequiredAdminLevel2 = true,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(CountryID)
                };

                if (((ContactGetListViewModel)contact).AdministrativeLevel0ID is not null)
                    ((ContactGetListViewModel)contact).ContactLocation.AdminLevel0Value =
                        ((ContactGetListViewModel)contact).AdministrativeLevel0ID;
                ((ContactGetListViewModel)contact).ContactLocation.AdminLevel1Value =
                    ((ContactGetListViewModel)contact).AdministrativeLevel1ID;
                ((ContactGetListViewModel)contact).ContactLocation.AdminLevel2Value =
                    ((ContactGetListViewModel)contact).AdministrativeLevel2ID;
                ((ContactGetListViewModel)contact).ContactLocation.SettlementType =
                    ((ContactGetListViewModel)contact).SettlementTypeID;
                ((ContactGetListViewModel)contact).ContactLocation.SettlementId =
                    ((ContactGetListViewModel)contact).SettlementID;
                ((ContactGetListViewModel)contact).ContactLocation.Settlement =
                    ((ContactGetListViewModel)contact).SettlementID;
                ((ContactGetListViewModel)contact).ContactLocation.Apartment =
                    ((ContactGetListViewModel)contact).Apartment;
                ((ContactGetListViewModel)contact).ContactLocation.Building =
                    ((ContactGetListViewModel)contact).Building;
                ((ContactGetListViewModel)contact).ContactLocation.House = ((ContactGetListViewModel)contact).House;
                ((ContactGetListViewModel)contact).ContactLocation.PostalCode =
                    ((ContactGetListViewModel)contact).PostalCodeID;
                ((ContactGetListViewModel)contact).ContactLocation.PostalCodeText =
                    ((ContactGetListViewModel)contact).PostalCode;
                if (((ContactGetListViewModel)contact).PostalCodeID != null)
                    ((ContactGetListViewModel)contact).ContactLocation.PostalCodeList = new List<PostalCodeViewModel>
                    {
                        new()
                        {
                            PostalCodeID = ((ContactGetListViewModel) contact).PostalCodeID.ToString(),
                            PostalCodeString = ((ContactGetListViewModel) contact).PostalCode
                        }
                    };

                ((ContactGetListViewModel)contact).ContactLocation.StreetText =
                    ((ContactGetListViewModel)contact).Street;
                ((ContactGetListViewModel)contact).ContactLocation.Street =
                    ((ContactGetListViewModel)contact).StreetID;
                if (((ContactGetListViewModel)contact).StreetID != null)
                    ((ContactGetListViewModel)contact).ContactLocation.StreetList = new List<StreetModel>
                    {
                        new()
                        {
                            StreetID = ((ContactGetListViewModel) contact).StreetID.ToString(),
                            StreetName = ((ContactGetListViewModel) contact).Street
                        }
                    };

                var result = await DiagService.OpenAsync<Contact>(
                    Case.Session.OutbreakTypeId == (long)OutbreakTypeEnum.Veterinary
                        ? Localizer.GetString(HeadingResourceKeyConstants.OutbreakContactsContactPremiseHeading)
                        : Localizer.GetString(HeadingResourceKeyConstants.OutbreakContactsContactDetailsHeading),
                    new Dictionary<string, object>
                    {
                        {"Model", ((ContactGetListViewModel) contact).ShallowCopy()},
                        {"Case", Case},
                        {"ContactsTabIndicator", true}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is ContactGetListViewModel model)
                {
                    if (Contacts.Any(x =>
                            x.CaseContactID == ((ContactGetListViewModel)result).CaseContactID))
                    {
                        var index = Contacts.IndexOf((ContactGetListViewModel)contact);
                        Contacts[index] = model;

                        TogglePendingSaveContacts(model, (ContactGetListViewModel)contact);
                    }

                    await InvokeAsync(() =>
                    {
                        Contacts = null;
                        ContactsGrid.Reload();
                        StateHasChanged();
                    });
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
        /// <param name="contact"></param>
        protected async Task OnEditContactTracingClick(object contact)
        {
            try
            {
                ((ContactGetListViewModel)contact).ContactTracingEditInProgressIndicator = true;

                var caseDetail = await OutbreakClient
                    .GetCaseDetail(GetCurrentLanguage(), ((ContactGetListViewModel)contact).CaseID, _token)
                    .ConfigureAwait(false);
                Case = caseDetail.First();

                if (Case.OutbreakId != null)
                {
                    dynamic request = new OutbreakSessionDetailRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        idfsOutbreak = (long)Case.OutbreakId
                    };
                    List<OutbreakSessionDetailsResponseModel> session = OutbreakClient.GetSessionDetail(request).Result;

                    var sessionSpeciesParameters = OutbreakClient.GetSessionParametersList(request).Result;
                    foreach (var parameter in sessionSpeciesParameters)
                        switch (parameter.OutbreakSpeciesTypeID)
                        {
                            case (long)OutbreakSpeciesTypeEnum.Avian:
                                session.First().AvianCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().AvianCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().AvianContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Human:
                                session.First().HumanCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().HumanCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                                session.First().HumanContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                            case (long)OutbreakSpeciesTypeEnum.Livestock:
                                session.First().LivestockCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                                session.First().LivestockCaseQuestionaireTemplateID =
                                    parameter.CaseQuestionaireTemplateID;
                                session.First().LivestockContactTracingTemplateID = parameter.ContactTracingTemplateID;
                                break;
                        }

                    Case.Session = session.First();
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
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveContacts(ContactGetListViewModel record, ContactGetListViewModel originalRecord)
        {
            PendingSaveContacts ??= new List<ContactGetListViewModel>();

            if (PendingSaveContacts.Any(x => x.CaseContactID == record.CaseContactID))
            {
                var index = PendingSaveContacts.IndexOf(originalRecord);
                PendingSaveContacts[index] = record;
            }
            else
            {
                PendingSaveContacts.Add(record);
            }

            SaveDisabledIndicator = false;
        }

        #endregion

        #region Delete Contact Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="contact"></param>
        protected async Task OnDeleteContactClick(object contact)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        ((ContactGetListViewModel)contact).RowAction = (int)RowActionTypeEnum.Delete;
                        ((ContactGetListViewModel)contact).RowStatus = (int)RowStatusTypeEnum.Inactive;

                        var deletedContact = new List<ContactGetListViewModel> { (ContactGetListViewModel)contact };
                        var request = new ContactSaveRequestModel
                        {
                            Contacts = JsonConvert.SerializeObject(BuildContactParameters(deletedContact)),
                            User = authenticatedUser.UserName
                        };
                        await OutbreakClient.SaveContact(request);

                        Contacts = null;
                        await ContactsGrid.Reload();

                        DiagService.Close(result);
                    }
                }
                else
                    DiagService.Close(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Save Contacts Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSaveContactsButtonClick()
        {
            try
            {
                foreach (var contact in PendingSaveContacts)
                {
                    if (contact.ContactTracingFlexFormRequest?.idfsFormTemplate == null) continue;
                    FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                    {
                        Answers = contact.ContactTracingObservationParameters,
                        idfsFormTemplate = (long)contact.ContactTracingFlexFormRequest.idfsFormTemplate,
                        idfObservation = contact.ContactTracingFlexFormRequest.idfObservation,
                        User = contact.ContactTracingFlexFormRequest.User
                    };

                    if (flexFormRequest.Answers == "[]") continue;
                    var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                    contact.ContactTracingFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                    contact.ContactTracingObservationID = flexFormResponse.idfObservation;

                    await InvokeAsync(StateHasChanged);

                    contact.ContactTracingObservationID = flexFormResponse.idfObservation;
                }

                var request = new ContactSaveRequestModel
                {
                    Contacts = JsonConvert.SerializeObject(BuildContactParameters(PendingSaveContacts)),
                    User = authenticatedUser.UserName
                };

                await OutbreakClient.SaveContact(request);

                Contacts = null;
                PendingSaveContacts = new List<ContactGetListViewModel>();
                await ContactsGrid.Reload();
                SaveDisabledIndicator = true;

                var uri = $"{NavManager.BaseUri}Outbreak/OutbreakCases?queryData={OutbreakId}&tab=Contacts";
                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="contact"></param>
        /// <returns></returns>
        protected async Task OnSaveContactTracingButtonClick(object contact)
        {
            try
            {
                if (ContactTracing is not null)
                {
                    var response = await ContactTracing.CollectAnswers();
                    await InvokeAsync(StateHasChanged);
                    ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfsFormTemplate =
                        response.idfsFormTemplate;
                    ((ContactGetListViewModel)contact).ContactTracingFlexFormAnswers = ContactTracing.Answers;
                    ((ContactGetListViewModel)contact).ContactTracingObservationParameters = response.Answers;
                    ((ContactGetListViewModel)contact).RowAction = (int)RowActionTypeEnum.Update;
                    ((ContactGetListViewModel)contact).ContactTracingEditInProgressIndicator = false;

                    ((ContactGetListViewModel)contact).ContactLocation = new LocationViewModel
                    {
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        EnableAdminLevel2 = true,
                        EnableAdminLevel3 = true,
                        EnableApartment = true,
                        EnableBuilding = true,
                        EnableHouse = true,
                        EnablePostalCode = true,
                        EnableSettlement = true,
                        EnableSettlementType = true,
                        EnableStreet = true,
                        ShowAdminLevel0 = false,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = true,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
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
                        ShowCoordinates = false,
                        IsDbRequiredAdminLevel0 = true,
                        IsDbRequiredAdminLevel1 = true,
                        IsDbRequiredAdminLevel2 = true,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        AdminLevel0Value = Convert.ToInt64(CountryID)
                    };

                    if (((ContactGetListViewModel)contact).AdministrativeLevel0ID is not null)
                        ((ContactGetListViewModel)contact).ContactLocation.AdminLevel0Value =
                            ((ContactGetListViewModel)contact).AdministrativeLevel0ID;
                    ((ContactGetListViewModel)contact).ContactLocation.AdminLevel1Value =
                        ((ContactGetListViewModel)contact).AdministrativeLevel1ID;
                    ((ContactGetListViewModel)contact).ContactLocation.AdminLevel2Value =
                        ((ContactGetListViewModel)contact).AdministrativeLevel2ID;
                    ((ContactGetListViewModel)contact).ContactLocation.SettlementType =
                        ((ContactGetListViewModel)contact).SettlementTypeID;
                    ((ContactGetListViewModel)contact).ContactLocation.SettlementId =
                        ((ContactGetListViewModel)contact).SettlementID;
                    ((ContactGetListViewModel)contact).ContactLocation.Settlement =
                        ((ContactGetListViewModel)contact).SettlementID;
                    ((ContactGetListViewModel)contact).ContactLocation.Apartment =
                        ((ContactGetListViewModel)contact).Apartment;
                    ((ContactGetListViewModel)contact).ContactLocation.Building =
                        ((ContactGetListViewModel)contact).Building;
                    ((ContactGetListViewModel)contact).ContactLocation.House =
                        ((ContactGetListViewModel)contact).House;
                    ((ContactGetListViewModel)contact).ContactLocation.PostalCode =
                        ((ContactGetListViewModel)contact).PostalCodeID;
                    ((ContactGetListViewModel)contact).ContactLocation.PostalCodeText =
                        ((ContactGetListViewModel)contact).PostalCode;
                    if (((ContactGetListViewModel)contact).PostalCodeID != null)
                        ((ContactGetListViewModel)contact).ContactLocation.PostalCodeList =
                            new List<PostalCodeViewModel>
                            {
                                new()
                                {
                                    PostalCodeID = ((ContactGetListViewModel) contact).PostalCodeID.ToString(),
                                    PostalCodeString = ((ContactGetListViewModel) contact).PostalCode
                                }
                            };

                    ((ContactGetListViewModel)contact).ContactLocation.StreetText =
                        ((ContactGetListViewModel)contact).Street;
                    ((ContactGetListViewModel)contact).ContactLocation.Street =
                        ((ContactGetListViewModel)contact).StreetID;
                    if (((ContactGetListViewModel)contact).StreetID != null)
                        ((ContactGetListViewModel)contact).ContactLocation.StreetList = new List<StreetModel>
                        {
                            new()
                            {
                                StreetID = ((ContactGetListViewModel) contact).StreetID.ToString(),
                                StreetName = ((ContactGetListViewModel) contact).Street
                            }
                        };

                    TogglePendingSaveContacts((ContactGetListViewModel)contact, (ContactGetListViewModel)contact);

                    await InvokeAsync(() =>
                    {
                        Contacts = null;
                        ContactsGrid.Reload();
                        StateHasChanged();
                    });

                    if (((ContactGetListViewModel)contact).ContactTracingFlexFormRequest is { idfsFormTemplate: { } })
                    {
                        var formTemplateId = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest
                            .idfsFormTemplate;
                        if (formTemplateId != null)
                        {
                            FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                            {
                                Answers = ((ContactGetListViewModel)contact).ContactTracingObservationParameters,
                                idfsFormTemplate = (long)formTemplateId,
                                idfObservation = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest
                                    .idfObservation,
                                User = ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.User
                            };
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfObservation =
                                flexFormResponse.idfObservation;
                            ((ContactGetListViewModel)contact).ContactTracingObservationID =
                                flexFormResponse.idfObservation;

                            await InvokeAsync(StateHasChanged);

                            ((ContactGetListViewModel)contact).ContactTracingObservationID =
                                flexFormResponse.idfObservation;
                        }
                    }
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
        /// <param name="contacts"></param>
        /// <returns></returns>
        private List<ContactSaveRequestModel> BuildContactParameters(IList<ContactGetListViewModel> contacts)
        {
            List<ContactSaveRequestModel> requests = new();

            if (contacts is null)
                return new List<ContactSaveRequestModel>();

            foreach (var contact in contacts)
            {
                contact.ContactLocation ??= new LocationViewModel();

                var request = new ContactSaveRequestModel();
                {
                    request.CaseContactID = contact.CaseContactID;
                    request.OutbreakCaseReportUID = contact.CaseID;
                    request.ContactRelationshipTypeID = contact.ContactRelationshipTypeID;
                    request.ContactStatusID = contact.ContactStatusID;
                    request.OutbreakID = OutbreakId;
                    request.HumanMasterID = contact.HumanMasterID;
                    request.HumanID = contact.HumanID;
                    request.FarmMasterID = contact.FarmMasterID;
                    request.AddressID = contact.AddressID;
                    request.LocationID = contact.LocationID;
                    request.ForeignAddressString = contact.ForeignAddressString;
                    request.Apartment = contact.Apartment;
                    request.Building = contact.Building;
                    request.House = contact.House;
                    request.Street = contact.Street;
                    request.PostalCode = contact.PostalCode;
                    request.Comment = contact.Comment;
                    request.ContactPhone = contact.ContactPhone;
                    request.DateOfLastContact = contact.DateOfLastContact;
                    request.PlaceOfLastContact = contact.PlaceOfLastContact;
                    request.ContactTracingObservationID = contact.ContactTracingObservationID;
                    request.RowAction = contact.RowAction;
                    request.RowStatus = contact.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Cancel Save Contact Tracing Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="contact"></param>
        protected async Task OnCancelSaveContactTracingButtonClick(object contact)
        {
            try
            {
                ((ContactGetListViewModel)contact).ContactTracingEditInProgressIndicator = false;

                await ContactsGrid.Reload();
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