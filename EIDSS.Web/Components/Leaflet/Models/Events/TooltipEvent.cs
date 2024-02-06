using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Web.Components.Leaflet.Models.Events
{
    public class TooltipEvent : Event
    {
        public Tooltip Tooltip { get; set; }
    }
}
