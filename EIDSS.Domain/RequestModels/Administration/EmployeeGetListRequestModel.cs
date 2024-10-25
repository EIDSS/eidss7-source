using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;
namespace EIDSS.Domain.RequestModels.Administration
{
    public class EmployeeGetListRequestModel: BaseGetRequestModel {
   
        public long? EmployeeID { get; set; }
        public string FirstOrGivenName { get; set; }
        public string SecondName { get; set; }
        public string LastOrSurName { get; set; }
        public string ContactPhone { get; set; }
        public string OrganizationAbbreviatedName { get; set; }
        public string OrganizationFullName { get; set; }
        public string EIDSSOrganizationID { get; set; }
        public long? OrganizationID { get; set; }
        public string PositionTypeName { get; set; }
        public long? PositionTypeID { get; set; }
        public long? AccountState { get; set; }
        public long? EmployeeCategory { get; set; }
        public long? PersonalIdType { get; set; }
        public string PersonalIDValue { get; set; }
        public long? EmployeeCategoryID { get; set; }
        
            
        
    }
}
