using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;
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
using static System.GC;
using static System.Int32;
using static System.String;

namespace EIDSS.Web.Components.Human.Person
{
    public class OutbreakCaseListBase : PersonBaseComponent, IDisposable
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
        protected RadzenDataGrid<CaseGetListViewModel> OutbreakCaseGrid;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "EIDSSCaseID";

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
                if (StateContainer.HumanMasterID != null)
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

                        // test edit
                        var request = new OutbreakCaseListRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            HumanMasterID = StateContainer.HumanMasterID,
                            SearchTerm = null,
                            TodaysFollowUpsIndicator = false,
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };

                        StateContainer.OutbreakCases = await OutbreakClient.GetCasesList(request);
                        //OutbreakCaseQueryCount = !StateContainer.OutbreakCases.Any() ? 0 : StateContainer.OutbreakCases.First().TotalRowCount;
                        OutbreakCaseQueryCount = StateContainer.OutbreakCases.Count;
                    }
                    else
                    {
                        //OutbreakCaseQueryCount = !StateContainer.OutbreakCases.Any() ? 0 : StateContainer.OutbreakCases.First().TotalRowCount;
                        OutbreakCaseQueryCount = StateContainer.OutbreakCases.Count;
                    }

                    OutbreakCaseCount = OutbreakCaseQueryCount + OutbreakCaseNewRecordCount;

                    OutbreakCaseLastDatabasePage = Math.DivRem(OutbreakCaseCount, pageSize, out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0)
                        OutbreakCaseLastDatabasePage += 1;

                    OutbreakCaseLastDatabasePage = page;
                    IsLoading = false;
                }
                else
                {
                    StateContainer.OutbreakCases = new List<CaseGetListViewModel>();
                    OutbreakCaseCount = 0;
                    StateContainer.IsOutbreakReportHidden = true;
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

        #region Edit Case Button Click Event

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
                //var outbreakCase = (CaseGetListViewModel)outbreakCase;

                var outbreakTypeId = ((CaseGetListViewModel)outbreakCase).OutbreakTypeID;
                if (outbreakTypeId == null) return;
                
                var path = (OutbreakTypeEnum)outbreakTypeId switch
                {
                    OutbreakTypeEnum.Human => "Outbreak/HumanCase/Edit",
                    OutbreakTypeEnum.Veterinary => "Outbreak/OutbreakCases/VeterinaryDetails",
                    _ => Empty
                };
                
                var query = $"?outbreakId={((CaseGetListViewModel)outbreakCase).EIDSSOutbreakID}&caseId={((CaseGetListViewModel)outbreakCase).CaseID}" + (readOnly ? "&readOnly=true" : string.Empty);
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
    }
}