using EIDSS.ClientLibrary.Responses;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary
{
    public interface IUserConfigurationService
    {
        UserPreferences GetUserPreferences(string username);
        AuthenticatedUser GetUserToken(string username);
        SystemPreferences SystemPreferences { get; set; }
        bool HasToken(string username);
        void RemoveUserToken(string username);
        public void SetUserPreferences(UserPreferences prefs, long userId);
        void SetUserPreferences(UserPreferences prefs, string username);
        void SetUserToken(string username, AuthenticatedUser token);
        AuthenticatedUser GetUserToken();
        void RemoveUserToken();

        UserPreferences GetUserPreferences(string sessionId, string username);
        AuthenticatedUser GetUserToken(string sessionId, string username);
        bool HasToken(string sessionId, string username);
        void RemoveUserToken(string sessionId, string username);
        void SetUserToken(string sessionId, string username, AuthenticatedUser token);
        public void SetUserPreferences(UserPreferences prefs, string sessionId, long userId);
        void SetUserPreferences(UserPreferences prefs, string sessionId, string username);


    }

    public class TupleComparer : IEqualityComparer<Tuple<string, string>>
    {
        public bool Equals(Tuple<string, string> x, Tuple<string, string> y)
        {
            return ((x != null) && (y != null) &&
                    string.Equals(x.Item1, y.Item1, StringComparison.OrdinalIgnoreCase) &&
                    string.Equals(x.Item2, y.Item2, StringComparison.OrdinalIgnoreCase));
        }

        public int GetHashCode(Tuple<string, string> obj)
        {
            return obj.Item1.GetHashCode() + obj.Item2.GetHashCode();
        }
    }

    /// <summary>
    /// User account security contract that stored user security information in a singleton object.
    /// </summary>


    /// <summary>
    /// Stores user security information.
    /// To ensure global coverage, this class must be registered as a singleton!
    /// </summary>
    public class UserConfigurationService : IUserConfigurationService
    {

        /// <summary>
        /// AuthenticatedUser storage collection with two keys representing session Id and user name
        /// </summary>
        private Dictionary<Tuple<string, string>, AuthenticatedUser> _sessionTokenColl =
            new Dictionary<Tuple<string, string>, AuthenticatedUser>(new TupleComparer());


        /// <summary>
        /// AuthenticatedUser storage collection
        /// </summary>
        private Dictionary<string, AuthenticatedUser> _tokencoll =
            new Dictionary<string, AuthenticatedUser>(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Stores system preferences
        /// </summary>
        private SystemPreferences _systemPrefs { get; set; }


        /// <summary>
        /// Gets an instance of <see cref="SystemPreferences"/> that represents system preference
        /// </summary>
        /// <returns></returns>
        public SystemPreferences SystemPreferences
        {
            get => _systemPrefs;
            set => _systemPrefs = value;
        }

        /// <summary>
        /// Creates a new instance.
        /// </summary>
        public UserConfigurationService()
        {
        }

        public UserPreferences GetUserPreferences(string username)
        {
            if (string.IsNullOrEmpty(username))
                return null;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return null;

            var uList = _sessionTokenColl.Where((w =>
                (string.Equals(w.Key.Item2, username, StringComparison.OrdinalIgnoreCase) &&
                    (w.Value != null) &&
                    (!string.IsNullOrEmpty(((AuthenticatedUser)(w.Value)).RefreshToken)))));

            var u = uList.FirstOrDefault();
            if (u.Value != null)
                return (u.Value).Preferences;

            var uListExpired = _sessionTokenColl.Where((w =>
                (string.Equals(w.Key.Item2, username, StringComparison.OrdinalIgnoreCase) &&
                 (w.Value != null))));

            u = uListExpired.FirstOrDefault();
            if (u.Value != null)
                return (u.Value).Preferences;

            return null;
        }


        /// <summary>
        /// Returns an instance of &lt;see cref="UserPreferences"/&gt; which represent overrides to system preferences of a user from the collection. Null is returned if none is found.
        /// </summary>
        /// <param name="sessionId">Session Identifier</param>
        /// <param name="username">User Name</param>
        /// <returns>Returns an instance of &amp;lt;see cref="UserPreferences"/&amp;gt;</returns>
        public UserPreferences GetUserPreferences(string sessionId, string username)
        {
            if (string.IsNullOrEmpty(sessionId))
                return null;

            if (string.IsNullOrEmpty(username))
                return null;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return null;

            var sessionUserKey =
                new Tuple<string, string>(sessionId.ToLowerInvariant().Trim(), username.ToLowerInvariant().Trim());
            return _sessionTokenColl.TryGetValue(sessionUserKey, out var user) ? user.Preferences : null;
        }


        /// <summary>
        /// Get a user token from the collection.  Null is returned if none is found.
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public AuthenticatedUser GetUserToken(string username)
        {
            AuthenticatedUser user = null;
            if (_tokencoll.ContainsKey(username))
                user = _tokencoll[username];
            return user;

        }


        /// <summary>
        /// Get a user from the collection. Null is returned if none is found.
        /// </summary>
        /// <param name="sessionId">Session Identifier</param>
        /// <param name="username">User Name</param>
        /// <returns>Returns an instance of &amp;amp;lt;see cref="AuthenticatedUser"/&amp;amp;gt;</returns>
        public AuthenticatedUser GetUserToken(string sessionId, string username)
        {
            if (string.IsNullOrEmpty(sessionId))
                return null;

            if (string.IsNullOrEmpty(username))
                return null;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return null;

            var sessionUserKey =
                new Tuple<string, string>(sessionId.ToLowerInvariant().Trim(), username.ToLowerInvariant().Trim());
            return _sessionTokenColl.TryGetValue(sessionUserKey, out var user) ? user : null;
        }

        /// <summary>
        /// GetUserToken
        /// </summary>
        /// <returns></returns>
        public AuthenticatedUser GetUserToken()
        {
            AuthenticatedUser user = null;
            if (_tokencoll is { Count: > 0 })
            {
                user = _tokencoll.FirstOrDefault().Value;
            }

            return user;
        }

        /// <summary>
        /// Checks for the existence of a token for the given user
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public bool HasToken(string username)
        {
            username = username.ToLower().Trim();
            return _tokencoll.ContainsKey(username) ? true : false;
        }

        /// <summary>
        /// Checks for the existence of a user in the collection for the given session Id and user name 
        /// </summary>
        /// <param name="sessionId">Session Identifier</param>
        /// <param name="username">User Name</param>
        /// <returns>Returns Boolean value</returns>
        public bool HasToken(string sessionId, string username)
        {
            if (string.IsNullOrEmpty(sessionId))
                return false;

            if (string.IsNullOrEmpty(username))
                return false;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return false;

            var sessionUserKey =
                new Tuple<string, string>(sessionId.ToLowerInvariant().Trim(), username.ToLowerInvariant().Trim());

            return _sessionTokenColl.ContainsKey(sessionUserKey) ? true : false;
        }


        /// <summary>
        /// Removes a user's token
        /// </summary>
        /// <param name="username"></param>
        public void RemoveUserToken(string username)
        {
            if (username != null)
            {
                username = username.ToLower().Trim();
                _tokencoll.Remove(username);
            }
        }

        /// <summary>
        /// Removes a user from the collection
        /// </summary>
        /// <param name="sessionId">Session Identifier</param>
        /// <param name="username">User Name</param>
        public void RemoveUserToken(string sessionId, string username)
        {
            if (string.IsNullOrEmpty(sessionId))
                return;

            if (string.IsNullOrEmpty(username))
                return;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return;

            var sessionUserKey =
                new Tuple<string, string>(sessionId.ToLowerInvariant().Trim(), username.ToLowerInvariant().Trim());
            if (_sessionTokenColl.ContainsKey(sessionUserKey))
                _sessionTokenColl.Remove(sessionUserKey);
        }


        /// <summary>
        /// Removes a user's token
        /// </summary>
        public void RemoveUserToken()
        {
            if (_tokencoll is {Count: > 0})
            {
                var key = _tokencoll.FirstOrDefault().Key;
                _tokencoll.Remove(key);
            }
        }

        /// <summary>
        /// Saves a user's preference settings given the userid
        /// </summary>
        /// <param name="prefs"></param>
        /// <param name="username"></param>
        public void SetUserPreferences(UserPreferences prefs, long userId)
        {
            if (_tokencoll !=null && _tokencoll.Count>0)
            {
                var u = _tokencoll.Where(w => ((AuthenticatedUser) w.Value).EIDSSUserId == Convert.ToString(userId));
                if (u != null)
                    ((AuthenticatedUser) u.FirstOrDefault().Value).Preferences = prefs;
            }
        }

        /// <summary>
        /// Saves user's preference settings for the user with specified identifier
        /// </summary>
        /// <param name="prefs">An instance of &amp;lt;see cref="UserPreferences"/&amp;gt; which represent overrides to the system preferences</param>
        /// <param name="sessionId">Session Identifier - not in use</param>
        /// <param name="userId">User Identifier</param>
        public void SetUserPreferences(UserPreferences prefs, string sessionId, long userId)
        {
            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return;

            var uList = _sessionTokenColl.Where((w =>
                ((w.Value != null) &&
                 string.Equals(((AuthenticatedUser)(w.Value)).EIDSSUserId, string.Format("{0}", userId), StringComparison.InvariantCultureIgnoreCase))));
            foreach (var u in uList)
                if (u.Value != null)
                    (u.Value).Preferences = prefs;
        }


        /// <summary>
        /// Saves a user's preference settings given the username
        /// </summary>
        /// <param name="prefs"></param>
        /// <param name="username"></param>
        public void SetUserPreferences(UserPreferences prefs, string username)
        {
            if (_tokencoll.ContainsKey(username))
                _tokencoll[username].Preferences = prefs;
        }

        /// <summary>
        /// Saves user's preference settings for the user with specified identifier
        /// </summary>
        /// <param name="prefs">An instance of &amp;lt;see cref="UserPreferences"/&amp;gt; which represent overrides to the system preferences</param>
        /// <param name="sessionId">Session Identifier - not in use</param>
        /// <param name="username">User Name</param>
        public void SetUserPreferences(UserPreferences prefs, string sessionId, string username)
        {
            if (string.IsNullOrEmpty(username))
                return;

            if ((_sessionTokenColl == null) || (_sessionTokenColl.Count == 0))
                return;

            var uList = _sessionTokenColl.Where((w =>
                (string.Equals(w.Key.Item2, username.ToLowerInvariant().Trim(), StringComparison.InvariantCultureIgnoreCase))));
            foreach (var u in uList)
                if (u.Value != null)
                    (u.Value).Preferences = prefs;
        }


        /// <summary>
        /// Saves a user's token.
        /// </summary>
        /// <param name="username"></param>
        /// <param name="token"></param>
        public void SetUserToken(string username, AuthenticatedUser token)
        {
            username = username.ToLower().Trim();
            if (!_tokencoll.ContainsKey(username))
                _tokencoll.Add(username, token);
            else
                _tokencoll[username] = token;
        }


        /// <summary>
        /// Saves (adds or updates) user token for the given session identifier and user name 
        /// </summary>
        /// <param name="sessionId">Session Identifier</param>
        /// <param name="username">User Name</param>
        /// <param name="token">An instance of &amp;amp;amp;lt;see cref="AuthenticatedUser"/&amp;amp;amp;gt; (user token)</param>
        public void SetUserToken(string sessionId, string username, AuthenticatedUser token)
        {
            if (string.IsNullOrEmpty(sessionId))
                return;

            if (string.IsNullOrEmpty(username))
                return;

            if (_sessionTokenColl == null)
                return;

            var sessionUserKey =
                new Tuple<string, string>(sessionId.ToLowerInvariant().Trim(), username.ToLowerInvariant().Trim());


            if (!_sessionTokenColl.ContainsKey(sessionUserKey))
                _sessionTokenColl.Add(sessionUserKey, token);
            else
                _sessionTokenColl[sessionUserKey] = token;
        }



        private bool isTokenExpired(string username)
        {
            var user = _tokencoll[username];
            if (user == null) return true;

            return user.ExpireDate < DateTime.Now ? true : false;
        }

    }

}
