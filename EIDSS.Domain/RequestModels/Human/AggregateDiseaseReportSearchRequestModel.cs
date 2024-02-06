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
        public long? AggregateReportTypeID { get; set; }
        public string ReportID { get; set; }

        public string LegacyID { get; set; }
        public long? AdministrativeUnitTypeID { get; set; }
        public long? TimeIntervalTypeID { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? StartDate { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
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
