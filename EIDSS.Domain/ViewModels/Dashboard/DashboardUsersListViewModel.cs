using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Dashboard
{
    public class DashboardUsersListViewModel : BaseModel
    {        
        public long EmployeeID { get; set; }
        public string FirstName { get; set; }
        public string FamilyName { get; set; }
        public string SecondName { get; set; }
        public long? InstitutionID { get; set; }
        public string OrganizationName { get; set; }
        public string OrganizationFullName { get; set; }
        public long? PositionID { get; set; }
        public string Position { get; set; }   
    }
}
