using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class EmployeeSaveRequestResponseModel
    {
        public long? ReturnCode { get; set; }
        public string RetunMessage { get; set; }
        public long? idfPerson { get; set; }
        public string DuplicateMessage { get; set; }

        public string ValidationError { get; set; }


    }
}
