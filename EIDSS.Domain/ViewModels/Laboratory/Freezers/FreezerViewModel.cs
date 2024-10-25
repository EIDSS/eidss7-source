using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Laboratory.Freezers
{
    public class FreezerViewModel
    {
        public long? FreezerID { get; set; }
        public string FreezerName { get; set; }
        public string EIDSSFreezerID { get; set; }
        public long StorageTypeID { get; set; }
        public string StorageTypeName { get; set; }
        public string Building { get; set; }
        public string Room { get; set; }
        public long OrganizationID { get; set; }
        public string OrganizationName { get; set; }
        public string FreezerNote { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
        public List<FreezerSubdivisionViewModel> FreezerSubdivisions {get;set;}
    }
}
