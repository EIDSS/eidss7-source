using AutoFixture;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Web.xUnitTest.Abstracts;
using Microsoft.VisualStudio.TestPlatform.ObjectModel.DataCollection;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Service_Mocks
{
    public class UserConfigurationServiceMock : BaseServiceMock<IUserConfigurationService>, IUserConfigurationService
    {
        SystemPreferences _mock;
        SystemPreferences IUserConfigurationService.SystemPreferences { get => BaseArrangement.SystemPreferences; set => _mock = value; }

        public UserPreferences GetUserPreferences(string username)
        {
            Service.Setup(prop=> prop.GetUserPreferences(username)).Returns(BaseArrangement.UserPreferences);
            return Service.Object.GetUserPreferences(username);
        }

        public UserPreferences GetUserPreferences(string sessionId, string username)
        {
            Service.Setup(prop => prop.GetUserPreferences(sessionId, username)).Returns(BaseArrangement.UserPreferences);
            return Service.Object.GetUserPreferences(sessionId, username);
        }

        public AuthenticatedUser GetUserToken(string username)
        {
            Service.Setup(prop => prop.GetUserToken(username)).Returns(BaseArrangement.AuthenticatedUserMock);
            return Service.Object.GetUserToken(username);
        }

        public AuthenticatedUser GetUserToken(string sessionId, string username)
        {
            Service.Setup(prop => prop.GetUserToken(sessionId, username)).Returns(BaseArrangement.AuthenticatedUserMock);
            return Service.Object.GetUserToken(sessionId, username);
        }

        public AuthenticatedUser GetUserToken()
        {
            Service.Setup(prop => prop.GetUserToken()).Returns(BaseArrangement.AuthenticatedUserMock);
            return Service.Object.GetUserToken();
        }


        public bool HasToken(string username)
        {
            Service.Setup(prop => prop.HasToken(username)).Returns(true);
            return Service.Object.HasToken(username);
        }

        public bool HasToken(string sessionId, string username)
        {
            Service.Setup(prop => prop.HasToken(sessionId, username)).Returns(true);
            return Service.Object.HasToken(sessionId, username);
        }

        public void RemoveUserToken(string username)
        {
            Service.Setup(prop => prop.RemoveUserToken(username));
            Service.Object.RemoveUserToken(username);
        }

        public void RemoveUserToken(string sessionId, string username)
        {
            Service.Setup(prop => prop.RemoveUserToken(sessionId, username));
            Service.Object.RemoveUserToken(sessionId, username);
        }

        public void RemoveUserToken()
        {
            Service.Setup(prop => prop.RemoveUserToken());
            Service.Object.RemoveUserToken();
        }

        public void SetUserPreferences(UserPreferences prefs, long userId)
        {
            Service.Setup(prop => prop.SetUserPreferences(prefs, userId));
            Service.Object.SetUserPreferences(prefs,userId);
        }

        public void SetUserPreferences(UserPreferences prefs, string sessionId, long userId)
        {
            Service.Setup(prop => prop.SetUserPreferences(prefs, sessionId, userId));
            Service.Object.SetUserPreferences(prefs, sessionId, userId);
        }

        public void SetUserPreferences(UserPreferences prefs, string username)
        {
            Service.Setup(prop => prop.SetUserPreferences(prefs, username));
            Service.Object.SetUserPreferences(prefs,username);
        }

        public void SetUserPreferences(UserPreferences prefs, string sessionId, string username)
        {
            Service.Setup(prop => prop.SetUserPreferences(prefs, sessionId, username));
            Service.Object.SetUserPreferences(prefs, sessionId, username);
        }

        public void SetUserToken(string username, AuthenticatedUser token)
        {
            Service.Setup(prop => prop.SetUserToken(username, token));
            Service.Object.SetUserToken(username,token);
        }

        public void SetUserToken(string sessionId, string username, AuthenticatedUser token)
        {
            Service.Setup(prop => prop.SetUserToken(sessionId, username, token));
            Service.Object.SetUserToken(sessionId, username, token);
        }
    }
}
