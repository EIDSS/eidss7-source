using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Helpers
{
    //public static class ApplicationContext1
    //{
    //    private static IHttpContextAccessor _httpContextAccessor;

    //    public static void Configure(IHttpContextAccessor httpContextAccessor)
    //    {
    //        _httpContextAccessor = httpContextAccessor;
    //    }

    //    public static HttpContext Current => _httpContextAccessor.HttpContext;

    //    public static string GetCookie(string key)
    //    {
    //        return _httpContextAccessor.HttpContext.Request.Cookies[key];
    //    }

    //    public static void SetCookie(string key, string value, int? expireTime)
    //    {
    //        CookieOptions option = new CookieOptions();
    //        if (expireTime.HasValue)
    //            option.Expires = DateTime.Now.AddMinutes(expireTime.Value);
    //        else
    //            option.Expires = DateTime.Now.AddMilliseconds(10);
    //        option.HttpOnly = true;
    //        _httpContextAccessor.HttpContext.Response.Cookies.Append(key, value, option);
    //    }

    //    public static void RemoveCookie(string key)
    //    {

    //        if (_httpContextAccessor.HttpContext.Request.Cookies[key] != null)
    //        {
    //            _httpContextAccessor.HttpContext.Response.Cookies.Delete(key);
    //        }
    //    }

    //    public static void SetSession(string key,string value)
    //    {
    //        _httpContextAccessor.HttpContext.Session.SetString(key, value);
    //    }

    //    public static string GetSession(string key)
    //    {
    //        return _httpContextAccessor.HttpContext.Session.GetString(key);
    //    }

    //    public static void RemoveSession(string key)
    //    {
    //        _httpContextAccessor.HttpContext.Session.Remove(key);
    //    }
    //}
}
