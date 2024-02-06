using EIDSS.Web.Components.Leaflet.Models;
using EIDSS.Web.Components.Leaflet.Models.Events;
using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Web.Components.Leaflet.Model.Events
{
    public class DragEvent : Event
    {
        public LatLng LatLng { get; set; }

        public LatLng OldLatLng { get; set; }
    }
}
