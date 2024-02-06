using EIDSS.Domain.RequestModels.FlexForm;

namespace EIDSS.Web.ViewModels.CrossCutting
{
    public class DiseaseMatrixSectionViewModel
    {
        public Select2Configruation MatrixVersions { get; set; }
        public Select2Configruation Templates { get; set; }
        public long? idfsFormTemplate { get; set; }
        public long? idfVersion { get; set; }
        public FlexFormQuestionnaireGetRequestModel AggregateCase { get; set; }
        public string versionList { get; set; }
    }
}