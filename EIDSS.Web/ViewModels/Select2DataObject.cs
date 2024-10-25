using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{

    public class Select2DataResults
    {
        public List<Select2DataItem> results { get; set; }
        public Pagination pagination { get; set; }
    }

    public class Select2DataItem
    {
        public string id { get; set; }
        public string text { get; set; }
    }



    public class Pagination
    {
        public bool more { get; set; }
    }
}
