using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
	[DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
	public class AccessRuleSaveRequestModel : BaseSaveRequestModel
	{
		public AccessRuleGetDetailViewModel AccessRuleDetails { get; set; }
		public string ReceivingActors { get; set; }
	}
}