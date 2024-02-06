using AutoFixture;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Service_Mocks
{
    public class CrossCuttingServiceMock : BaseServiceMock<ICrossCuttingService>, ICrossCuttingService
    {
        public string GetDBLangID(string CultureID)
        {
            return this.GetDBLangID(CultureID);
        }

        public Task UpdateUserOrganizationInToken(long employeeId, long organizationId, string languageId, AuthenticatedUser authenticatedUser)
        {
            throw new NotImplementedException();
        }

        public Task UpdateUserPreferencesInTokenAsync(AuthenticatedUser authenticatedUser)
        {
            authenticatedUser.Preferences.ActiveLanguage = "en-US";
            authenticatedUser.Preferences.StartupLanguage = "en-US";
            authenticatedUser.Preferences.PrintMapInVetInvestigationForms = true;
            authenticatedUser.Preferences.DefaultMapProject = BaseArrangement.Fixture.Create<int>();
            authenticatedUser.Preferences.DefaultRayonInSearchPanels = true;
            authenticatedUser.Preferences.DefaultRegionInSearchPanels = true;
            authenticatedUser.Preferences.UserPreferencesId = BaseArrangement.Fixture.Create<long>();
            Service.Setup(p => p.UpdateUserPreferencesInTokenAsync(authenticatedUser)).Returns(Task.FromResult(authenticatedUser));
            return Service.Object.UpdateUserPreferencesInTokenAsync(authenticatedUser);

        }

    }
}
