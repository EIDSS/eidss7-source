﻿using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class ReportOnCasesOfAnnualFormIV03ViewModel  :ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<GisLocationCurrentLevelModel> GisRayonList { get; set; }

        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Rayon")]
        [LocalizedRequired]
        public long? RayonId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ReportOnCasesOfAnnualFormIV03QueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string RayonId { get; set; }
    }
}

