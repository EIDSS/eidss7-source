using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class DiseaseSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("idfsDiagnosis")]
        public long? DiagnosisId { get; set; }

        public bool ForceDelete { get; set; }

        [MapToParameter("strIDC10")]
        
        public string IDC10 { get; set; }
        [MapToParameter("strLabTest")]
        
        public string LabTest { get; set; }
        [MapToParameter("strOIECode")]
        
        public string OIECode { get; set; }
        [MapToParameter("strPensideTest")]
        
        public string PensideTest { get; set; }
        [MapToParameter("strSampleType")]
        
        public string SampleType { get; set; }
        
        [MapToParameter("blnSyndrome")]
        public bool? Syndrome { get; set; }

        [MapToParameter("idfsUsingType")]
        public long? UsingTypeId { get; set; }

        [MapToParameter("blnZoonotic")]
        public bool? Zoonotic { get; set; }

        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
