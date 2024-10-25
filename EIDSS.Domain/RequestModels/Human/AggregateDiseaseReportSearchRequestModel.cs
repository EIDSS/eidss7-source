using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.RequestModels.Human
{
    public class AggregateDiseaseReportSearchRequestModel : BaseGetRequestModel
    {
        //public string LanguageID { get; set; }
        public long? AggregateReportTypeID { get; set; }
        public string ReportID { get; set; }

        public string LegacyID { get; set; }
        //[LocalizedRequired]
        public long? AdministrativeUnitTypeID { get; set; }  //todo: rename to administrative unit type ID once human agg complete.
        //[LocalizedRequired]
        public long? TimeIntervalTypeID { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public long? AdministrativeUnitID { get; set; }  //todo: rename to administrative unit ID once human agg complete.
        public long? OrganizationID { get; set; }
        public bool? SelectAllIndicator { get; set; }
        public long UserSiteID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserOrganizationID { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; }
        //public long? SiteGroupID { get; set; }
        //public bool ApplyNonConfigurableFiltrationIndicator { get; set; }
        //public bool ApplyConfigurableFiltrationIndicator { get; set; }
        //public int PaginationSetNumber { get; set; }
        public bool OrganizationIDDisabledIndicator { get; set; }
    }
}
