using System.Collections.Generic;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class AggregateSettingsGetRequestModel : BaseGetRequestModel
    {
        public long? IdfCustomizationPackage { get; set; }
        public long? idfsSite { get; set; }
    }

    public class AggregateSettingsSaveRequestModel : BaseSaveRequestModel
    {
        public List<AggregateSettingRecordsSaveRequestModel> AggregateSettingRecordsList { get; set; }
        public string AggregateSettingRecords { get; set; }
        public string Events { get; set; }
    }

    public class AggregateSettingRecordsSaveRequestModel
    {
        public long? AggregateDiseaseReportTypeId { get; set; }
        public long? CustomizationPackageId { get; set; }
        public long? SiteId { get; set; }
        public long? StatisticalAreaTypeId { get; set; }
        public long? StatisticalPeriodTypeId { get; set; }
    }
}
