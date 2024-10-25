using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Vector
{
	[DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
	public class VectorSetSampleModel
	{
		public string LangID { get; set; }
		public long? idfMaterial { get; set; }
		public string strFieldBarcode { get; set; }
		public long? idfVectorSurveillanceSession { get; set; }
		public long? idfVector { get; set; }
		public long? idfSendToOffice { get; set; }
		public long? idfFieldCollectedByOffice { get; set; }
		public string strNote { get; set; }
		public DateTime? datFieldCollectionDate { get; set; }
		public DateTime? EnteredDate { get; set; }
		public long SiteID { get; set; }
		public long idfsDiagnosis { get; set; }
        
		public long? idfsSampleType { get; set; }
    }
}
