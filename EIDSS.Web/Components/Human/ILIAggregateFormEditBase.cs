using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.ViewModels;
using static System.String;

namespace EIDSS.Web.Components.Human
{
    public class ILIAggregateFormEditBase : BaseComponent
    {
        #region Dependencies

        [Inject] private DialogService DialogService { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IILIAggregateFormClient ILIAggregateFormClient { get; set; }
        [Inject] private ITokenService TokenService { get; set; }
        [Inject] private ProtectedSessionStorage ProtectedSessionStore { get; set; }
        [Inject] private ILogger<ILIAggregateFormEditBase> Logger { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter] public string SimpleSearchString { get; set; }

        [Parameter] public ILIAggregatePageViewModel Header { get; set; }

        [Parameter] public EventCallback<ILIAggregateDetailViewModel> OnAddNewILIAggregateDetail { get; set; }

        #endregion Parameters

        #region Properties

        public bool IsLoading { get; set; }
        public bool IsDeleteDisabled { get; set; }
        public bool IsSaveDisabled { get; set; }
        public List<int> Years { get; set; } = new();
        public List<WeekDisplay> Weeks { get; set; } = new();

        #endregion Properties

        #region Member Variables

        public RadzenDataGrid<ILIAggregateDetailViewModel> ILIAggregateDetailsGrid;
        public int Count;
        public List<ILIAggregateDetailViewModel> ILIAggregateDetails;
        public IEnumerable<OrganizationGetListViewModel> Hospitals;
        private string _newFormId;

        #endregion Member Variables

        #region Methods

        protected override void OnInitialized()
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _logger = Logger;

            base.OnInitialized();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await ProtectedSessionStore.DeleteAsync("ILIAggregateDetails").ConfigureAwait(false);

                for (var i = DateTime.Now.Year; i >= 2000; i--) Years.Add(i);

                await UpdateWeekNumbers();
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            ProtectedSessionStore.DeleteAsync("ILIAggregateDetails");
        }

        public async Task Reset()
        {
            ILIAggregateDetailsGrid.Reset();
            await ILIAggregateDetailsGrid.FirstPage(true);
        }

        public async Task LoadData(LoadDataArgs args)
        {
            IsLoading = true;

            try
            {
                if (IsNullOrEmpty(Header.FormID)) IsDeleteDisabled = true;

                var result = await ProtectedSessionStore.GetAsync<List<ILIAggregateDetailViewModel>>("ILIAggregateDetails");

                if (result.Value == null)
                {
                    IsLoading = true;
                    TokenService.GetAuthenticatedUser();
                    string sortColumn, sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "FormID";
                        sortOrder = EIDSSConstants.SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First().Property;
                        sortOrder = args.Sorts.First().SortOrder.HasValue ? args.Sorts.First().SortOrder?.ToString() : EIDSSConstants.SortConstants.Descending;
                    }

                    if (args.Top != null)
                    {
                        var request = new ILIAggregateFormDetailRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / 10,
                            PageSize = 10,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            IdfAggregateHeader = -1,
                            FormID = Header.FormID
                        };

                        ILIAggregateDetails = await ILIAggregateFormClient.GetILIAggregateDetailList(request);
                    }

                    await ProtectedSessionStore.SetAsync("ILIAggregateDetails", ILIAggregateDetails);
                    Count = ILIAggregateDetails.Count == 0 ? 0 : ILIAggregateDetails.First().TotalRowCount;
                }
                else
                {
                    Count = !result.Value.Any() ? 0 : result.Value.ToList().First().TotalRowCount;
                    ILIAggregateDetails = result.Value.Where(d => d.RowStatus == "0").ToList();
                    //Header.DetailsList = ILIAggregateDetails;
                }

                IsSaveDisabled = ILIAggregateDetails.Count == 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            IsLoading = false;
        }

