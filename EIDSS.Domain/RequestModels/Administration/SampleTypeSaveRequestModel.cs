using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SampleTypeSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("IdfsSampleType")]
        public long? SampleTypeId { get; set; }
        public bool DeleteAnyway { get; set; }
        [MapToParameter("strSampleCode")]
        public string SampleCode { get; set; }
        [MapToParameter("LOINC_NUM")]
        public string LOINC_NUMBER { get; set; }
    }
}
