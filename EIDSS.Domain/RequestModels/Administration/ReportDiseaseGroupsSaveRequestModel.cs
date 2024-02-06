using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ReportDiseaseGroupsSaveRequestModel : BaseReferenceEditorRequestModel
    {        
        public long? IdfsReportDiagnosisGroup { get; set; }
        public bool DeleteAnyway { get; set; }
        public string StrCode { get; set; }
    }
}
