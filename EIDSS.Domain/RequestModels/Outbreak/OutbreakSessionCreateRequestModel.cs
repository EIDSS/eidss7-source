using EIDSS.Domain.Attributes;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class OutbreakSessionCreateRequestModel
    {
        public string LangID { get; set; }
        public long? idfOutbreak { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionDiseaseFieldLabel))]
        [LocalizedRequired]
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionStatusFieldLabel))]
        [LocalizedRequired]
        public long? idfsOutbreakStatus { get; set; }
        public long? OriginalOutbreakStatusTypeId { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionTypeFieldLabel))]
        [LocalizedRequired]
        public long? OutbreakTypeId { get; set; }
        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public long? AdminLevel2Value { get; set; }
        public long? AdminLevel3Value { get; set; }
        public long? idfsLocation { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionStartDateFieldLabel))]
        [LocalizedRequired]
        public DateTime datStartDate { get; set; }
        public DateTime? datCloseDate { get; set; }
        public string strOutbreakID { get; set; }
        public string strDescription { get; set; }
        public int? intRowStatus { get; set; }
        public DateTime? datModificationForArchiveDate { get; set; }
        public long? idfPrimaryCaseOrSession { get; set; }
        public long idfsSite { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
        public string OutbreakParameters { get; set; }
        public string User { get; set; }
        public OutbreakSessionDetailsResponseModel SessionDetails { get; set; }
        public List<EventSaveRequestModel> PendingSaveEvents { get; set; }
        public string Events { get; set; }
    }

    public class OutbreakSessionParameters
    {
        public long? OutbreakSpeciesParameterUID { get; set; }
        public long OutbreakSpeciesTypeID { get; set; }
        public int? CaseMonitoringDuration { get; set; } 
        public int? CaseMonitoringFrequency { get; set; } 
        public int? ContactTracingDuration { get; set; } 
        public int? ContactTracingFrequency { get; set; }
        public int intRowStatus { get; set; }
    }
}

