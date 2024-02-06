using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Laboratory.Freezers
{
    public class FreezerSubdivisionParameter
    {
        public long FreezerSubdivisionID { get; set; }
        public long? SubdivisionTypeID { get; set; }
        public long FreezerID { get; set; }
        public long? ParentFreezerSubdivisionID { get; set; }
        public long OrganizationID { get; set; }
        public string EIDSSFreezerSubdivisionID { get; set; }
        public string FreezerSubdivisionName { get; set; }
        public string SubdivisionNote { get; set; }
        public int? NumberOfLocations { get; set; }
        public long? BoxSizeTypeID { get; set; }
        public string BoxPlaceAvailability { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
