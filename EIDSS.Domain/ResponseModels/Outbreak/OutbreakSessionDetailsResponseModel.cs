using System;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakSessionDetailsResponseModel
    {
        public long? idfOutbreak { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionDiseaseFieldLabel))]
        [LocalizedRequired]
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public string strDiagnosis { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionStatusFieldLabel))]
        [LocalizedRequired]
        public long? idfsOutbreakStatus { get; set; }
        public string strOutbreakStatus { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakSessionTypeFieldLabel))]
        [LocalizedRequired]
        public long? OutbreakTypeId { get; set; }
        public string strOutbreakType { get; set; }
        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
        public long? PostalCodeID { get; set; }
        public string PostalCode { get; set; }
        public long? StreetID { get; set; }
        public string StreetName { get; set; }
        public string House { get; set; }
        public string Building { get; set; }
        public string Apartment { get; set; }

        private DateTime? dtStartDate;
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(datStartDate), "SessionDetails_datStartDate", nameof(datCloseDate), "SessionDetails_datCloseDate", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.OutbreakSessionStartDateFieldLabel), nameof(FieldLabelResourceKeyConstants.OutbreakSessionEndDateFieldLabel))]
        [LocalizedRequired]
        public DateTime? datStartDate
        {
            get { return dtStartDate; }
            set
            {
                dtStartDate = value;
                StartDate = DateTime.Parse(value.ToString()).ToShortDateString();
            }
        }

        public string StartDate { get; set; }
        public string Today { get; set; }

        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(datCloseDate), "SessionDetails_datCloseDate", nameof(datStartDate), "SessionDetails_datStartDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.OutbreakSessionEndDateFieldLabel), nameof(FieldLabelResourceKeyConstants.OutbreakSessionStartDateFieldLabel))]
        public DateTime? datCloseDate { get; set; }
        public string strOutbreakID { get; set; }
        public string strDescription { get; set; }
        public int intRowStatus { get; set; }
        public Guid rowguid { get; set; }
        public DateTime? datModificationForArchiveDate { get; set; }
        public long? idfPrimaryCaseOrSession { get; set; }
        public long idfsSite { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }

        public long HumanOutbreakSpeciesParameterUID { get; set; }
        public long? HumanCaseQuestionaireTemplateID { get; set; }
        public long? HumanCaseMonitoringTemplateID { get; set; }
        public long? HumanContactTracingTemplateID { get; set; }
        public int? txtHumanCaseMonitoringDuration { get; set; }
        public int? txtHumanCaseMonitoringFrequency { get; set; }
        public int? txtHumanContactTracingDuration { get; set; }
        public int? txtHumanContactTracingFrequency { get; set; }

        public long AvianOutbreakSpeciesParameterUID { get; set; }
        public long? AvianCaseQuestionaireTemplateID { get; set; }
        public long? AvianCaseMonitoringTemplateID { get; set; }
        public long? AvianContactTracingTemplateID { get; set; }
        public int? txtAvianCaseMonitoringDuration { get; set; }
        public int? txtAvianCaseMonitoringFrequency { get; set; }
        public int? txtAvianContactTracingDuration { get; set; }
        public int? txtAvianContactTracingFrequency { get; set; }

        public long LivestockOutbreakSpeciesParameterUID { get; set; }
        public long? LivestockCaseQuestionaireTemplateID { get; set; }
        public long? LivestockCaseMonitoringTemplateID { get; set; }
        public long? LivestockContactTracingTemplateID { get; set; }
        public int? txtLivestockCaseMonitoringDuration { get; set; }
        public int? txtLivestockCaseMonitoringFrequency { get; set; }
        public int? txtLivestockContactTracingDuration { get; set; }
        public int? txtLivestockContactTracingFrequency { get; set; }

        public bool idfscbHuman { get; set; } = false;
        public bool idfscbAvian { get; set; } = false;
        public bool idfscbLivestock { get; set; } = false;
        public bool idfscbVector { get; set; } = false;

        public bool bHuman { get; set; }
        public bool bAvian { get; set; }
        public bool bLivestock { get; set; }
        public bool bVector { get; set; }

        public bool bHasHumanCases { get; set; }
        public bool bHasVetCases { get; set; }

        public bool bShowSuccessMessage { get; set; }
        public bool bShowOutbreakID { get; set; }

        public long? OriginalOutbreakStatusTypeId { get; set; }
    }
}
