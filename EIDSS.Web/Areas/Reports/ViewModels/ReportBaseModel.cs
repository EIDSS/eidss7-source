using System;
using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.ViewModels
{
    public class ReportBaseModel
    {
        public string ReportName { get; set; } = "Report Tile";

        public List<ReportLanguageModel> ReportLanguageModels { get; set; }

        [Required]
        [DisplayName("Language")]
        public string LanguageId { get; set; }

        public string PriorLanguageId { get; set; }

        [DisplayName("Use Archive Data")]
        public bool UseArchiveData { get; set; } = false;

        [DisplayName("Include Signature")]
        public bool IncludeSignature { get; set; } = false;

        public string SelectedCultureInfoName { get; set; }
        public string SelectedUICultureInfoName { get; set; }

        public bool ShowUseArchiveData { get; set; } = false;

        public bool ShowIncludeSignature { get; set; } = false;


    }

    public class ReportQueryBaseModel
    {
        public string ReportName { get; set; }

        public string LanguageId { get; set; }

        public string PriorLanguageId { get; set; }

        public string UseArchiveData { get; set; }

        public string IncludeSignature { get; set; }

        public DateTime PrintDateTime { get; set; }

        public ReportQueryBaseModel()
        {
            PrintDateTime = new DateTime();
        }
    }
}
