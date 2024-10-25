using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class GetHumanActiveCampaignSampleToSampleTypeResponseModel 
    {

		public long idfCampaignToDiagnosis { get; set; }
		public long idfCampaign { get; set; }
		public long idfsDiagnosis { get; set; }
		public long idfsSampleType { get; set; }
        public string Disease { get; set; }
        public string SampleTypeName { get; set; }
		public long intPlannedNumber { get; set; }
		public string Comments { get; set; }
		public long TotalPages { get; set; }
		public long intOrder { get; set; }
		public long CurrentPage { get; set; }
		public long TotalRowCount { get; set; }

	}
}
