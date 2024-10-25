using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Laboratory.Freezer
{
    public class FreezerRequestModel
    {
        public string LanguageID { get; set; }
		public string SiteList { get; set; }
		public string FreezerName { get; set; }
		public string Note { get; set; }
		public long? StorageTypeID { get; set; }
		public string Building { get; set; }
		public string Room { get; set; }
		public string SearchString { get; set; }
		public int PaginationSet { get; set; }
		public int PageSize { get; set; }
		public int MaxPagesPerFetch { get; set; }		
    }
}
