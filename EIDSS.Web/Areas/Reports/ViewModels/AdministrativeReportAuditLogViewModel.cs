using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class AdministrativeReportAuditLogViewModel  :ReportBaseModel
    {
        public List<BaseReferenceViewModel> DiagnosisList { get; set; }
        public List<ReportListViewModel> ReportsList { get; set; }

        [DisplayName("Report Name")]
        public string ReportsName { get; set; }


        [DisplayName("Start Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:MM/dd/yyyy}")]
        public string StartIssueDate { get; set; }

        [DisplayName("End Issue Date")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:MM/dd/yyyy}")]
        public string EndIssueDate { get; set; }

        [DisplayName("User First Name")]
        public string UserFirstName { get; set; }

        [DisplayName("User Last Name")]
        public string UserLastName { get; set; }

        [DisplayName("User Middle Name")]
        public string UserMiddleName { get; set; }

        public string JavascriptToRun { get; set; }

    }

    public class AdministrativeReportAuditLogQueryModel:ReportQueryBaseModel
    {
        public string ReportsName { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string UserFirstName { get; set; }
        public string UserLastName { get; set; }
        public string UserMiddleName { get; set; }

    }
}

