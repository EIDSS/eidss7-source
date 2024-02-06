using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DiseaseReportListBase : SurveillanceSessionBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DiseaseReportListBase> Logger { get; set; }

        [Inject] private IConfigurationClient ConfigurationClient { get; set; }

        [Inject] protected GridContainerServices GridContainerServices { get; set; }

        #endregion Dependencies
        
        #region Member Variables

        protected int DiseaseReportCount;
        protected int DiseaseReportDatabaseQueryCount;
        protected int DiseaseReportLastDatabasePage;
        protected int DiseaseReportNewRecordCount;
        protected bool IsLoading;
        protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> DiseaseReportGrid;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Properties

        public GridExtensionBase GridExtension { get; set; }

        #endregion Properties

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "ReportID";

        #endregion Constants

        #endregion Globals

        #region Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            _source = new CancellationTokenSource();
            _token = _source.Token;

            GridExtension = new GridExtensionBase();
            GridColumnLoad("VeterinarySurveillanceDiseaseReportGridColumnModule");

            return base.OnInitializedAsync();
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        protected async Task LoadDiseaseReportGridView(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.SessionKey != null)
                {
                    int page,
                        pageSize = 10;

                    page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.DiseaseReports is null)
                        IsLoading = true;

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                    {
                        string sortColumn,
                            sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = DEFAULT_SORT_COLUMN;
                            sortOrder = SortConstants.Descending;
                        }
                        else
                        {
                            sortColumn = args.Sorts.FirstOrDefault().Property;
                            sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue
                                ? args.Sorts.FirstOrDefault().SortOrder.Value.ToString()
                                : SortConstants.Descending;
                        }

                        var request = new VeterinaryDiseaseReportSearchRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            SessionKey = StateContainer.SessionKey.Value,
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            ApplySiteFiltrationIndicator =
                                _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel)
                                    ? true
                                    : false,
                            UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                            UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                            UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                            OutbreakCaseReportOnly = 0
                        };

                        StateContainer.DiseaseReports = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, _token);
                        StateContainer.DiseaseReports = StateContainer.DiseaseReports.DistinctBy(r => r.ReportID).ToList();
                        DiseaseReportDatabaseQueryCount = !StateContainer.DiseaseReports.Any()
                            ? 0
                            : StateContainer.DiseaseReports.First().TotalRowCount;
                    }
                    else
                        DiseaseReportDatabaseQueryCount = !StateContainer.DiseaseReports.Any()
                            ? 0
                            : StateContainer.DiseaseReports.First().TotalRowCount;

                    DiseaseReportCount = DiseaseReportDatabaseQueryCount + DiseaseReportNewRecordCount;

                    DiseaseReportLastDatabasePage = Math.DivRem(DiseaseReportDatabaseQueryCount, pageSize,
                        out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0)
                        DiseaseReportLastDatabasePage += 1;

                    DiseaseReportLastDatabasePage = page;
                    IsLoading = false;
                }
                else
                {
                    StateContainer.DiseaseReports = new List<VeterinaryDiseaseReportViewModel>();
                    DiseaseReportCount = 0;
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

        protected void SendReportLink(VeterinaryDiseaseReportViewModel diseaseReport)
        {
            var reportCategoryTypeId = StateContainer.ReportTypeID == ASSpeciesType.Livestock
                ? (long)CaseTypeEnum.Livestock
                : (long)CaseTypeEnum.Avian;
            var path = $"Veterinary/VeterinaryDiseaseReport/Details" +
                       $"?reportTypeId={CaseReportType.Active}" +
                       $"&farmId={diseaseReport.FarmMasterKey}" +
                       $"&diseaseReportId={diseaseReport.ReportKey}" +
                       $"&diseaseId={diseaseReport.DiseaseID}" +
                       $"&reportCategoryTypeId={reportCategoryTypeId}" +
                       $"&isReadOnly={true}" +
                       $"&isReview={true}";

            var uri = $"{NavManager.BaseUri}{path}";

            NavManager.NavigateTo(uri, true);
        }

        #region Grid Column Chooser

        protected void VeterinarySurveillanceDiseaseReportGridClickHandler()
        {
            GridColumnSave("VeterinarySurveillanceDiseaseReportGridColumnModule");
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, DiseaseReportGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = GridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = GridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion Grid Column Chooser

        #endregion Methods

    }
}