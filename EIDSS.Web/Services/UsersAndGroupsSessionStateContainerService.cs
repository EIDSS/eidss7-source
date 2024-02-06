using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Administration.Security.ViewModels.UserGroup;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Services
{
    public class UsersAndGroupsSessionStateContainerService
    {
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;

        public IList<EmployeesForUserGroupViewModel> UsersAndGroups { get; set; }
        public IList<EmployeesForUserGroupViewModel> SelectedUsersAndGroups { get; set; }
        public IList<EmployeesForUserGroupViewModel> SearchUsersAndGroups { get; set; }

        public IList<EmployeesForUserGroupViewModel> SelectedUsersAndGroupsToDelete { get; set; }

        public UsersAndGroupsSectionViewModel Model { get; set; }

        #endregion

        #region Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged() => OnChange?.Invoke();

        public void SetUsersAndGroupsModel(UsersAndGroupsSectionViewModel model)
        {
            Model = model;
            NotifyStateChanged();
        }

        #endregion
    }
}
