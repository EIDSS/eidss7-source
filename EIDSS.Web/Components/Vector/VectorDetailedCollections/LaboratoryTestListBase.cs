using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Web.Components.Vector.Common;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class LaboratoryTestListBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<LaboratoryTestListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Properties

        protected RadzenDataGrid<USP_VCTS_LABTEST_GetListResponseModel> LaboratoryTestListGrid { get; set; }
        protected bool IsLoading { get; set; }
        protected int LaboratoryTestsCount { get; set; } = 1;

        #endregion Properties

        #region Constants

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecyle Methods

        protected override void OnInitialized()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;
            
            VectorSessionStateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);

                await JsRuntime.InvokeVoidAsync("DetailedCollectionLaboratoryTests.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            base.Dispose(disposing);
        }

        #endregion Lifecyle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "VectorDetailedCollectionKey" && VectorSessionStateContainer.SelectedVectorTab == (int)VectorTabs.VectorSessionTab)
            {
                await LaboratoryTestListGrid.Reload();
            }
        }

        #endregion State Container Events

        #region Load Data

        /// <summary>
        ///
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadTestGrid(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.VectorDetailedCollectionKey != null)
                {
                    var pageSize = LaboratoryTestListGrid.PageSize != 0 ? LaboratoryTestListGrid.PageSize : 10;
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (VectorSessionStateContainer.LaboratoryTestsList is null)
                    {
                        VectorSessionStateContainer.LaboratoryTestsList = new List<USP_VCTS_LABTEST_GetListResponseModel>();
                        IsLoading = true;
                    }

                    IsLoading = true;

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                        }

                        var request = new USP_VCTS_LABTEST_GetListRequestModel()
                        {
                            idfVectorSurveillanceSession = (long)VectorSessionStateContainer.VectorSessionKey,
                            idfVector = VectorSessionStateContainer.VectorDetailedCollectionKey.GetValueOrDefault(),
                            LangID = GetCurrentLanguage()
                        };

                        VectorSessionStateContainer.LaboratoryTestsList = await VectorClient.GetVectorLabTestsAsync(request, _token);
                        LaboratoryTestsCount = !VectorSessionStateContainer.LaboratoryTestsList.Any() ? 0 : VectorSessionStateContainer.LaboratoryTestsList.First().TotalRowCount;

                        IsLoading = false;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            return await Task.FromResult(true);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}