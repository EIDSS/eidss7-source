using EIDSS.Domain.Attributes;
using EIDSS.Domain.ResponseModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
	[DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
	public class ILIAggregateDetailSaveRequestModel : APIPostResponseModel
	{
		public string LanguageID { get; set; }
		public long? IdfAggregateHeader { get; set; }
		public long? IdfAggregateDetail { get; set; }
		public int RowStatus { get; set; }
		public long IdfHospital { get; set; }
		public int IntAge0_4 { get; set; }
		public int IntAge5_14 { get; set; }
		public int IntAge15_29 { get; set; }
		public int IntAge30_64 { get; set; }
		public int IntAge65 { get; set; }
		public int IntTotalILI { get; set; }
		public int IntTotalAdmissions { get; set; }
		public int IntILISamples { get; set; }
		public string AuditUserName { get; set; }
		public string RowAction { get; set; }		
		public long IdfsSite { get; set; }
		public string StrFormID { get; set; }		
		public bool RefreshPage { get; set; }	
		public long IdfEnteredBy { get; set; }
		public int IntYear { get; set; }
		public int IntWeek { get; set; }

    }
	
}
