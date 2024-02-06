using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportCaseInvestigationRiskFactorsPageViewModel
    {
       

        public FlexFormQuestionnaireGetRequestModel RiskFactors { get; set; }

        public bool IsReportClosed { get; set; } = false;
        public bool isOutbreakCase { get; set; } = false;
        public string AdditionalComments { get; set; }

    }
}
