#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
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

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class DiseaseReportListBase : FarmBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DiseaseReportListBase> Logger { get; set; }

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
        protected bool AddLivestockDiseaseReportButtonDisabled;
        protected bool AddAvianDiseaseReportButtonDisabled;
        protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> DiseaseReportGrid;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "ReportID";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            return base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (StateContainer.SelectedFarmTypes is not null)
            {
                if (StateContainer.SelectedFarmTypes.Any())
                {
                    if (StateContainer.SelectedFarmTypes.Count() == 2)
                    {
                        AddLivestockDiseaseReportButtonDisabled =
                            !StateContainer.VeterinaryDiseaseResultPermissions.Create;
                        AddAvianDiseaseReportButtonDisabled = !StateContainer.VeterinaryDiseaseResultPermissions.Create;
                    }
                    else
                    {
                        switch (StateContainer.SelectedFarmTypes.First())
                        {
                            case HACodeBaseReferenceIds.Avian:
                                AddLivestockDiseaseReportButtonDisabled = true;
                                AddAvianDiseaseReportButtonDisabled =
                                    !StateContainer.VeterinaryDiseaseResultPermissions.Create;
                                break;
                            case HACodeBaseReferenceIds.Livestock:
                                AddLivestockDiseaseReportButtonDisabled =
                                    !StateContainer.VeterinaryDiseaseResultPermissions.Create;
                                AddAvianDiseaseReportButtonDisabled = true;
                                break;
                        }
                    }
                }
            }

            await InvokeAsync(StateHasChanged);

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadDiseaseReportGridView(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.FarmMasterID != null)
                {
                    const int pageSize = 10;

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
                                sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue
                                    ? args.Sorts.FirstOrDefault()?.SortOrder.Value.ToString()
                                    : SortConstants.Descending;
                            }

                            var request = new VeterinaryDiseaseReportSearchRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                FarmMasterID = StateContainer.FarmMasterID.Value,
                                Page = page,
                                PageSize = pageSize,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                IncludeSpeciesListIndicator = true,
                                ApplySiteFiltrationIndicator =
                                    _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
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
                        {
                            DiseaseReportDatabaseQueryCount = StateContainer.DiseaseReports != null && !StateContainer.DiseaseReports.Any()
                                ? 0
                                : StateContainer.DiseaseReports.First().TotalRowCount;
                        }

                        DiseaseReportCount = DiseaseReportDatabaseQueryCount + DiseaseReportNewRecordCount;

                        DiseaseReportLastDatabasePage = Math.DivRem(DiseaseReportDatabaseQueryCount, pageSize,
                            out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0)
                            DiseaseReportLastDatabasePage += 1;

                        DiseaseReportLastDatabasePage = page;
                    }

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

        #endregion

        #region Add and Edit Disease Reports

        /// <summary>
        /// </summary>
        /// <param name="farmMasterKey"></param>
        /// <param name="reportKey"></param>
        /// <param name="caseType"></param>
        /// <param name="isReview"></param>
        protected async Task OnOpenEdit(long? farmMasterKey, long reportKey, long? caseType, bool isReview = false)
        {
            await OpenDiseaseReport(caseType, farmMasterKey, reportKey, false, false, isReview );
        }

        /// <summary>
        /// </summary>
        protected async Task OnAddLivestockDiseaseReportClick()
        {
            await OpenDiseaseReport((long)CaseTypeEnum.Livestock, StateContainer.FarmMasterID, null);
        }

        /// <summary>
        /// </summary>
        protected async Task OnAddAvianDiseaseReportClick()
        {
            await OpenDiseaseReport((long)CaseTypeEnum.Avian, StateContainer.FarmMasterID, null);
        }

        /// <summary>
        /// </summary>
        /// <param name="caseType"></param>
        /// <param name="farmId"></param>
        /// <param name="diseaseReportId"></param>
        /// <param name="isEdit"></param>
        /// <param name="isReadOnly"></param>
        /// <param name="isReview"></param>
        private async Task OpenDiseaseReport(long? caseType, long? farmId, long? diseaseReportId, bool isEdit = false, bool isReadOnly = false, bool isReview = false)
        {
            if (StateContainer.VeterinaryDiseaseResultPermissions.Create)
            {
                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                var query =
                    $"?reportCategoryTypeID={caseType}&farmID={farmId}&diseaseReportID={diseaseReportId}&isEdit={isEdit}&isReadOnly={isReadOnly}&isReview={isReview}";
                var uri = $"{NavManager.BaseUri}{path}{query}";

                if (StateContainer.FarmInformationSectionChangedIndicator ||
                    StateContainer.FarmAddressSectionChangedIndicator)
                {
                    var result = await ShowWarningDialog(
                        MessageResourceKeyConstants
                            .ChangesMadeToTheRecordWillBeLostIfYouLeaveThePageDoYouWantToContinueMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close(result);

                        NavManager.NavigateTo(uri, true);
                    }
                    else
                        DiagService.Close(result);
                }
                else
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