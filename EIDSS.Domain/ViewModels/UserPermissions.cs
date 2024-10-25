using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class UserPermissions
    {
        public bool Create { get; set; } = false;
        public bool Write { get; set; } = false;
        public bool Read { get; set; } = false;
        public bool Delete { get; set; } = false;
        public bool AccessToGenderAndAgeData { get; set; } = false;
        public bool AccessToPersonalData { get; set; } = false;
        public bool Execute { get; set; } = false;
    }
}

