using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Auditing
{
    /// <summary>
    /// Audit data model that assists in auditing the Vet Farm save
    /// </summary>
    internal class tlbSpeciesActualAuditRequestModel
    {
        public long SpeciesMasterID { get; set; }

        public long SpeciesTypeID { get; set; }

        public DateTime StartOfSignsDate { get; set; }

        public string AverageAge { get; set; }

        public int SickAnimalQuantity { get; set; }

        public int TotalAnimalQuantity { get; set; }

        public int DeadAnimalQuantity { get; set; }

        public long OversationID { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
