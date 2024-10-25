using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class DiseaseReportsBase : ParentComponent, IDisposable
    {
        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        #region Dependencies

        [Inject]
        private ILogger<DiseaseReportsBase> Logger { get; set; }

        #endregion Dependencies

        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool isLoading;
        protected int count = 0;

        protected RadzenDataGrid<ActiveSurveillanceSessionDiseaseReportsResponseModel> _diseaseReportsGrid;

        #endregion Globals

        #region Grid Reorder Col Chooser

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        protected override void OnInitialized()
        {
            _logger = Logger;

            gridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceSessionDisease");

            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, _diseaseReportsGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
                index = gridExtension.FindColumnOrder(columnName);
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
                visible = gridExtension.GetColumnVisibility(columnName);
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
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion Grid Reorder Col Chooser

        protected async Task LoadDiseaseReportsGridView(LoadDataArgs args, bool bInitialLoad = true)
        {
            try
            {
                isLoading = true;
                authenticatedUser = TokenService.GetAuthenticatedUser();
                count = 0;

                if (bInitialLoad && IdfMonitoringSession != null)
                {
                    var request = new ActiveSurveillanceSessionDiseaseReportsRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SortColumn = "SampleTypeName",
                        SortOrder = "ASC",
                        UserSiteID = long.Parse(authenticatedUser.SiteId),
                        UserOrganizationID = long.Parse(authenticatedUser.Institution),
                        UserEmployeeID = long.Parse(authenticatedUser.EIDSSUserId),
                        SessionKey = IdfMonitoringSession
                    };

                    model.DiseaseReports.List = await HumanActiveSurveillanceSessionClient.GetActiveSurveillanceDiseaseReportsListAsync(request, token);
                    count = model.DiseaseReports.List.Count();
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch cancellation or timeout exception
                if (source?.IsCancellationRequested == true)
                {
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
            //initialize the grid so that it displays 'No records message'
            isLoading = false;
        }

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void SendReportLink(long id)
        {
            NavManager.NavigateTo($"Human/HumanDiseaseReport/LoadDiseaseReport?caseId={id}&isEdit=True&readOnly=True&StartIndex=9", true);
        }
    }
}