using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class AggregateReportGetListDetailRequestModel
    {
        public string LanguageID { get; set; }
        public long? idfAggrCase { get; set; }
        public long? idfsAggrCaseType { get; set; }
        [Required]
        public long? UserSiteID { get; set; }
        [Required]
        public long? UserOrganizationID { get; set; }
        [Required]
        public long? UserEmployeeID { get; set; }
        public bool? ApplyFiltrationIndicator { get; set; } = false;
    }
}