using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Leaflet.Exception
{
    /// <summary>
    /// Exception thrown when the user tried to manipulate the map before it has been initialized.
    /// </summary>
    public class UninitializedMapException : System.Exception
    {

        public UninitializedMapException()
        {

        }

        public UninitializedMapException(string message) : base(message)
        {

        }

    }
}