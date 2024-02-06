using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class SiteAlertsSubscriptionListViewModel
    {

        //public List<EventSubscriptionTypeModel> eventSubscriptionTypeModels { get; set; }
        //public List<AlertRecipients> alertRecipients  { get; set; }
        public bool WritePermission { get; set; }
        public bool ReadPermission { get; set; }
    }

    public class AlertRecipients
    {
        public string Id { get; set; }
        public string Value { get; set; }
    }
}
