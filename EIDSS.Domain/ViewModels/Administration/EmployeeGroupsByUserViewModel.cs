using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EmployeeGroupsByUserViewModel
    {
        public long idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
        public string strName { get; set; }

    }
}
