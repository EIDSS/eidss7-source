using EIDSS.Web.Components.Leaflet.Models;
using System.Drawing;

namespace EIDSS.Web.Components.Leaflet.Models
{
    public class Circle : Path
    {

        /// <summary>
        /// Center of the circle.
        /// </summary>
        public LatLng Position { get; set; }

        /// <summary>
        /// Radius of the circle, in meters.
        /// </summary>
        public float Radius { get; set; }

    }
}
