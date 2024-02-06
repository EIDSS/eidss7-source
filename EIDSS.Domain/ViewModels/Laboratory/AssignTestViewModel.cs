using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class AssignTestViewModel 
    {        
        public bool FilterTestNameByDisease { get; set; }
        [LocalizedRequired]
        public long DiseaseID { get; set; }
        [LocalizedRequired]
        public long? TestNameTypeID { get; set; }
        public long? TestResultTypeID { get; set; }
        public List<TestingGetListViewModel> Tests { get; set; }
        public List<TestingGetListViewModel> PendingSaveTests { get; set; }
        public List<BaseReferenceViewModel> TestNameTypes { get; set; }
        public bool IsSaveDisabled { get; set; }
        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; }
    }
}
