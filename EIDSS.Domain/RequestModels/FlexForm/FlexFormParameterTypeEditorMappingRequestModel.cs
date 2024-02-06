using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
	public class FlexFormParameterTypeEditorMappingRequestModel
    {
		public string LanguageID { get; set; }
		public long idfsParameterType { get; set; }
	}
}
