using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class FilteredDiseaseGetListViewModel : BaseModel
    {
        public long DiseaseID { get; set; }
        public int? intHACode { get; set; }
        public string DiseaseName { get; set; }
        public string ICD10 { get; set; }
        public string OIECode { get; set; }
        public long? UsingType { get; set; }

        /// <summary>
        /// Used when registering laboratory samples for human and veterinary active surveillance sessions.
        /// </summary>
        public long? SampleTypeID { get; set; }
    }
}