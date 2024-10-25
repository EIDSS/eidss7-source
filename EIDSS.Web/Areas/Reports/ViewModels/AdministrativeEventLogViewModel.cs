using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class AdministrativeEventLogViewModel : ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }


        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        public string StartIssueDate { get; set; }


        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        public string EndIssueDate { get; set; }

        public string JavascriptToRun { get; set; }

    }

    public class AdministrativeEventLogQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
    }
}

