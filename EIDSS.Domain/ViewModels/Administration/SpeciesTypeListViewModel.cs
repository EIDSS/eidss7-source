using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SpeciesTypeListViewModel : BaseModel
    {
        public long SpeciesTypeId { get; set; }
        public string Default { get; set; }
        public string Name { get; set; }
        public string strCode { get; set; }
        public int? intHACode { get; set; }
        public string strHACode { get; set; }
        public string strHACodeNames { get; set; }
        public int? intOrder { get; set; }

    }
}
