using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Laboratory.Freezer
{
	[DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FreezerSaveRequestModel
    {
        public string LanguageID { get; set; }
        public long FreezerID { get; set; }
		public long? StorageTypeID { get; set; }
		public long OrganizationID { get; set; }
		public string FreezerName { get; set; }
		public string FreezerNote { get; set; }
		public string EIDSSFreezerID { get; set; }
		public string Building { get; set; }
		public string Room { get; set; }
		public int RowStatus { get; set; }
        public List<FreezerSubdivisionParameter> FreezerSubdivisionsList { get; set; }
		public string FreezerSubdivisions { get; set; }
		public string AuditUserName { get; set; }

    }
}
