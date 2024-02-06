using EIDSS.Domain.Abstracts;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanPersonSearchRequestModel : BaseGetRequestModel
    {
        public string EIDSSPersonID { get; set; }
        public long? PersonalIDType { get; set; }
        public string PersonalID { get; set; }
        public string FirstOrGivenName { get; set; }
        public string SecondName { get; set; }
        public string LastOrSurname { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? DateOfBirthFrom { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? DateOfBirthTo { get; set; }
        public long? GenderTypeID { get; set; }
        public long? idfsLocation { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? SettlementTypeID { get; set; }
        public bool? RecordIdentifierSearchIndicator { get; set; }
    }
}