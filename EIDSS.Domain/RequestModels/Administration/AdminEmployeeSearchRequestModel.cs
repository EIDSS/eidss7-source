using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class AdminEmployeeSearchRequestModel 
    {

        [Required]
        public string LanguageId { get; set; }
        public Nullable<long> EmployeeId { get; set; }
        public string FirstName { get; set; }
        public string SecondName { get; set; }
        public string FamilyName { get; set; }
        public string ContactPhone { get; set; }
        public string OrganizationFullName { get; set; }
        public string OrganizationID { get; set; }
        public Nullable<long> InstitutionId { get; set; }
        public string Position { get; set; }
        public string PersonalID { get; set; }
        public Nullable<long> PersonalIDType { get; set; }
        public Nullable<long> PositionId { get; set; }
        public long? idfsEmployeeCategory { get; set; }
        public long? accountStateId { get; set; }
        public Nullable<int> Page { get; set; } = 1;
        public Nullable<int> PageSize{ get; set; } = 10;
    }
}
