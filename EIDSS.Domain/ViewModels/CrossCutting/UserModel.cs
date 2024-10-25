using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class UserModel:BaseModel
    {
        public long idfPerson { get; set; }
        public long idfUserID { get; set; }
        public string strFirstName { get; set; }
        public string strSecondName { get; set; }
        public string strFamilyName { get; set; }
        public long? idfInstitution { get; set; }
        public long idfsSite { get; set; }

        public string FullName => $"{strFirstName} {strFamilyName}";     // the Name property

    }
}
