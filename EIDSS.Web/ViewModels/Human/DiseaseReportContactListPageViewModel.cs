using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportContactListPageViewModel
    {
        public long? HumanID { get; set; }

        public long? HumanActualID { get; set; }

        public long? idfHumanCase { get; set; }

        public bool isEdit { get; set; }

        public DiseaseReportContactDetailsViewModel AddContactDetails { get; set; }

        public List<DiseaseReportContactDetailsViewModel> ContactDetails { get; set; }
        
        public bool IsReportClosed { get; set; } = false;

        //Outbreak
        public FlexFormQuestionnaireGetRequestModel ContactTracingFlexFormRequest { get; set; }
    }
}
