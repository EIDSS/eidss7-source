using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class UserGroupGetListViewModel : BaseModel
    {
        public long idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
    }
}
