using EIDSS.Web.Components.Leaflet.Models.Events;
using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Web.Components.Leaflet.Model.Events
{
    public class DragEndEvent : Event
    {
        public float Distance { get; set; }
    }
}
