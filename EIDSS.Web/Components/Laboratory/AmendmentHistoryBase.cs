#region Usings

using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory;
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

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class AmendmentHistoryBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AmendmentHistoryBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long? TestId { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public int Count { get; set; }
        public IList<TestAmendmentsGetListViewModel> AmendmentHistory { get; set; }
        public RadzenDataGrid<TestAmendmentsGetListViewModel> AmendmentHistoryGrid;

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "AmendmentDate";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AmendmentHistoryBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AmendmentHistoryBase() : base(CancellationToken.None)
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

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

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

        #endregion

        #region Load Data Method

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadAmendmentHistoryData(LoadDataArgs args)
        {
            try
            {
                if (TestId == null)
                {
                    AmendmentHistory = new List<TestAmendmentsGetListViewModel>();
                }
                else
                {
                    var lastPage = 1;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / 10;

                    if (AmendmentHistory != null)
                    {
                        if (AmendmentHistory.Count > 0)
                            lastPage = AmendmentHistory.First().CurrentPage;
                    }
                    else
                    {
                        IsLoading = true;
                    }

                    if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / 10))
                        IsLoading = true;

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                    {
                        string sortColumn,
                            sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = DefaultSortColumn;
                            sortOrder = SortConstants.Ascending;
                        }
                        else
                        {
                            sortColumn = args.Sorts.First()?.Property;
                            sortOrder = args.Sorts.First().SortOrder.HasValue
                                ? args.Sorts.First().SortOrder?.ToString()
                                : SortConstants.Descending;
                        }

                        if (TestId != null)
                        {
                            var request = new TestAmendmentGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                TestID = (long) TestId,
                                Page = page,
                                PageSize = 10,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder
                            };

                            AmendmentHistory = await LaboratoryClient.GetTestAmendmentList(request, _token);
                        }

                        Count = !(AmendmentHistory ?? new List<TestAmendmentsGetListViewModel>()).Any()
                            ? 0
                            : (AmendmentHistory ?? new List<TestAmendmentsGetListViewModel>()).First().TotalRowCount;
                    }

                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}