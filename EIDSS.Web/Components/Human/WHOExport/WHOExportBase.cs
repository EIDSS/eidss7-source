using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Areas.Human.ViewModels.WHOExport;
using EIDSS.Web.Components.Shared;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.WHOExport
{
    public class WHOExportBase : SearchComponentBase<WHOExportViewModel>, IDisposable
    {
        #region Protected and Public Fields
        //protected RadzenAccordion _radAccordion;
        protected RadzenDataGrid<WHOExportGetListViewModel> _grid;
        protected RadzenTemplateForm<WHOExportViewModel> form;
        protected WHOExportViewModel model;

        #endregion

        #region Private Fields and Properties

        //private bool searchSubmitted;

        //private CancellationTokenSource source;
        //private CancellationToken token;

        //protected RadzenDataGrid<WHOExportListViewModel> grid;
        protected RadzenTemplateForm<WHOExportViewModel> Form { get; set; }
        protected IEnumerable<FilteredDiseaseGetListViewModel> DiseaseList { get; set; }
        protected UserPermissions exportPermissions;
        protected UserPermissions accessToHumanDiseaseReportDataPermissions;
        protected UserPermissions accessToOutbreakDataPermissions;
        protected bool disableGenerateButton;
        protected bool showGrid;

        #endregion Private Fields and Properties

        #region Parameters
        [Inject] private IWHOExportClient WHOExportClient { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        #endregion

        #region Dependency Injection

        [Inject]
        private ILogger<WHOExportViewModel> Logger { get; set; }

        #endregion

        #region Lifecycle Methods
        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            _logger = Logger;

            //initialize model
            InitializeModel();

            //reset the cancellation token
            source = new();
            token = source.Token;

            exportPermissions = GetUserPermissions(PagePermission.CanImport_ExportData);
            accessToHumanDiseaseReportDataPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            accessToOutbreakDataPermissions = GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData);

            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.WHOExportSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult.Success && indicatorResult.Value;
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<WHOExportViewModel>(SearchPersistenceKeys.WHOExportSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {

                    isLoading = true;

                    model.SearchCriteria = searchModel.SearchCriteria;
                    if (searchModel.SearchResults != null)
                    {
                        model.SearchResults = searchModel.SearchResults;
                        count = model.SearchResults.Count;

                        showGrid = true;
                    }

                    isLoading = false;
                }
            }
            else
            {
                //set grid for not loaded
                isLoading = false;
                showGrid = false;

                // set the defaults
                await SetDefaultsAsync();
            }
        }

        protected async Task HandleValidSubmit()
        {
            DateTime? dateFrom = model.SearchCriteria.DateFrom == null ? null : (DateTime)model.SearchCriteria.DateFrom;
            DateTime? dateTo = model.SearchCriteria.DateTo == null ? null : (DateTime)model.SearchCriteria.DateTo;
            //long? diseaseID = model.SearchCriteria.DiseaseID == null ? null : (long)model.SearchCriteria.DiseaseID;

            if (form.IsValid && dateFrom != null && dateTo != null)
            {
                searchSubmitted = true;
                showGrid = true;

                if (_grid != null) 
                    await _grid.Reload();
            }
        }

        protected async Task CancelSearchClicked()
        {
            await CancelSearchAsync();
        }

        //protected override async Task OnAfterRenderAsync(bool firstRender)
        //{
        //    if (firstRender)
        //    {
        //        // Disease default to Measles
        //        if (DiseaseList != null)
        //            model.SearchCriteria.DiseaseID = DiseaseList.Where(x => x.DiseaseName == "Measles").ToList().FirstOrDefault().DiseaseID;
        //    }

        //    await base.OnAfterRenderAsync(firstRender);
        //}

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
        #endregion

        #region Protected Methods and Delegates

        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;
                    showSearchResults = true;

                    var request = new WHOExportRequestModel
                    {
                        LangID = GetCurrentLanguage(),
                        DateFrom = model.SearchCriteria.DateFrom,
                        DateTo = model.SearchCriteria.DateTo,
                        DiseaseID = model.SearchCriteria.DiseaseID,
                    };

                    //var result = new List<WHOExportGetListViewModel>();
                    var result = await WHOExportClient.GetWHOExportList(request);
                    if (source.IsCancellationRequested == false)
                    {
                        model.SearchResults = result;
                        count = model.SearchResults != null ? model.SearchResults.Count : 0;
                        _grid.PageSize = count;
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                }
                finally
                {
                    isLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                model.SearchResults = new List<WHOExportGetListViewModel>();
                count = 0;
                isLoading = false;
            }
        }


        protected async Task ExportAsync()
        {
            using MemoryStream memoryStream = new();
            using (TextWriter tw = new StreamWriter(memoryStream, Encoding.UTF8))
            {
                StringBuilder sb = new StringBuilder();
                if (model.SearchResults != null && model.SearchResults.Count > 0)
                {
                    int i = 0;
                    foreach (var row in model.SearchResults)
                    {
                        i = 0;
                        PropertyInfo[] props = row.GetType().GetProperties();

                        for (i = 0; i <= props.Count() - 3; i++)
                        {
                            if (props[i].GetValue(row) != null)
                            {
                                Type propertyType = props[i].PropertyType;
                                object targetType = (propertyType.IsGenericType == true && propertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)) == true) ? Nullable.GetUnderlyingType(propertyType) : propertyType;
                                if (targetType.GetType().Name == "RuntimeType" && ((Type)targetType).Name == "DateTime")
                                {
                                    sb.Append(DateTime.Parse(props[i].GetValue(row).ToString()).ToShortDateString() + "\t");
                                }
                                else
                                    sb.Append(props[i].GetValue(row).ToString() + "\t");
                            }
                            else
                            {
                                sb.Append("\t");
                            }
                        }

                        sb.AppendLine();
                    }

                    await tw.WriteAsync(sb.ToString());
                    await tw.FlushAsync();
                    memoryStream.Position = 0;
                }

                var bytes = memoryStream.ToArray();
                DateTime dt = (DateTime)model.SearchCriteria.DateFrom;
                String fileName = DiseaseList.Where(x => x.DiseaseID == model.SearchCriteria.DiseaseID).ToList().FirstOrDefault().DiseaseName + dt.Month.ToString() + dt.Year.ToString() + "Export.txt";
                await SaveAs(fileName, bytes);
            }
        }

        protected async Task OpenEdit(WHOExportGetListViewModel row)
        {
            long id = row.idfCase;
            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.WHOExportSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.WHOExportSearchModelKey, model);

            shouldRender = false;
            var uri = string.Empty;
            if (row.intSrcOutbreakRelated == 1 && row.strReportID != null)
            {
                id = long.Parse(row.strReportID);
                uri = $"{NavManager.BaseUri}Outbreak/OutbreakCases?queryData={id}";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                uri = $"{NavManager.BaseUri}Human/HumanDiseaseReport/LoadDiseaseReport?caseId={id}&isEdit=True&IsFromWHOExport=True";
                NavManager.NavigateTo(uri, true);
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {

            var request = new FilteredDiseaseRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType
                //,AdvancedSearchTerm = args.Filter
            };

            var list = await CrossCuttingClient.GetFilteredDiseaseList(request);
            if (request.LanguageId == "ka-GE")
                DiseaseList = list.Where(x => x.DiseaseName == "წითელა" || x.DiseaseName == "წითურა").ToList();
            else
                DiseaseList = list.Where(x => x.DiseaseName == "Measles" || x.DiseaseName == "Rubella").ToList();

            await InvokeAsync(StateHasChanged);
        }

        protected bool DisableEdit(WHOExportGetListViewModel model)
        {
            if (model.intSrcOutbreakRelated == 1)
            {
                if (accessToOutbreakDataPermissions.Write)
                    return false;
                else
                    return true;
            }
            else
            {
                if (accessToHumanDiseaseReportDataPermissions.Write)
                    return false;
                else
                    return true;
            }
        }

        public async Task SaveAs(string filename, byte[] data)
        {
            await JsRuntime.InvokeAsync<object>(
                "saveAsFile",
                filename,
                Convert.ToBase64String(data));
        }

        #endregion

        #region Private Methods

        private async Task SetDefaultsAsync()
        {
            var today = DateTime.Today;
            DateTime LastMonthLastDate;
            if (today.Day < DateTime.DaysInMonth(today.Year, today.Month))
                LastMonthLastDate = DateTime.Today.AddDays(0 - DateTime.Today.Day);
            else
                LastMonthLastDate = today;

            // Date From default to the first day of a last Completed calendar month
            model.SearchCriteria.DateFrom = LastMonthLastDate.AddDays(1 - LastMonthLastDate.Day);
            // Date To default to the last day of a last Completed calendar month
            model.SearchCriteria.DateTo = LastMonthLastDate;

            // Disease default to Measles
            if (DiseaseList == null)
            {
                var args = new LoadDataArgs();
                await GetDiseasesAsync(args);
                if (GetCurrentLanguage() == "ka-GE")
                    model.SearchCriteria.DiseaseID = DiseaseList.Where(x => x.DiseaseName == "წითელა").ToList().FirstOrDefault().DiseaseID;
                else
                    model.SearchCriteria.DiseaseID = DiseaseList.Where(x => x.DiseaseName == "Measles").ToList().FirstOrDefault().DiseaseID;
                await InvokeAsync(StateHasChanged);
            }
        }

        private void InitializeModel()
        {
            model = new WHOExportViewModel();
            model.Permissions = exportPermissions;
            disableGenerateButton = false;
        }
        #endregion
    }
}
