using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class VaccinationGetListRequestModel : BaseGetRequestModel
    {
        public long DiseaseReportID { get; set; }
        public long? SpeciesID { get; set; }
    }
}
