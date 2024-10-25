using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Human
{
    /// <summary>
    /// Page view model used to support the DiseaseReportSample Blazor Component
    /// Use this page view model to push data to the component while populating the view
    /// model from your specific domain view model like Human, Vet, etc.
    /// </summary>
    public class DiseaseReportFinalOutcomeViewModel
    {
        public long? idfHumanCase { get; set; }

        public long idfsSite { get; set; }

        public List<BaseReferenceEditorsViewModel> FinalCaseClassification { get; set; }

        public UserPermissions Permissions { get; set; }

        public long? idfDisease { get; set; }

        public string? strDisease { get; set; }

        [IsValidDate]
        public DateTime? dateOfDiagnosis { get; set; }
        public string strCaseId { get; set; }
        public long? idfsFinalCaseStatus { get; set; }
        public string strFinalCaseStatus { get; set; }
        public DateTime? datFinalCaseClassificationDate { get; set; }
        public bool? blnClinicalDiagBasis { get; set; } = false;
        public bool? blnLabDiagBasis { get; set; } = false;
        public bool? blnEpiDiagBasis { get; set; } = false;
        public long? idfsOutCome { get; set; }
        public string Outcome { get; set; }
        public DateTime? datDateOfDeath { get; set; }
        public DateTime? datDateOfDischarge { get; set; }
        public string strEpidemiologistsName { get; set; }
        public long? idfInvestigatedByPerson { get; set; }
        public string Comments { get; set; }
        public long? idfInvestigatedByOffice { get; set; }
        public bool? blnInitialSSD { get; set; }
        public bool? blnFinalSSD { get; set; }
        public bool IsReportClosed { get; set; } = false;

        [IsValidDate]
        public DateTime? datSampleStatusDate { get; set; }
        public bool showWarningForFinalCaseClassification { get; set; }
        public List<EventSaveRequestModel> Events { get; set; } = new List<EventSaveRequestModel>();
    }
}
