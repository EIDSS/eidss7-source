using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.CrossCutting;

namespace EIDSS.ClientLibrary.Services
{

    public interface IApplicationContext
    {
        void SetSession(string key, string value);
        string GetSession(string key);
        void RemoveSession(string key);
        string SessionId { get; }
    }

    public class ApplicationContext: IApplicationContext
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public  ApplicationContext(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public string GetCookie(string key)
        {
            string returnValue = null;
            if (_httpContextAccessor.HttpContext != null)
            {
                returnValue = _httpContextAccessor.HttpContext.Request.Cookies[key];
            }
            return returnValue;

        }

        public void SetCookie(string key, string value, int? expireTime)
        {
            var option = new CookieOptions
            {
                Expires = expireTime.HasValue ? DateTime.Now.AddMinutes(expireTime.Value) : DateTime.Now.AddMilliseconds(10),
                HttpOnly = true,
                Secure = true,
                SameSite= SameSiteMode.Strict
            };
            _httpContextAccessor.HttpContext?.Response.Cookies.Append(key, value, option);
        }

        public void RemoveCookie(string key)
        {

            if (_httpContextAccessor.HttpContext != null && _httpContextAccessor.HttpContext.Request.Cookies[key] != null)
            {
                _httpContextAccessor.HttpContext.Response.Cookies.Delete(key);
            }
        }

        public string SessionId
        {
            get { return _httpContextAccessor?.HttpContext?.Session.Id; }
        }

        public void SetSession(string key, string value)
        {
            _httpContextAccessor?.HttpContext?.Session.SetString(key, value);
        }

        public string GetSession(string key)
        {
            string userName = null;
            if (_httpContextAccessor != null)
            {
                if (_httpContextAccessor.HttpContext != null)
                {
                    userName = _httpContextAccessor.HttpContext.User.Identity is {IsAuthenticated: true} ? _httpContextAccessor.HttpContext.User.Identity.Name : _httpContextAccessor.HttpContext.Session.GetString(key);
                }
                else
                {
                    userName = null;
                }
            }
            else
            {
                userName =null;
            }

            return userName;
            
        }

        public void RemoveSession(string key)
        {
            _httpContextAccessor?.HttpContext?.Session.Remove(key);
        }
    }
}
