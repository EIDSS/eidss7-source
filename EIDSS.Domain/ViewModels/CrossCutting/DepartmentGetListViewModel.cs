using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class DepartmentGetListViewModel : BaseModel
    {
        public long DepartmentID { get; set; }
        public long OrganizationID { get; set; }
        [StringLength(2000)]
        [LocalizedRequired()]
        public string DepartmentNameDefaultValue { get; set; }
        [StringLength(2000)]
        public string DepartmentNameNationalValue { get; set; }
        [LocalizedRange("-2147483648", "2147483648")]
        public int Order { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
        public int RecordCount { get; set; }
    }
}
