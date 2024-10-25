using EIDSS.ClientLibrary.Responses;
using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.ClientLibrary
{
    [Obsolete(message:"This class has been replaced by the singleton service UserConfigurationService, please use that service instead!", 
        error:true)]
    // <summary>
    /// Stores  a user token for each user logged into the application.
    /// </summary>
    public static class ConfigFactory
    {
        private static Dictionary<string, AuthenticatedUser> _tokencoll = new Dictionary<string, AuthenticatedUser>(StringComparer.OrdinalIgnoreCase);

        internal static SystemPreferences SystemPrefs { get; set; }

        internal static UserPreferences UserPrefs { get; set; }

        static readonly object _object = new object();

        /// <summary>
        /// Returns true if the user's token has expired.
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        private static bool isTokenExpired(string username)
        {
            var user = _tokencoll[username];
            if (user == null) return true;

            return user.ExpireDate < DateTime.Now ? true : false;
        }

        /// <summary>
        /// Retrieves a user token from the collection if found, otherwise null is returned.
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static AuthenticatedUser GetUserToken(string username)
        {
            AuthenticatedUser user = null;

            // Traffic light.... we want to mitigate issues...
            lock (_object)
            {
                if (_tokencoll.ContainsKey(username))
                {
                    user = _tokencoll[username];
                    if (isTokenExpired(username))
                    {
                        // remove the token...
                        //_tokencoll.Remove(username);
                        //throw new Exception("Your session has expired!  You must log into the system again.");
                    }
                }
                return user;
            }
        }


        /// <summary>
        /// Adds a user token to the collection.
        /// </summary>
        /// <param name="username"></param>
        /// <param name="token"></param>
        public static void SetUserToken(string username, AuthenticatedUser token)
        {
            username = username.ToLower().Trim();
            if (!_tokencoll.ContainsKey(username))
                _tokencoll.Add(username, token);
            else
                _tokencoll[username] = token;
        }

        /// <summary>
        /// Removes a user token from the collection.
        /// </summary>
        /// <param name="username"></param>
        public static void RemoveUserToken(string username)
        {
            username = username.ToLower().Trim();
            _tokencoll.Remove(username);
        }

        /// <summary>
        /// Determines if a user token exists.
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static bool HasToken(string username)
        {
            username = username.ToLower().Trim();
            return _tokencoll.ContainsKey(username) ? true : false;
        }

        public static SystemPreferences GetSystemPreferences()
        {
            return SystemPrefs;
        }

        /// <summary>
        /// Sets the system preferences...
        /// </summary>
        /// <param name="prefs"></param>
        internal static void SetSystemPreferences(SystemPreferences prefs)
        {
            SystemPrefs = prefs;
        }

        public static UserPreferences GetUserPreferences()
        {
            return UserPrefs;
        }
        /// <summary>
        /// Sets the system preferences...
        /// </summary>
        /// <param name="prefs"></param>
        internal static void SetUserPreferences(UserPreferences prefs)
        {
            UserPrefs = prefs;
        }

        //static ConfigFactory()
        //{
        //    PreferenceServiceClient ps = new PreferenceServiceClient();
        //    var x = ps.InitializeSystemPreferences();
        //}
    }
}
