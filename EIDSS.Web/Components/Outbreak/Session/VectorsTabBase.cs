#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels;
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
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Session
{
    public class VectorsTabBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<VectorsTabBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long OutbreakId { get; set; }
        [Parameter] public string EidssOutbreakId { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public IList<VectorGetListViewModel> VectorSessions { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        protected RadzenDataGrid<VectorGetListViewModel> VectorSessionsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }
        public string SearchTerm { get; set; }
        public long BottomAdminLevel { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private int _databaseQueryCount;
        private int _lastPage = 1;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "SessionID";

        #endregion

        #endregion

        #region Constructors

        public VectorsTabBase(CancellationToken token) : base(token)
        {
        }

        protected VectorsTabBase() : base(CancellationToken.None)
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

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            BottomAdminLevel =
                _tokenService.GetAuthenticatedUser().BottomAdminLevel; //19000002 is level 2, 19000003 is level 3, etc
            _userPermissions = GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
            CreatePermissionIndicator = _userPermissions.Create;
            WritePermissionIndicator = _userPermissions.Write;

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
                _source?.Cancel();
                _source?.Dispose();
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~VectorsTabBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadVectorSessionData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (VectorSessionsGrid.PageSize != 0)
                    pageSize = VectorSessionsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (VectorSessions is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        IsLoading = true;

                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        var request = new VectorGetListRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            OutbreakKey = OutbreakId,
                            SearchTerm = SearchTerm,
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };
                        VectorSessions = await OutbreakClient.GetVectorList(request, _token)
                            .ConfigureAwait(false);
                        var recordCount = VectorSessions.Any() ? VectorSessions.First().RecordCount : 0;
                        if (recordCount != null)
                            _databaseQueryCount = !VectorSessions.Any() ? 0 : (int) recordCount;
                    }
                    else if (VectorSessions != null)
                    {
                        _databaseQueryCount = VectorSessions.Count;
                    }

                    Count = _databaseQueryCount;

                    _lastPage = page;
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sessionKey"></param>
        /// <returns></returns>
        protected void SendReportLink(long sessionKey)
        {
            const string path = "Vector/VectorSurveillanceSession/Edit";
            var query = $"?sessionKey={sessionKey}&isReadOnly=true&outbreakKey=" + OutbreakId;
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        #endregion

        #region Add Vector Surveillance Session Button Click Event

        /// <summary>
        /// </summary>
        protected void OnAddVectorSurveillanceSessionButtonClick()
        {
            var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/Add?outbreakKey=" + OutbreakId +
                      "&outbreakID=" + EidssOutbreakId;
            NavManager.NavigateTo(uri, true);
        }

        #endregion

        #region Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchButtonClick()
        {
            VectorSessions = null;

            await InvokeAsync(() =>
            {
                VectorSessionsGrid.Reload();
                StateHasChanged();
            });
        }

        #endregion

        #region Clear Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearButtonClick()
        {
            SearchTerm = null;
            VectorSessions = null;

            await InvokeAsync(() =>
            {
                VectorSessionsGrid.Reload();
                StateHasChanged();
            });
            
        }

        #endregion

        #endregion
    }
}