using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class AdminEmployeeSaveRequestModel
    {
        public long? idfPerson { get; set; }

        public long? idfsStaffPosition { get; set; }
        
        public long? idfInstitution { get; set; }

        public long? idfDepartment { get; set; }
        
        public string strFamilyName { get; set; } 
        
        public string strFirstName { get; set; }

        public string strSecondName { get; set; }

        public string strContactPhone { get; set; }

        public string strBarcode { get; set; }

        public long? idfsSite { get; set; }
        
        public string strPersonalID { get; set; }

        public string idfPersonalIDType { get; set; }

        public long? idfsEmployeeCategory { get; set; }
        
        public string User { get; set; }
    }   
}
