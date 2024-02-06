namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakFlexFormDesignerModel
    {
        public long? idfOutbreak { get; set; }
        public string? strOutbreakID { get; set; }
        public long? flexFormType { get; set; }
        public long? outbreakSpeciesParameterUID { get; set; }
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public string? strDiagnosis { get; set; }
        public long? idfsFormTemplate { get; set; }
    }
}
