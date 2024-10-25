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
    public class DiseaseReportVaccinationViewModel
    {
        public int VaccinationID { get; set; }
        public long humanDiseaseReportVaccinationUID { get; set; }
        public long idfHumanCase { get; set; }
        public string vaccinationName { get; set; }
        public DateTime? vaccinationDate { get; set; }

        public string? rowAction { get; set; }

        public int intRowStatus { get; set; }



    }
}
