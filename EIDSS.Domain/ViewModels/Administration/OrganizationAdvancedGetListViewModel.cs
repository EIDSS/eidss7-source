using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class OrganizationAdvancedGetListViewModel : BaseModel
    {
        public long idfOffice { get; set; }
        public long? idfsOfficeName { get; set; }
        public string EnglishFullName { get; set; }
        public long? idfsOfficeAbbreviation { get; set; }
        public string EnglishName { get; set; }
        public string FullName { get; set; }
        public string name { get; set; }
        public int? intHACode { get; set; }
        public long? idfsSite { get; set; }
        public string strSiteName { get; set; }
        public long? idfLocation { get; set; }
    }
}
