using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SystemEventLogGetListViewModel
    {
        public long EventId { get; set; }
        public long? EventTypeId { get; set; }
        public string strInformationString { get; set; }
        public string EventTypeName { get; set; }
        public long? ObjectId { get; set; }
        public DateTime? EventDate { get; set; }
        public string strPersonName { get; set; }
        public long? idfUserID { get; set; }
        public long idfPerson { get; set; }
        public string ViewUrl { get; set; }
        public int? TotalRowCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
