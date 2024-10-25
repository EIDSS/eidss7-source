using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EmployeeDetailRequestResponseModel : BaseModel
    {
        public long idfPerson { get; set; }
        public long? idfsStaffPosition { get; set; }
        public string strStaffPosition { get; set; }
        public long? idfInstitution { get; set; }
        public string strOrganizationFullName { get; set; }
        public string strOrganizationName { get; set; }
        public long? idfDepartment { get; set; }
        public string strDepartmentName { get; set; }
        public string strFamilyName { get; set; }
        public string strFirstName { get; set; }
        public string strSecondName { get; set; }
        public string strContactPhone { get; set; }
        public string strBarcode { get; set; }
        public string PersonalIDValue { get; set; }
        public long? PersonalIDTypeID { get; set; }
        public string strPersonalIDType { get; set; }
        public long idfsSite { get; set; }
        public string strSiteName { get; set; }
        public long idfsEmployeeCategory { get; set; }
        public string strEmployeeCategory { get; set; }

    }
}
