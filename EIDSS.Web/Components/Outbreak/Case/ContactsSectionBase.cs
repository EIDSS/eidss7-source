#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Veterinary.SearchFarm;
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
using EIDSS.Web.Components.Human.SearchPerson;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Web.Components.Human.Person;
using Serilog.Sinks.Http.TextFormatters;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case
{
    public class ContactsSectionBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ContactsSectionBase> Logger { get; set; }
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
        protected RadzenDataGrid<ContactGetListViewModel> ContactsGrid { get; set; }
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

        private const string DefaultSortColumn = "ContactName";

        #endregion

        #endregion

        #region Constructors

        public ContactsSectionBase(CancellationToken token) : base(token)
        {
        }

        protected ContactsSectionBase() : base(CancellationToken.None)
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
                if (!IsHumanCase)
                    await JsRuntime.InvokeVoidAsync("ContactsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
                else
                {
                    await InvokeAsync(() =>
                    {
                        _ = LoadContactData(new LoadDataArgs() { Top = 1, Skip = 10 });
                        StateHasChanged();
                    });
                }
            }
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
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.Contacts is null ||
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

                        Model.Contacts = await GetContacts(Model.CaseId, null, null, false, page, pageSize, sortColumn,
                                sortOrder)
                            .ConfigureAwait(false);
                        _databaseQueryCount = !Model.Contacts.Any() ? 0 : Model.Contacts.First().TotalRowCount;
                    }
                    else if (Model.Contacts != null)
                    {
                        _databaseQueryCount = Model.Contacts.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.CaseContactID < 0)
                            ? 0
                            : Model.Contacts.First(x => x.CaseContactID > 0).TotalRowCount;
                    }

                    if (Model.Contacts != null)
                        for (var index = 0; index < Model.Contacts.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.Contacts[index].CaseContactID < 0)
                            {
                                Model.Contacts.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveContacts == null || index < 0 || Model.Contacts.Count == 0 ||
                                Model.PendingSaveContacts.All(x =>
                                    x.CaseContactID != Model.Contacts[index].CaseContactID)) continue;
                            {
                                if (Model.PendingSaveContacts.First(x =>
                                            x.CaseContactID == Model.Contacts[index].CaseContactID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.Contacts.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.Contacts[index] = Model.PendingSaveContacts.First(x =>
                                        x.CaseContactID == Model.Contacts[index].CaseContactID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveContacts != null &&
                            Model.PendingSaveContacts.Any(x => x.CaseContactID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveContacts.Where(x => x.CaseContactID < 0).ToList();
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
                                Model.Contacts?.Clear();
                            }
                            else
                            {
                                Model.Contacts?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.Contacts?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.Contacts != null)
                            Model.Contacts = Model.Contacts.AsQueryable()
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
        protected void TogglePendingSaveContacts(ContactGetListViewModel record, ContactGetListViewModel originalRecord)
        {
            Model.PendingSaveContacts ??= new List<ContactGetListViewModel>();

            if (Model.PendingSaveContacts.Any(x => x.CaseContactID == record.CaseContactID))
            {
                var index = Model.PendingSaveContacts.IndexOf(originalRecord);
                Model.PendingSaveContacts[index] = record;
            }
            else
            {
                Model.PendingSaveContacts.Add(record);
            }
        }

        #endregion

        #region Add Contact Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddContactClick()
        {
            try
            {
                FlexFormQuestionnaireGetRequestModel contactTracingFlexFormRequest = new()
                {
                    idfsDiagnosis = Model.DiseaseId,
                    LangID = GetCurrentLanguage()
                };

                if (Model.Session.OutbreakTypeId == (long)OutbreakTypeEnum.Veterinary || (Model.Session.OutbreakTypeId == (long) OutbreakTypeEnum.Zoonotic && VeterinaryDiseaseReport is not null))
                {
                    if (VeterinaryDiseaseReport.ReportCategoryTypeID != 0)
                    {
                        if (VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                        {
                            contactTracingFlexFormRequest.idfsFormType =
                                (long)FlexibleFormTypeEnum.AvianOutbreakCaseContactTracing;
                            contactTracingFlexFormRequest.idfsFormTemplate =
                                Model.Session.AvianContactTracingTemplateID;
                        }
                        else
                        {
                            contactTracingFlexFormRequest.idfsFormType =
                                (long)FlexibleFormTypeEnum.LivestockOutbreakCaseContactTracing;
                            contactTracingFlexFormRequest.idfsFormTemplate =
                                Model.Session.LivestockContactTracingTemplateID;
                        }
                    }

                    var result = await DiagService.OpenAsync<SearchFarm>(
                        Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseSearchFarmHeading),
                        new Dictionary<string, object> { { "Mode", SearchModeEnum.SelectNoRedirect } },
                        new DialogOptions
                        {
                            Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    switch (result)
                    {
                        case null:
                            {
                                ContactGetListViewModel model = new()
                                {
                                    ContactRelationshipTypeID = (long)PatientRelationshipTypeEnum.Other,
                                    ContactStatusID = (long)OutbreakContactStatusTypeEnum.Healthy,
                                    ContactTypeID = (long)OutbreakContactTypeEnum.Veterinary,
                                    ContactTracingFlexFormRequest = contactTracingFlexFormRequest,
                                    FarmName = null,
                                    ContactLocation = new LocationViewModel
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
                                    }
                                };

                                result = await DiagService.OpenAsync<Contact>(
                                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                                    new Dictionary<string, object>
                                    {
                                    {"Model", model},
                                    {"Case", Model},
                                    {"AddContactPremiseIndicator", true}
                                    },
                                    new DialogOptions
                                    {
                                        Style = CSSClassConstants.DefaultDialogWidth,
                                        AutoFocusFirstElement = true,
                                        CloseDialogOnOverlayClick = true,
                                        Draggable = false,
                                        Resizable = true,
                                        ShowClose = true
                                    });

                                if (result is ContactGetListViewModel newContactModel)
                                {
                                    _newRecordCount += 1;

                                    TogglePendingSaveContacts(newContactModel, null);

                                    await ContactsGrid.Reload().ConfigureAwait(false);
                                }
                                else
                                {
                                    IsLoading = false;
                                }

                                break;
                            }
                        case FarmViewModel record:
                            {
                                if (record.FarmOwnerID != null)
                                {
                                    ContactGetListViewModel model = new()
                                    {
                                        HumanMasterID = (long)record.FarmOwnerID,
                                        FarmMasterID = record.FarmMasterID,
                                        ContactName = record.FarmOwnerName,
                                        ContactRelationshipTypeID = (long)PatientRelationshipTypeEnum.Other,
                                        ContactStatusID = (long)OutbreakContactStatusTypeEnum.Healthy,
                                        ContactTypeID = (long)OutbreakContactTypeEnum.Veterinary
                                    };

                                    result = await DiagService.OpenAsync<Contact>(
                                        Localizer.GetString(HeadingResourceKeyConstants
                                            .HumanDiseaseReportContactDetailsHeading),
                                        new Dictionary<string, object>
                                        {
                                        {"Model", model},
                                        {"Case", Model}
                                        },
                                        new DialogOptions
                                        {
                                            Style = CSSClassConstants.DefaultDialogWidth,
                                            AutoFocusFirstElement = true,
                                            CloseDialogOnOverlayClick = true,
                                            Draggable = false,
                                            Resizable = true,
                                            ShowClose = true
                                        });
                                }

                                if (result is ContactGetListViewModel newContactModel)
                                {
                                    _newRecordCount += 1;

                                    TogglePendingSaveContacts(newContactModel, null);

                                    await ContactsGrid.Reload().ConfigureAwait(false);
                                }
                                else
                                {
                                    IsLoading = false;
                                }

                                break;
                            }
                    }
                }
                else
                {
                    contactTracingFlexFormRequest.idfsFormType = (long)FlexibleFormTypeEnum.HumanOutbreakCaseContactTracing;
                    contactTracingFlexFormRequest.idfsFormTemplate = Model.Session.HumanContactTracingTemplateID;

                    var result = await DiagService.OpenAsync<SearchPerson>(
                        Localizer.GetString(HeadingResourceKeyConstants.CreateHumanCaseContactsHeading),
                        new Dictionary<string, object> { { "Mode", SearchModeEnum.SelectNoRedirect } },
                        new DialogOptions
                        {
                            Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result != null)
                    {
                        
                        if (result.ToString() != "Cancelled")
                        {
                            bool bCancelled = false;

                            if (result.ToString() == Localizer.GetString(ButtonResourceKeyConstants.AddButton))
                            {
                                var addResult = await DiagService.OpenAsync<PersonSections>(
                                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                                    new Dictionary<string, object>() { { "ShowInDialog", true } },
                                    new DialogOptions
                                    {
                                        Style = LaboratoryModuleCSSClassConstants.AddPersonDialog,
                                        AutoFocusFirstElement = true,
                                        CloseDialogOnOverlayClick = false,
                                        Draggable = false,
                                        Resizable = true
                                    });

                                if (addResult != null)
                                {
                                    if (addResult.ToString() != "Cancelled")
                                    {
                                        if (addResult is PersonViewModel newRecord)
                                        {
                                            result = addResult;
                                        }
                                    }
                                    else
                                    {
                                        bCancelled = true;
                                    }
                                }
                                else
                                {
                                    bCancelled = true;
                                }
                            }

                            if (!bCancelled)
                            {
                                var pvm = (PersonViewModel)result;

                                ContactGetListViewModel model = new()
                                {
                                    ContactRelationshipTypeID = (long)PatientRelationshipTypeEnum.Other,
                                    ContactStatusID = (long)OutbreakContactStatusTypeEnum.Healthy,
                                    ContactTypeID = (long)OutbreakContactTypeEnum.Human,
                                    ContactTracingFlexFormRequest = contactTracingFlexFormRequest,
                                    FarmName = null,
                                    HumanMasterID = (long)pvm.HumanMasterID,
                                    ContactName = pvm.FullName,
                                    ContactLocation = new LocationViewModel
                                    {
                                        IsHorizontalLayout = true,
                                        EnableAdminLevel1 = true,
                                        EnableAdminLevel2 = true,
                                        EnableAdminLevel3 = false,
                                        EnableApartment = false,
                                        EnableBuilding = false,
                                        EnableHouse = false,
                                        EnablePostalCode = false,
                                        EnableSettlement = false,
                                        EnableSettlementType = false,
                                        EnableStreet = true,
                                        ShowAdminLevel0 = false,
                                        ShowAdminLevel1 = true,
                                        ShowAdminLevel2 = true,
                                        ShowAdminLevel3 = false,
                                        ShowAdminLevel4 = false,
                                        ShowAdminLevel5 = false,
                                        ShowAdminLevel6 = false,
                                        ShowSettlementType = false,
                                        ShowStreet = false,
                                        ShowBuilding = false,
                                        ShowApartment = false,
                                        ShowElevation = false,
                                        ShowHouse = true,
                                        ShowLatitude = false,
                                        ShowLongitude = false,
                                        ShowMap = false,
                                        ShowBuildingHouseApartmentGroup = false,
                                        ShowPostalCode = false,
                                        ShowCoordinates = false,
                                        IsDbRequiredAdminLevel0 = true,
                                        IsDbRequiredAdminLevel1 = true,
                                        IsDbRequiredAdminLevel2 = true,
                                        IsDbRequiredSettlement = false,
                                        IsDbRequiredSettlementType = false,
                                        AdminLevel0Value = Convert.ToInt64(CountryID)
                                    }
                                };

                                result = await DiagService.OpenAsync<Contact>(
                                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportContactDetailsHeading),
                                    new Dictionary<string, object>
                                    {
                                {"Model", model},
                                {"Case", Model},
                                {"AddContactPremiseIndicator", false}
                                    },
                                    new DialogOptions
                                    {
                                        Style = CSSClassConstants.DefaultDialogWidth,
                                        AutoFocusFirstElement = true,
                                        CloseDialogOnOverlayClick = true,
                                        Draggable = false,
                                        Resizable = true,
                                        ShowClose = true
                                    });
                                if (result != null)
                                {
                                    if (result.ToString() != "Cancelled")
                                    {
                                        if (result is ContactGetListViewModel newContactModel)
                                        {
                                            _newRecordCount += 1;

                                            TogglePendingSaveContacts(newContactModel, null);

                                            await ContactsGrid.Reload().ConfigureAwait(false);
                                        }
                                        else
                                        {
                                            IsLoading = false;
                                        }

                                        if (Model.PendingSaveContacts.First().ContactTypeID == OutbreakCaseTypes.Human)
                                        {
                                            await JsRuntime.InvokeAsync<string>("SetContactsData", Model.PendingSaveContacts);
                                        }
                                    }
                                }
                            }
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

        #endregion

        #region Edit Contact Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="contact"></param>
        protected async Task OnEditContactClick(object contact)
        {
            try
            {
                if (((ContactGetListViewModel)contact).ContactTracingFlexFormRequest is {idfsFormTemplate: { }})
                {
                    var formTemplateId = ((ContactGetListViewModel) contact).ContactTracingFlexFormRequest
                        .idfsFormTemplate;
                    if (formTemplateId != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((ContactGetListViewModel) contact).ContactTracingObservationParameters,
                            idfsFormTemplate = (long) formTemplateId,
                            idfObservation = ((ContactGetListViewModel) contact).ContactTracingFlexFormRequest.idfObservation,
                            User = ((ContactGetListViewModel) contact).ContactTracingFlexFormRequest.User
                        };

                        if (flexFormRequest.idfsFormTemplate != 0 && flexFormRequest.idfsFormTemplate != null)
                        {
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            ((ContactGetListViewModel)contact).ContactTracingFlexFormRequest.idfObservation =
                                flexFormResponse.idfObservation;
                            ((ContactGetListViewModel)contact).ContactTracingObservationID = flexFormResponse.idfObservation;

                            await InvokeAsync(StateHasChanged);

                            ((ContactGetListViewModel)contact).ContactTracingObservationID = flexFormResponse.idfObservation;
                        }
                    }
                }

                var result = await DiagService.OpenAsync<Contact>(
                    Localizer.GetString(HeadingResourceKeyConstants.OutbreakContactsContactDetailsHeading),
                    new Dictionary<string, object>
                    {
                        {"Model", ((ContactGetListViewModel) contact).ShallowCopy()},
                        {"Case", Model}
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
                    if (Model.Contacts.Any(x =>
                            x.CaseContactID == ((ContactGetListViewModel) result).CaseContactID))
                    {
                        var index = Model.Contacts.IndexOf((ContactGetListViewModel) contact);
                        Model.Contacts[index] = model;

                        TogglePendingSaveContacts(model, (ContactGetListViewModel) contact);
                    }

                    await ContactsGrid.Reload().ConfigureAwait(false);
                    
                    if (Model.Contacts.First().ContactTypeID == OutbreakCaseTypes.Human && VeterinaryDiseaseReport is null)
                    {
                        await JsRuntime.InvokeAsync<string>("SetContactsData", Model.Contacts);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
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
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.Contacts.Any(
                                x => x.CaseContactID == ((ContactGetListViewModel) contact).CaseContactID))
                        {
                            if (((ContactGetListViewModel) contact).CaseContactID <= 0)
                            {
                                Model.Contacts.Remove((ContactGetListViewModel) contact);
                                Model.PendingSaveContacts.Remove((ContactGetListViewModel) contact);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((ContactGetListViewModel) contact).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.Contacts.Remove((ContactGetListViewModel) contact);

                                TogglePendingSaveContacts(result, (ContactGetListViewModel) contact);
                            }
                        }

                        await ContactsGrid.Reload().ConfigureAwait(false);
                        
                        if (Model.Contacts is not null && Model.Contacts.Any(x => x.ContactTypeID == OutbreakCaseTypes.Human) && VeterinaryDiseaseReport is null)
                        {
                            await JsRuntime.InvokeAsync<string>("SetContactsData", Model.Contacts);
                        }

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
            Model.ContactsSectionValidIndicator = true;

            if (!Model.ContactsSectionValidIndicator)
                return Model.ContactsSectionValidIndicator = true;

            foreach (var contact in Model.Contacts)
            {
                if (contact.ContactTracingFlexFormRequest?.idfsFormTemplate == null || contact.ContactTracingFlexFormRequest?.idfsFormTemplate == 0) continue;
                FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                {
                    Answers = contact.ContactTracingObservationParameters,
                    idfsFormTemplate = (long) contact.ContactTracingFlexFormRequest.idfsFormTemplate,
                    idfObservation = contact.ContactTracingFlexFormRequest.idfObservation,
                    User = contact.ContactTracingFlexFormRequest.User
                };

                if (flexFormRequest.idfsFormTemplate != 0 && flexFormRequest.idfsFormTemplate != null)
                {
                    var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                    contact.ContactTracingFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                    contact.ContactTracingObservationID = flexFormResponse.idfObservation;

                    await InvokeAsync(StateHasChanged);

                    contact.ContactTracingObservationID = flexFormResponse.idfObservation;
                }
            }

            return Model.ContactsSectionValidIndicator = true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            //TODO: change validation once flex form is ready to go.
            Model.ContactsSectionValidIndicator = true; // Form.EditContext.Validate();

            return Model.ContactsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.Contacts = null;
            ContactsGrid.Reload();
        }

        #endregion

        #endregion
    }
}