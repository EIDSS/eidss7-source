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
    public class DiseaseReportTestNameForDiseasesViewModel
    {
        public long idfTestForDisease { get; set; }
        public long idfsDiagnosis { get; set; }
        public string strDisease { get; set; }
        public long? idfsTestName { get; set; }
        public string strTestName { get; set; }
        public long? idfsTestCategory { get; set; }
        public string strTestCategory { get; set; }
        public long? idfsSampleType { get; set; }
        public string strSampleType { get; set; }

    }
}
