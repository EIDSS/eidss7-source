using System;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormSectionsListViewModel : BaseModel
    {
        public long idfsSection { get; set; }
        public long? idfsParentSection { get; set; }
        public long idfsFormType { get; set; }
        public Guid rowguid { get; set; }
        public int intRowStatus { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public int HasParameters { get; set; }
        public int HasNestedSections { get; set; }
        public bool blnGrid { get; set; }
        public bool blnFixedRowSet { get; set; }
        public int intOrder { get; set; }
        public string langid { get; set; }
        public long? idfsMatrixType { get; set; }
    }
}
