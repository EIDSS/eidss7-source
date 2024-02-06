using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SystemPreferenceViewModel
    {
        public long SystemPreferenceID { get; set; }
        public string PreferenceDetail { get; set; }
    }
}
