using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Administration.AdministrativeUnits;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Rendering;
using Microsoft.EntityFrameworkCore.Internal;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Serilog.Core;

namespace EIDSS.Web.Components.Shared
{
    public class ArchiveComponentBase : BaseComponent, IDisposable
    {

        [Inject] private ILogger<ArchiveComponentBase> Logger { get; set; }

        [Inject]
        private IAdminClient AdminClient { get; set; }

        [Inject]
        private ICrossCuttingService CrossCuttingService { get; set; }

        public string ArchiveMenuName { get; set; }
        public bool IsInArchiveMode { get; set; }

        protected override void OnInitialized()
        {
            try
            {
                ArchiveMenuName = _tokenService.GetAuthenticatedUser().ArchiveMenuName;

                //IsInArchiveMode = false;
                //ArchiveMenuName ="Connect to Archive";
                base.OnInitialized();
            }
            catch (Exception e)
            {
                Logger.LogError(e.Message);
                throw;
            }
          
        }

        public string GetArchiveMenuName()
        {
            IsInArchiveMode = !_tokenService.GetAuthenticatedUser().IsInArchiveMode;
            ArchiveMenuName = IsInArchiveMode
                    ? Localizer.GetString(FieldLabelResourceKeyConstants.SecurityConnecttoarchiveFieldLabel)
                    : Localizer.GetString(FieldLabelResourceKeyConstants.SecurityDisconnectFromArchiveFieldLabel);

            return ArchiveMenuName;
        }

        public async Task ToggleArchiveAsync()
        {
            try
            {
                _tokenService.GetAuthenticatedUser().IsInArchiveMode = !_tokenService.GetAuthenticatedUser().IsInArchiveMode;
                IsInArchiveMode = !_tokenService.GetAuthenticatedUser().IsInArchiveMode;
                ArchiveMenuName = IsInArchiveMode
                    ? Localizer.GetString(FieldLabelResourceKeyConstants.SecurityConnecttoarchiveFieldLabel)
                    : Localizer.GetString(FieldLabelResourceKeyConstants.SecurityDisconnectFromArchiveFieldLabel);
                _tokenService.GetAuthenticatedUser().ArchiveMenuName = ArchiveMenuName;

                if (_tokenService.GetAuthenticatedUser().IsInArchiveMode)
                {
                    _tokenService.UpdatePermissionsToReadOnly();
                    await AdminClient.ConnectToArchive(_tokenService.GetAuthenticatedUser().IsInArchiveMode);

                }
                else
                {
                    await AdminClient.ConnectToArchive(_tokenService.GetAuthenticatedUser().IsInArchiveMode);
                    var permissions = await AdminClient.GetUserRolesAndPermissions(Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId), null);
                    _tokenService.GetAuthenticatedUser().Claims = new List<Permission>(); 
                    CrossCuttingService.RefreshToken(_tokenService.GetAuthenticatedUser().UserOrganizations.FirstOrDefault(x => x.OrganizationID == Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId)), permissions, _tokenService.GetAuthenticatedUser());

                }

                var path = "Administration/Dashboard";
                var uri = $"{NavManager.BaseUri}{path}";
                NavManager.NavigateTo(uri, true);
            }
            catch (Exception e)
            {
                Logger.LogError(e.Message);
                throw;
            }
           

        }



        public void Dispose()
        {
            
        }
    }
}
