using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class ILIAggregateDetailViewModel : BaseModel
    {
        public long IdfAggregateDetail { get; set; }
        public long IdfAggregateHeader { get; set; }

        [LocalizedRequired]
        public long? IdfHospital { get; set; }

        public string HospitalName { get; set; }
        public int? IntAge0_4 { get; set; }
        public int? IntAge5_14 { get; set; }
        public int? IntAge15_29 { get; set; }
        public int? IntAge30_64 { get; set; }
        public int? IntAge65 { get; set; }
        public int? InTotalILI { get; set; }
        public int? IntTotalAdmissions { get; set; }
        public int? IntILISamples { get; set; }
        public string RowAction { get; set; }
        public string RowStatus { get; set; }
        public long RowId { get; set; }      
        public OrganizationGetListViewModel SelectedHospital { get; set; }
    }
}
