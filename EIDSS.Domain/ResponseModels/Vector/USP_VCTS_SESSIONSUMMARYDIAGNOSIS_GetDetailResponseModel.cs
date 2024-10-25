using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel
    {
         
        public int RowNumber { get; set; }
        public long idfsVSSessionSummaryDiagnosis { get; set; }
        public long idfsVSSessionSummary { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public int? intPositiveQuantity { get; set; }
        public int intRowStatus { get; set; }
        public int RowAction { get; set; }
        public int TotalRowCount { get; set; }
        public USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel ShallowCopy() => (USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel)MemberwiseClone();

    }
}
