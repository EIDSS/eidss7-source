using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class FarmGetListViewModel
    {
        public long FarmKey { get; set; }
        public string FarmID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int? Order { get; set; }
        public string AddressString { get; set; }
        public string OrganizationTypeName { get; set; }
        public int AccessoryCode { get; set; }
        public long? SiteID { get; set; }
        public int RowStatus { get; set; }
        public int? RowCount { get; set; }
    }
}
