using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class OMMCaseDetailModel : BaseModel
    {
            public long? idfOutbreak { get; set; }
            public long? idfHumanActual { get; set; }
            public DateTime? datNotificationDate { get; set; }
            public long? idfSentByOffice { get; set; }
            public long? idfSentByPerson { get; set; }
            public long? idfReceivedByOffice { get; set; }
            public long? idfReceivedByPerson { get; set; }
            public long? idfsCountry { get; set; }
            public long? idfsRegion { get; set; }
            public long? idfsRayon { get; set; }
            public long? idfsSettlement { get; set; }
            public string strStreetName { get; set; }
            public string strPostCode { get; set; }
            public string strBuilding { get; set; }
            public string strHouse { get; set; }
            public string strApartment { get; set; }
            public double? dblLatitude { get; set; }
            public double? dblLongitude { get; set; }
            public long? OutbreakCaseStatusID { get; set; }
            public DateTime? datOnSetDate { get; set; }
            public DateTime? datFinalDiagnosisDate { get; set; }
            public long? idfHospital { get; set; }
            public DateTime? datHospitalizationDate { get; set; }
            public DateTime? datDischargeDate { get; set; }
            public string strClinicalNotes { get; set; }
            public string strNote { get; set; }
            public string Antimicrobials { get; set; }
            public string Vaccinations { get; set; }
            public long? idfInvestigatedByOffice { get; set; }
            public long? idfInvestigatedByPerson { get; set; }
            public DateTime? datInvestigationStartDate { get; set; }
            public long? OutbreakCaseClassificationID { get; set; }
            public string IsPrimaryCaseFlag { get; set; }
            public string InvestigationAdditionalComments { get; set; }
            public string datMonitoringDate { get; set; }
            public string MonitoringAdditionalComments { get; set; }
            public string MonitoringInvestigatorOrganization { get; set; }
            public string MonitoringInvestigatorName { get; set; }
            public string Contacts { get; set; }
            public string Samples { get; set; }
            public string Tests { get; set; }
            public long? idfsYNAntimicrobialTherapy { get; set; }
            public long? idfsYNHospitalization { get; set; }
            public long? idfsYNSpecificVaccinationAdministered { get; set; }
            public long? OutbreakCaseObservationID { get; set; }
            public long? OutbreakCaseObservationFormType { get; set; }
            public long? CaseEPIObservationID { get; set; }
            public long? CaseEPIObservationFormType { get; set; }
            public string CaseMonitorings { get; set; }
            public long? idfEpiObservation { get; set; }
    }
}
