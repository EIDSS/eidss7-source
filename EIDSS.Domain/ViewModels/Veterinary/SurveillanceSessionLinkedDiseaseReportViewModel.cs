using System.Collections;
using System.Collections.Generic;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class SurveillanceSessionLinkedDiseaseReportViewModel
    {
        public long SessionKey { get; set; }
        public long? DiseaseReportId { get; set; }
        public long ReportTypeId { get; set; }
        public string SessionId { get; set; }
        public long? FarmMasterId { get; set; }
        public long? DiseaseId { get; set; }
        public IList<FarmInventoryGetListViewModel> FarmInventory { get; set; }
        public IList<AnimalGetListViewModel> Animals { get; set; }
        public IList<SampleGetListViewModel> Samples { get; set; }
        public IList<LaboratoryTestGetListViewModel> LaboratoryTests { get; set; }
        public IList<LaboratoryTestInterpretationGetListViewModel> TestInterpretations { get; set; }
        public bool IsEdit { get; set; }
        public bool IsReadOnly { get; set; }
        public bool IsReview { get; set; }
        public bool SessionInventoryProcessed { get; set; }
    }
}
