using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Shared
{
    public class LatLong
    {
        public float lat { get; set; }

        public float lon { get; set; }
    }

    public class JsInteropClasses
    {
        private readonly IJSRuntime js;

        public JsInteropClasses(IJSRuntime js)
        {
            this.js = js;
        }

        public async ValueTask<LatLong> GetLatLongForLeaflet(string url,string defaultUrl,long lat, long lan)
        {
            var result= await js.InvokeAsync<LatLong>("GetLatLongForLeaflet", url, defaultUrl,lat,lan, js);
            return result;
        }

        public void Dispose()
        {
        }
    }
}