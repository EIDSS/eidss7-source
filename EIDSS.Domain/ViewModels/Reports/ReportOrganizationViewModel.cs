using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class ReportOrganizationViewModel: BaseModel
    {
        public long? idfInstitution { get; set; }
        public string OrganizationName { get; set; }
    }
}
