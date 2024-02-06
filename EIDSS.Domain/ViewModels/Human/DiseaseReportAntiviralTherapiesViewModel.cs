using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class DiseaseReportAntiviralTherapiesViewModel
    {
        public int AntibioticID { get; set; }      
        public long idfAntimicrobialTherapy { get; set; }
        public long idfHumanCase { get; set; }
        public DateTime? datFirstAdministeredDate { get; set; }
        public string strAntimicrobialTherapyName { get; set; }
        public string strDosage { get; set; }

        public string? rowAction { get; set; }

        public int intRowStatus { get; set; }

        public bool Selected { get; set; }



    }
}
