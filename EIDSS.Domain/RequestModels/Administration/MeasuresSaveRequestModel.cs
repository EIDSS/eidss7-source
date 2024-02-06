using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class MeasuresSaveRequestModel : BaseReferenceEditorRequestModel
    {
        public long? IdfsBaseReference { get; set; }
        public long? IdfsReferenceType { get; set; }
        public string StrActionCode { get; set; }

        public long IdfsAction { get; set; }
        public long IdfsMeasureList { get; set; }
        public bool DeleteAnyway { get; set; }
    }
}