        protected void OpenEdit(ILIAggregateDetailViewModel item)
        {
            try
            {
                ILIAggregateDetailsGrid.EditRow(item);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task SaveRow(ILIAggregateDetailViewModel item)
        {
            try
            {
                var hospital = Hospitals.FirstOrDefault(x => x.OrganizationKey == item.IdfHospital);
                if (hospital != null) item.HospitalName = hospital.FullName;
                await ILIAggregateDetailsGrid.UpdateRow(item);

                foreach (var detail in ILIAggregateDetails.Where(detail => detail.IdfAggregateDetail == item.IdfAggregateDetail))
                {
                    detail.IntAge0_4 = item.IntAge0_4;
                    detail.IntAge5_14 = item.IntAge5_14;
                    detail.IntAge15_29 = item.IntAge15_29;
                    detail.IntAge30_64 = item.IntAge30_64;
                    detail.IntAge65 = item.IntAge65;
                    detail.InTotalILI = item.InTotalILI;
                    detail.IntILISamples = item.IntILISamples;
                    detail.IntTotalAdmissions = item.IntTotalAdmissions;
                    await ProtectedSessionStore.SetAsync("ILIAggregateDetails", ILIAggregateDetails);
                    break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task DeleteRow(ILIAggregateDetailViewModel item)
        {
            try
            {
                ILIAggregateDetailViewModel itemToRemove = null;

                var result = await ProtectedSessionStore.GetAsync<List<ILIAggregateDetailViewModel>>("ILIAggregateDetails");

                if (result.Value != null)
                {
                    foreach (var detail in result.Value.Where(detail => detail.IdfAggregateDetail == item.IdfAggregateDetail))
                    {
                        if (detail.RowAction == "I")
                        {
                            itemToRemove = detail;
                            break;
                        }

                        detail.RowStatus = "1";
                        await ProtectedSessionStore.SetAsync("ILIAggregateDetails", result.Value);
                        break;
                    }

                    if (itemToRemove != null)
                    {
                        ILIAggregateDetails.Remove(itemToRemove);
                        await ProtectedSessionStore.SetAsync("ILIAggregateDetails", ILIAggregateDetails);
                    }

                    await ILIAggregateDetailsGrid.Reload();
                }
                else
                {
                    ILIAggregateDetailsGrid.CancelEditRow(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void CancelEdit(ILIAggregateDetailViewModel item)
        {
            try
            {
                ILIAggregateDetailsGrid.CancelEditRow(item);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetHospitals()
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = Convert.ToInt32(AccessoryCodeEnum.Human),
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Hospital
                };

                var lstOrganizationsAdv = await OrganizationClient.GetOrganizationAdvancedList(request);
                var hospitalList = lstOrganizationsAdv.Select(orgAdv => new OrganizationGetListViewModel { OrganizationKey = orgAdv.idfOffice, FullName = orgAdv.FullName }).ToList();

                Hospitals = hospitalList;

                await ProtectedSessionStore.SetAsync("Hospitals", Hospitals);
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task OpenAddModal()
        {
            try
            {
                var result = await DialogService.OpenAsync<ILIAggregateAddModal>(Localizer.GetString(HeadingResourceKeyConstants.AddRecordModalHeading), //"Add Record",
                    null, new DialogOptions { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext)result).Validate())
                {
                    await OnAddNewILIAggregateDetail.InvokeAsync(result as ILIAggregateDetailViewModel);

                    var newRecord = (ILIAggregateDetailViewModel)result.Model;
                    newRecord.RowAction = "I";
                    newRecord.RowStatus = "0";
                    newRecord.RowId = Convert.ToInt64(DateTime.Now.Ticks);
                    newRecord.IdfAggregateHeader = Header.IdfAggregateHeader;

                    List<ILIAggregateDetailViewModel> lstILITable = new();
                    lstILITable = ILIAggregateDetails;
                    lstILITable.Add(newRecord);
                    ILIAggregateDetails = lstILITable;

                    var hospitalsSession = await ProtectedSessionStore.GetAsync<IEnumerable<OrganizationGetListViewModel>>("Hospitals");

                    if (hospitalsSession.Value == null)
                    {
                        await GetHospitals();
                        var h = Hospitals.FirstOrDefault(x => x.OrganizationKey == newRecord.IdfHospital);
                        if (h != null)
                        {
                            newRecord.HospitalName = h.FullName;
                        }
                    }
                    else
                    {
                        var h = hospitalsSession.Value.FirstOrDefault(x => x.OrganizationKey == newRecord.IdfHospital);
                        if (h != null)
                        {
                            newRecord.HospitalName = h.FullName;
                        }
                    }

                    var totalRowCount = ILIAggregateDetails.Max(x => x.TotalRowCount);
                    foreach (var d in ILIAggregateDetails)
                    {
                        d.TotalRowCount = totalRowCount + 1; //d.TotalRowCount++;
                    }

                    await ProtectedSessionStore.SetAsync("ILIAggregateDetails", ILIAggregateDetails);
                    await ILIAggregateDetailsGrid.Reload();
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task SaveAll()
        {
            ILIAggregateSaveRequestModel request = new();
            Events = new List<EventSaveRequestModel>();

            try
            {
                request.StrFormId = Header.FormID;
                request.IdfEnteredBy = Convert.ToInt64(authenticatedUser.PersonId);
                request.IdfsSite = Convert.ToInt64(authenticatedUser.SiteId);
                request.IntYear = Header.Year;
                request.IntWeek = Header.Week;
                request.RowStatus = 0;
                request.AuditUserName = authenticatedUser.UserName;
                request.DatStartDate = FirstDateOfWeek(Header.Year, Header.Week, -4);
                request.DatFinishDate = FirstDateOfWeek(Header.Year, Header.Week, 2);

                if (IsNullOrEmpty(Header.FormID))
                {
                    request.IdfAggregateHeader = -1;

                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                      request.IdfsSite
                        ? SystemEventLogTypes.NewILIAggregateFormWasCreatedAtYourSite
                        : SystemEventLogTypes
                            .NewILIAggregateFormWasCreatedAtAnotherSite;
                    Events.Add(await CreateEvent(0,
                            null, eventTypeId, request.IdfsSite, null)
                        .ConfigureAwait(false));
                }
                else request.IdfAggregateHeader = Header.IdfAggregateHeader;

                var result = await ProtectedSessionStore.GetAsync<List<ILIAggregateDetailViewModel>>("ILIAggregateDetails");

                if (result.Value != null)
                {
                    foreach (var d in result.Value.Where(d => d.RowId == 0))
                    {
                        d.RowId = d.IdfAggregateDetail;
                    }

                    request.ILITables = System.Text.Json.JsonSerializer.Serialize(result.Value);
                }

                request.Events = JsonConvert.SerializeObject(Events);

                var response = await ILIAggregateFormClient.SaveILIAggregate(request);

                _newFormId = response.StrFormId;

                DiagService.OnClose -= HandleSaveSuccessResponse;
                DiagService.OnClose += HandleSaveSuccessResponse;
                await InvokeAsync(() =>
                {
                    _ = ShowSaveSuccessMessage(_newFormId);
                    StateHasChanged();
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        // -4 to get Sunday, +2 to get Saturday
        private static DateTime FirstDateOfWeek(int year, int weekOfYear, int offSet)
        {
            var jan1 = new DateTime(year, 1, 1);
            var daysOffset = DayOfWeek.Thursday - jan1.DayOfWeek;

            // Use first Thursday in January to get first week of the year as
            // it will never be in Week 52/53
            var firstThursday = jan1.AddDays(daysOffset);
            var cal = CultureInfo.CurrentCulture.Calendar;
            var firstWeek = cal.GetWeekOfYear(firstThursday, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);

            var weekNum = weekOfYear;
            // As we're adding days to a date in Week 1,
            // we need to subtract 1 in order to get the right date for week #1
            if (firstWeek == 1)
            {
                weekNum -= 1;
            }

            // Using the first Thursday as starting week ensures that we are starting in the right year
            // then we add number of weeks multiplied with days
            var result = firstThursday.AddDays(weekNum * 7);

            // Subtract 4 days from Thursday to get Sunday
            return result.AddDays(offSet);
        }

        public Task UpdateWeekNumbers()
        {
            Weeks.Clear();
            for (var i = 1; i <= 52; i++)
            {
                var startDate = FirstDateOfWeek(Header.Year, i, -4);
                var endDate = FirstDateOfWeek(Header.Year, i, 2);

                Weeks.Add(new WeekDisplay
                {
                    WeekNumber = i,
                    WeekDate = $"Week {i}  |  {startDate.ToShortDateString()} - {endDate.ToShortDateString()}"
                });
            }

            return Task.CompletedTask;
        }

        public async Task DeleteAll()
        {
            try
            {
                DiagService.OnClose -= HandleDeleteResponse;
                DiagService.OnClose += HandleDeleteResponse;
                await ShowConfirmDeleteMessage();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task ShowConfirmDeleteMessage()
        {
            try
            {
                var buttons = new List<DialogButton>();

                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);

                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async void HandleDeleteResponse(dynamic result)
        {
            result = (DialogReturnResult)result;
            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                try
                {
                    //fire delete
                    var response = await ILIAggregateFormClient.DeleteILIAggregateHeader(Header.IdfAggregateHeader, authenticatedUser.UserName);

                    // delete from session
                    await ProtectedSessionStore.DeleteAsync("ILIAggregateDetails");

                    //show delete success modal?

                    //redirect
                    NavManager.NavigateTo($"Human/ILIAggregateSearchPage/Index", true);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                // just close modal
                DiagService.OnClose -= HandleDeleteResponse;
                DiagService.Close();
            }
        }

        protected async Task ShowSaveSuccessMessage(string newFormId)
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

                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.LocalizedMessage),
                        $"{Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)} (Form ID: {newFormId})"
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void HandleSaveSuccessResponse(dynamic result)
        {
            try
            {
                result = (DialogReturnResult)result;

                if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    NavManager.NavigateTo($"Human/ILIAggregateAddEditPage?queryData={_newFormId}", true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task Cancel()
        {
            try
            {
                DiagService.OnClose -= HandleCancelResponse;
                DiagService.OnClose += HandleCancelResponse;
                await ShowCancelMessage();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task ShowCancelMessage()
        {
            var buttons = new List<DialogButton>();

            var yesButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);

            var noButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };
            buttons.Add(noButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)}
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        protected async void HandleCancelResponse(dynamic result)
        {
            result = (DialogReturnResult)result;
            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                try
                {
                    // delete from session
                    await ProtectedSessionStore.DeleteAsync("ILIAggregateDetails");

                    //redirect
                    NavManager.NavigateTo($"Human/ILIAggregateSearchPage/Index", true);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                // just close modal
                DiagService.OnClose -= HandleCancelResponse;
                DiagService.Close();
            }
        }

        public void CalculateTotalILI(ILIAggregateDetailViewModel ag)
        {
            ag.InTotalILI = (ag.IntAge0_4 ?? 0)
                + (ag.IntAge5_14 ?? 0)
                + (ag.IntAge15_29 ?? 0)
                + (ag.IntAge30_64 ?? 0)
                + (ag.IntAge65 ?? 0);
        }

        protected async Task PrintReport()
        {
            try
            {
                if (Header is { FormID: { } })
                {
                    var reportTitle = Localizer.GetString(HeadingResourceKeyConstants
                        .ILIAggregateDetailsILIAggregateDetailsHeading);

                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("FormID", Header.FormID);
                    reportModel.AddParameter("LegacyFormID", Header.LegacyFormID ?? "");
                    reportModel.AddParameter("AggregateHeaderID", Header.IdfAggregateHeader.ToString());
                    reportModel.AddParameter("HospitalID", "");
                    if (Header.WeeksFrom is not null)
                        reportModel.AddParameter("StartDate", Header.WeeksFrom.Value.ToString("d", cultureInfo));
                    if (Header.WeeksTo is not null)
                        reportModel.AddParameter("FinishDate", Header.WeeksTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("SortColumn", "FormID");
                    reportModel.AddParameter("SortOrder", EIDSSConstants.SortConstants.Descending);
                    reportModel.AddParameter("PageSize", (int.MaxValue - 1).ToString());
                    reportModel.AddParameter("PageNumber", "1");
                    reportModel.AddParameter("ApplySiteFiltrationIndicator", "0");
                    reportModel.AddParameter("UserEmployeeID", authenticatedUser.PersonId);
                    reportModel.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                    reportModel.AddParameter("UserOrganization", authenticatedUser.OfficeId.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        reportTitle,
                        new Dictionary<string, object>
                        {
                             {"ReportName", "ILIAggregateReport"},
                             {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px",
                            //Height = "600px"
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }

    public class WeekDisplay
    {
        public int WeekNumber { get; set; }
        public string WeekDate { get; set; }
    }

    #endregion Methods
}