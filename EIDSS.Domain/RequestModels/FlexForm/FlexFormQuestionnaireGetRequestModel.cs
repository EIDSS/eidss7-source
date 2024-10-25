using EIDSS.Domain.ResponseModels.FlexForm;
using System.Collections.Generic;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormQuestionnaireGetRequestModel
    {
        public string Title { get; set; }
        public string SubmitButtonID { get; set; }
        public string ObserationFieldID { get; set; }
        public string LangID { get; set; }
        public long? idfsDiagnosis { get; set; }
        public long? idfsFormType { get; set; }
        public long? idfObservation { get; set; }
        public long? idfsFormTemplate { get; set; }
        public List<FlexFormMatrixData> MatrixData { get; set; }
        public List<string> MatrixColumns { get; set; }
        public List<string> MatrixColumnStyles { get; set; }
        public string observationList { get; set; }
        public string User { get; set; }
        public bool EnableInterprocess { get; set; } = false;
        public string CallbackFunction { get; set; }
        public string CallbackErrorFunction { get; set; }
        public long TagID { get; set; } = 0;
        public IList<FlexFormActivityParametersListResponseModel> ReviewAnswers { get; set; }
        public bool IsFormDisabled { get; set; } = false;
        public long? idfVersion { get; set; }

    }

    public class FlexFormMatrixData
    {
        public long idfRow { get; set; }
        public List<string> MatrixData { get; set; }
    }
}
