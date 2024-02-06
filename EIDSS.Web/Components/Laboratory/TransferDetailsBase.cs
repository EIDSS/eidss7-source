#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Laboratory;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using static System.GC;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class TransferDetailsBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<TransferDetailsBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public TransferredGetListViewModel Transfer { get; set; }

        #endregion

        #region Properties

        public RadzenTemplateForm<TransferredGetListViewModel> Form { get; set; }
        public IEnumerable<OrganizationAdvancedGetListViewModel> TransferredToOrganizations { get; set; }
        public bool WritePermissionIndicator { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public TransferDetailsBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected TransferDetailsBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            try
            {
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);
                WritePermissionIndicator = _userPermissions.Write;

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
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

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetTransferredToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                TransferredToOrganizations = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
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