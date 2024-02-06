using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class WeeklyReportSaveRequestModel
    {
        public long? idfReportForm { get; set; }
        public string strReportFormID { get; set; }
        public long? idfsReportFormType { get; set; }
        public long? GeographicalAdministrativeUnitID { get; set; }
        public long? idfSentByOffice { get; set; }
        public long? idfSentByPerson { get; set; }
        public long? idfEnteredByOffice { get; set; }
        public long? idfEnteredByPerson { get; set; }
        public DateTime? datSentByDate { get; set; }
        public DateTime? datEnteredByDate { get; set; }
        public DateTime? datStartDate { get; set; }
        public DateTime? datFinishDate { get; set; }
        public long? idfDiagnosis { get; set; }
        public int? total { get; set; }
        public long? SiteID { get; set; }
        public long? UserID { get; set; }
        public int? notified { get; set; }
        public string comments { get; set; }
        public DateTime? datModificationForArchiveDate { get; set; }

        public string requestResult { get; set; }
    }
}
