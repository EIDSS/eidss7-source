using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
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
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class OutbreakCaseListBase : FarmBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<OutbreakCaseListBase> Logger { get; set; }

        #endregion Dependencies



        #region Member Variables

        protected int OutbreakCaseCount;
        protected int OutbreakCaseQueryCount;
        protected int OutbreakCaseLastDatabasePage;
        protected int OutbreakCaseNewRecordCount;
        protected bool IsLoading;
        protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> OutbreakCaseGrid;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "ReportID";

        #endregion Constants

        #endregion Globals

        #region Methods

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
            try
            {
                _source?.Cancel();
                _source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task LoadOutbreakGridView(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.FarmMasterID != null)
                {
                    int page,
                        pageSize = 10;

                    page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.OutbreakCases is null)
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
                            sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue ? args.Sorts.FirstOrDefault().SortOrder.Value.ToString() : SortConstants.Descending;
                        }

                        var request = new VeterinaryDiseaseReportSearchRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            FarmMasterID = StateContainer.FarmMasterID.Value,
                            OutbreakCasesIndicator = true,
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            IncludeSpeciesListIndicator = true,
                            ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel) ? true : false,
                            UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                            UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                            UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                            OutbreakCaseReportOnly = 1
                        };

                        StateContainer.OutbreakCases = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, _token);
                        StateContainer.OutbreakCases = StateContainer.OutbreakCases.DistinctBy(r => r.ReportID).ToList();
                        OutbreakCaseQueryCount = !StateContainer.OutbreakCases.Any() ? 0 : StateContainer.OutbreakCases.First().TotalRowCount;
                    }
                    else
                        OutbreakCaseQueryCount = !StateContainer.OutbreakCases.Any() ? 0 : StateContainer.OutbreakCases.First().TotalRowCount;

                    OutbreakCaseCount = OutbreakCaseQueryCount + OutbreakCaseNewRecordCount;

                    OutbreakCaseLastDatabasePage = Math.DivRem(OutbreakCaseCount, pageSize, out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0)
                        OutbreakCaseLastDatabasePage += 1;

                    OutbreakCaseLastDatabasePage = page;
                    IsLoading = false;
                }
                else
                {
                    StateContainer.OutbreakCases = new List<VeterinaryDiseaseReportViewModel>();
                    OutbreakCaseCount = 0;
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

        #endregion Methods
    }
}