using EIDSS.Domain.Attributes;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ReportAuditSaveRequestModel
    {
        public long? idfUserID { get; set; }
        public string strFirstName { get; set; }
        public string strMiddleName { get; set; }
        public string strLastName { get; set; }
        public string userRole { get; set; }
        public string strOrganization { get; set; }
        public bool? idfIsSignatureIncluded { get; set; }
        public string strReportName { get; set; }
        public DateTime? datGeneratedDate { get; set; }
    }

    public class ReportAuditSaveJsonModel
    {

        [JsonProperty("idfIsSignatureIncluded")]
        public string IdfIsSignatureIncluded { get; set; }
        [JsonProperty("strReportName")]
        public string StrReportName { get; set; }
    }
}
