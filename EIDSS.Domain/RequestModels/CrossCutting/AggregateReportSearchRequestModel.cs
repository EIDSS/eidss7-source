using EIDSS.Domain.Abstracts;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class AggregateReportSearchRequestModel : BaseGetRequestModel
    {
        public long? AggregateReportTypeID { get; set; }
        public string ReportID { get; set; }
        public string LegacyReportID { get; set; }
        public long? AdministrativeUnitTypeID { get; set; }  
        public long? TimeIntervalTypeID { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public long? AdministrativeUnitID { get; set; }  
        public long? OrganizationID { get; set; }
        public bool? SelectAllIndicator { get; set; }
        public long UserSiteID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserOrganizationID { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; }
        public bool OrganizationIDDisabledIndicator { get; set; }
    }
}
