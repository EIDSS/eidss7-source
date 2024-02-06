namespace EIDSS.Domain.ResponseModels.Veterinary
{
    public class DiseaseReportSaveRequestResponseModel : APIPostResponseModel
    {
        public long? DiseaseReportID { get; set; }
        public string EIDSSReportID { get; set; }
        public long? CaseID { get; set; }
        public string EIDSSCaseID { get; set; }
        public long? ConnectedDiseaseReportLaboratoryTestID { get; set; }
    }
}