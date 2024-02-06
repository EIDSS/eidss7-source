using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Web.Components.Leaflet.Models.Events
{
    public class PopupEvent : Event
    {
        public Popup Popup { get; set; }
    }
}
