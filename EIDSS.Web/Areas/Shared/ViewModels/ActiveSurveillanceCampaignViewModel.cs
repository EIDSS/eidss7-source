using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Shared.ViewModels
{
    public class ActiveSurveillanceCampaignViewModel
    {

        public ActiveSurveillanceCampaignViewModel()
        {
            ActiveSurveillanceCampaignDetail = new ActiveSurveillanceCampaignDetailViewModel();
            DiseaseSpeciesSampleList = new List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>();
            VetCampaignSessionList = new List<VeterinaryActiveSurveillanceSessionViewModel>();
            HumanCampaignSessionList = new List<ActiveSurveillanceSessionResponseModel>();
            Permissions = new UserPermissions();
        }

        public ActiveSurveillanceCampaignDetailViewModel ActiveSurveillanceCampaignDetail { get; set; }
        public List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> DiseaseSpeciesSampleList { get; set; }
        public List<VeterinaryActiveSurveillanceSessionViewModel> VetCampaignSessionList { get; set; }
        public List<ActiveSurveillanceSessionResponseModel> HumanCampaignSessionList { get; set; }
        public List<EventSaveRequestModel> PendingSaveEvents { get; set; }

        public UserPermissions Permissions { get; set; }
        public long? CampaignID { get; set; }
        public bool IsReadonly { get; set; }
        public bool IsDiseaseSpeciesSampleGridInEditMode { get; set; }

    }
}

