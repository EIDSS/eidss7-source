using System.Drawing;

namespace EIDSS.Web.Components.Leaflet.Models.Events
{
    public class ResizeEvent : Event
    {
        public PointF OldSize { get; set; }
        public PointF NewSize { get; set; }
    }
}
