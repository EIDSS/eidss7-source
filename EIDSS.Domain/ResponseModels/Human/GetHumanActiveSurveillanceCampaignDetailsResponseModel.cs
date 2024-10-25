using System;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.ResponseModels.Human
{
	public class GetHumanActiveSurveillanceCampaignDetailsResponseModel
	{

		public long CampaignID { get; set; }
		public long CampaignTypeID { get; set; }
		public string CampaignTypeName { get; set; }
		public long CampaignStatusTypeID { get; set; }
		public string CampaignStatusTypeName { get; set; }
		public long DiseaseID { get; set; }
		public string DiseaseName { get; set; }
		public long SampleTypeID { get; set; }
		public string SampleTypeName { get; set; }

		[DateComparer(nameof(CampaignStartDate), "CampaignStartDate", nameof(CampaignEndDate), "CampaignEndDate", CompareTypeEnum.LessThanOrEqualTo, nameof(CampaignStartDate), nameof(CampaignEndDate))]
        [LocalizedDateLessThanOrEqualToToday]
		[IsValidDate]
		public DateTime CampaignStartDate { get; set; }
		public DateTime CampaignEndDate { get; set; }
		public string EIDSSCampaignID { get; set; }

		[LocalizedRequired]
		public string CampaignName { get; set; }
		public string PlannedNumber { get; set; }
		public string CampaignAdministrator { get; set; }
		public string Conclusion { get; set; }
		public long SiteId { get; set; }

	}
}
