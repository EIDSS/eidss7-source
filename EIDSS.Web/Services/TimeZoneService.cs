﻿using System;
using System.Threading.Tasks;
using Microsoft.JSInterop;

namespace EIDSS.Web.Services
{
    public sealed class TimeZoneService
    {
        private readonly IJSRuntime _jsRuntime;

        private TimeSpan? _userOffset;

        public TimeZoneService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }

        public async ValueTask<DateTimeOffset> GetLocalDateTime(DateTimeOffset dateTime)
        {
            if (_userOffset == null)
            {
                int offsetInMinutes = await _jsRuntime.InvokeAsync<int>("blazorGetTimezoneOffset");
                _userOffset = TimeSpan.FromMinutes(-offsetInMinutes);
            }

            return dateTime.ToOffset(_userOffset.Value);
        }

        public async ValueTask<DateTime> GetLocalDate()
        {
            var localDate = await _jsRuntime.InvokeAsync<DateTime>("localDate");

            return localDate;
        }
    }
}
