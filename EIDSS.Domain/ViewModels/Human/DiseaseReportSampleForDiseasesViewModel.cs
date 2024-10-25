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
    public class DiseaseReportSampleForDiseasesViewModel
    {
        public long? idfsSampleType { get; set; }
        public string strSampleType { get; set; }

    }
}
