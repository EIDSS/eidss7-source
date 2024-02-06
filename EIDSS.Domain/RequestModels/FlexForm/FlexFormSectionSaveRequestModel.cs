using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormSectionSaveRequestModel
    {
        public long? idfsSection { get; set; }
        public long? idfsParentSection { get; set; }
        public long? idfsFormType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string LangID { get; set; }
        public int intOrder { get; set; } = 0;
        public bool blnGrid { get; set; } = false;
        public bool blnFixedRowset { get; set; } = false;
        public long? idfsMatrixType { get; set; }
        public int? intRowStatus { get; set; }
        public string User { get; set; }
        public int CopyOnly { get; set; } = 0;
    }
}
