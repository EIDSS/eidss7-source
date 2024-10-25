using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class DepartmentGetRequestModel : BaseGetRequestModel
    {
        public long? DepartmentID { get; set; }
        public long? OrganizationID { get; set; }
    }
}
