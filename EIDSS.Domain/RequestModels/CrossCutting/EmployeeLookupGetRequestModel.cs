using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class EmployeeLookupGetRequestModel : BaseGetRequestModel
    {
        public long? OrganizationID { get; set; }
        public long? EmployeeID { get; set; }
        public bool? ShowUsersOnly { get; set; } = false;
        public int? AccessoryCode { get; set; }
        public string AdvancedSearch { get; set; } = null;
    }
}