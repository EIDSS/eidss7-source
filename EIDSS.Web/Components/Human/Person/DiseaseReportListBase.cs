using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
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
    public class DiseaseReportListBase : PersonBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private new ILogger<DiseaseReportListBase> Logger { get; set; }

        #endregion

        #region Parameters

        #endregion

        #region Properties

        #endregion

        #region Member Variables

        protected int DiseaseReportCount;
        protected int DiseaseReportDatabaseQueryCount;
        protected int DiseaseReportLastDatabasePage;
        protected int DiseaseReportNewRecordCount;
        protected bool IsLoading;        
        protected RadzenDataGrid<HumanDiseaseReportViewModel> DiseaseReportGrid;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "ReportID";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;                        

            return base.OnInitializedAsync();
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Load Data Methods

        protected async Task LoadDiseaseReportGridView(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.HumanMasterID != null)
                {
                    var pageSize = 10;

                    if (args.Top != null)
                    {
                        var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                        if (StateContainer.DiseaseReports is null)
                            IsLoading = true;

                        if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                        {
                            string sortColumn,
                                sortOrder;

                            if (args.Sorts == null || args.Sorts.Any() == false)
                            {
                                sortColumn = DefaultSortColumn;
                                sortOrder = SortConstants.Descending;
                            }
                            else
                            {
                                sortColumn = args.Sorts.FirstOrDefault()?.Property;
                                sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue ? args.Sorts.FirstOrDefault()?.SortOrder?.ToString() : SortConstants.Descending;
                            }

                            var request = new HumanDiseaseReportSearchRequestModel()
                            {
                                LanguageId = GetCurrentLanguage(),                            
                                Page = page,
                                PageSize = pageSize,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,             
                                PatientID = StateContainer.HumanMasterID, 
                                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                                UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                                UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                                ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                            };                       

                            StateContainer.DiseaseReports = await HumanDiseaseReportClient.GetHumanDiseaseReports(request, _token);                        
                            DiseaseReportDatabaseQueryCount = !StateContainer.DiseaseReports.Any() ? 0 : StateContainer.DiseaseReports.First().RecordCount.GetValueOrDefault();
                        }
                        else if (StateContainer.DiseaseReports != null)
                            DiseaseReportDatabaseQueryCount =
                                StateContainer.DiseaseReports != null && !StateContainer.DiseaseReports.Any()
                                    ? 0
                                    : StateContainer.DiseaseReports.First().RecordCount.GetValueOrDefault();

                        DiseaseReportCount = DiseaseReportDatabaseQueryCount + DiseaseReportNewRecordCount;

                        DiseaseReportLastDatabasePage = Math.DivRem(DiseaseReportDatabaseQueryCount, pageSize, out int remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0)
                            DiseaseReportLastDatabasePage += 1;

                        DiseaseReportLastDatabasePage = page;
                    }

                    IsLoading = false;                                        
                }
                else
                {
                    StateContainer.DiseaseReports = new List<HumanDiseaseReportViewModel>();
                    DiseaseReportCount = 0;                    
                    StateContainer.IsDiseaseReportHidden = true;
                    IsLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add and Edit Disease Reports

        protected async Task OnOpenEdit(HumanDiseaseReportViewModel item)
        {
            await OpenDiseaseReport(StateContainer.HumanMasterID, item.ReportKey, true);
        }

        protected async Task OnOpenReadOnly(HumanDiseaseReportViewModel item)
        {
            await OpenDiseaseReport(StateContainer.HumanMasterID, item.ReportKey, true, true, 9);
        }

        protected async Task OnAddHumanDiseaseReportClick()
        {
            try
            {                
                if (ValidateMinimumPersonFields())
                {
                    authenticatedUser = _tokenService.GetAuthenticatedUser();
                    var response = await SavePerson();

                    if (response.ReturnCode == 0)
                    {
                        await OpenDiseaseReport(StateContainer.HumanMasterID, null);
                    }
                }               
            }            
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task OpenDiseaseReport(long? humanId, long? diseaseReportId, bool isEdit = false, bool readOnly = false, int startIndex = 1)
        {
            if (StateContainer.HumanDiseaseReportPermissions.Create)
            {
                const string path = "Human/HumanDiseaseReport/LoadDiseaseReport";
                var query =
                    $"?humanId={humanId}&caseId={diseaseReportId}&isEdit={isEdit}&readOnly={readOnly}&StartIndex={startIndex}";
                var uri = $"{NavManager.BaseUri}{path}{query}";

                NavManager.NavigateTo(uri, true);
            }
            else
            {
                await InsufficientPermissions();
            }
        }

        #endregion

        #endregion

    }
}