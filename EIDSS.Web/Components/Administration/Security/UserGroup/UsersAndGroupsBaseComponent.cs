using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using System.Threading;

namespace EIDSS.Web.Components.Administration.Security.UserGroup
{
    public class UsersAndGroupsBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected UsersAndGroupsSessionStateContainerService UserGroupService { get; set; }

        #endregion

        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion
        #endregion
    }
}
