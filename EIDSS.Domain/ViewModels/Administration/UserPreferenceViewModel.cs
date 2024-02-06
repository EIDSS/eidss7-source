using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class UserPreferenceViewModel :BaseModel
    {
        public long UserPreferenceUID { get; set; }
        public long UserID { get; set; }
        public string preferenceDetail { get; set; }
    }
}
