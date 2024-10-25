using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Auditing
{
    internal class tlbHerdActualAuditRequestModel
    {
        public long HerdMasterID { get; set; }

        public string EIDSSHerdID { get; set; }

        public long FarmMasterID { get; set; }

        public int SickAnimalQuantity { get; set; }

        public int TotalAnimalQuantity { get; set; }

        public int DeadAnimalQuantity { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
