using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication
{
    public class HumanDiseaseReportDeduplicationDetailsViewModel
    {
        public long LeftHumanDiseaseReportID { get; set; }
        public long RightHumanDiseaseReportID { get; set; }
        public HumanDiseaseReportDeduplicationNotificationSectionViewModel NotificationSection { get; set; }
        public HumanDiseaseReportDeduplicationSymptomsSectionViewModel SymptomsSection { get; set; }

        public HumanDiseaseReportDeduplicationFacilityDetailsSectionViewModel FacilityDetailSection { get; set; }
        public HumanDiseaseReportDeduplicationAntibioticVaccineHistorySectionViewModel AntibioticVaccineHistorySection { get; set; }

        public HumanDiseaseReportDeduplicationSamplesSectionViewModel SamplesSection { get; set; }
        public HumanDiseaseReportDeduplicationTestsSectionViewModel TestsSection { get; set; }

        public HumanDiseaseReportDeduplicationCaseInvestigationDetailsSectionViewModel CaseInvestigationDetailsSection { get; set; }
        public HumanDiseaseReportDeduplicationRiskFactorsSectionViewModel CaseInvestigationRiskFactorsSection { get; set; }

        public HumanDiseaseReportDeduplicationContactsSectionViewModel ContactsSection { get; set; }
        public HumanDiseaseReportDeduplicationFinalOutcomeSectionViewModel FinalOutcomeSection { get; set; }
        
    }
}
