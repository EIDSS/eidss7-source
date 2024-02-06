using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.ActiveSurveillanceSession
{
    public class ActiveSurveillanceSessionDetailPageViewModel
    {
        public long? SessionID { get; set; }
        public bool IsReadonly { get; set; }
        public long? CampaignId { get; set; }

    }
  
 }
