using System;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormTemplateListViewModel : BaseModel
    {
        public long idfsFormTemplate { get; set; }
        public long? idfsFormType { get; set; }
        public bool blnUNI { get; set; }
        public Guid rowguid { get; set; }
        public int intRowStatus { get; set; }
        public string strNote { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string NationalLongName { get; set; }
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
    }
}
