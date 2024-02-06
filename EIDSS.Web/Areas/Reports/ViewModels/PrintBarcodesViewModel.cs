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
    public class PrintBarcodesViewModel : ReportBaseModel
    {
        public List<BaseReferenceViewModel> TypeOfBarCodeLabelList { get; set; }
        public List<Age> NoOfLabelsToPrintList { get; set; }


        [DisplayName("Type Of Bar Code Label")]
        [LocalizedRequired]
        public string TypeOfBarCodeLabel { get; set; }


        [DisplayName("NoOfLabelsToPrint")]
        [LocalizedRequired]
        public string NoOfLabelsToPrint { get; set; }

        [DisplayName("Prefix")]
        public bool Prefix { get; set; }

        [DisplayName("Site")]
        public bool Site { get; set; }

        [DisplayName("Year")]
        public bool Year { get; set; }

        [DisplayName("Date")]
        public bool Date { get; set; }

        public string JavascriptToRun { get; set; }

    }

    public class PrintBarcodesQueryModel:ReportQueryBaseModel
    {
        public string TypeOfBarCodeLabel { get; set; }
        public string NoOfLabelsToPrint { get; set; }
        public string Prefix { get; set; }
        public string Site { get; set; }
        public string Year { get; set; }
        public string Date { get; set; }

    }
}

