using EIDSS.Domain.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.ViewModels.Human;

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class HumanDiseaseReportDeduplicationBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected HumanDiseaseReportDeduplicationSessionStateContainerService HumanDiseaseReportDeduplicationService { get; set; }

        //[Inject]
        //protected ProtectedSessionStorage BrowserStorage { get; set; }

        [Inject]
        private ILogger<HumanDiseaseReportDeduplicationBaseComponent> Logger { get; set; }
        #endregion

        #region Private Variables

        //private CancellationTokenSource source;
        //private CancellationToken token;

        #endregion

        #region Protected and Public Variables

        //protected const int HUMANADDRESSNUMBERFIELD = 11;
        //protected const int HUMANALTADDRESSNUMBERFIELD = 9;
        //protected const int EMPLOYERADDRESSNUMBERFIELD = 9;
        //protected const int SCHOOLADDRESSNUMBERFIELD = 9;

        protected const int SentByPerson = 7;
        protected const int ReceivedByPerson = 9;
        protected const int idfsFinalDiagnosis = 12;
        protected const int idfsFinalState = 11;
        protected const int idfSentByOffice = 12;
        protected const int idfSentByPerson = 13;
        protected const int idfReceivedByOffice = 14;
        protected const int idfReceivedByPerson = 15;
        protected const int idfsHospitalizationStatus = 16;

        protected const int idfsInitialCaseStatus = 3;
        protected const int idfCSObservation = 2;

        protected const int idfsYNHospitalization = 8;
        protected const int idfSoughtCareFacility = 9;
        protected const int idfsNonNotifiableDiagnosis = 10;
        protected const int idfsYNPreviouslySoughtCare = 11;
        protected const int idfHospital = 12;


        protected const int idfsYNAntimicrobialTherapy = 1;
        protected const int idfsYNSpecificVaccinationAdministered = 1;
        protected const int idfHumanCase = 1;

        protected const int idfsYNSpecimenCollected = 1;
        protected const int idfsYNTestsConducted = 1;

        protected const int YNExposureLocationKnown = 4;
        protected const int idfPointGeoLocation = 18;
        protected const int idfsYNExposureLocationKnown = 19;
        protected const int idfsPointGeoLocationType = 20;
        protected const int idfsPointRegion = 21;
        protected const int idfsPointRayon = 22;
        protected const int idfsPointSettlement = 23;
        protected const int idfsPointCountry = 24;
        protected const int idfInvestigatedByOffice = 26;
        protected const int idfOutbreak = 27;
        // protected const int idfsYNRelatedToOutbreak = 23;

        protected const int idfsFinalCaseStatus = 6;
        protected const int idfsOutcome = 7;
        protected const int idfInvestigatedByPerson = 8;

        protected const int HumanidfsRegion = 41;
        protected const int IsEmployedTypeID = 33;

        protected const int ExposureLocationFIELD = 22;

        protected const int HumanAltidfsRegion = 47;
        //protected const int HumanAltidfsRayon = 38;
        //protected const int HumanAltidfsSettlementType = 39;
        //protected const int HumanAltidfsSettlement = 40;
        //protected const int HumanAltGeoLocationID = 41;
        protected const int HumanAltidfsCountry = 46;
        protected const int ContactPhoneTypeID = 52;
        protected const int ContactPhone2TypeID = 53;

        protected const int EmployeridfsRegion = 35;
        //protected const int EmployeridfsRayon = 35;
        //protected const int EmployeridfsSettlementType = 36;
        //protected const int EmployeridfsSettlement = 37;
        protected const int EmployerGeoLocationID = 39;
        protected const int EmployeridfsCountry = 40;
        protected const int IsStudentTypeID = 41;
        protected const int SchoolidfsRegion = 42;
        //protected const int SchoolidfsRayon = 42;
        //protected const int SchoolAltidfsSettlementType = 43;
        //protected const int SchoolidfsSettlement = 44;
        protected const int SchoolGeoLocationID = 46;
        protected const int OccupationTypeID = 48;

        //protected bool disableMergeButton = true;
        protected bool disableMergeButton = false;
        protected bool showNextButton;
        protected bool showPreviousButton;
        protected bool showDetails = true;
        protected bool showReview = false;

        //public PersonDeduplicationTabEnum Tab { get; set; }

        protected Dictionary<string, int> keyDict0 = new Dictionary<string, int> {
                    {"strFinalDiagnosis", 0}, {"strCaseId", 1},
                    {"LegacyCaseID", 2}, {"CaseProgressStatus", 3}, {"EIDSSPersonID", 4}, {"ReportType", 5},
                    {"PatientFarmOwnerName", 6}, {"datEnteredDate", 7}, {"EnteredByPerson", 8}, {"strOfficeEnteredBy", 9},
                    {"datModificationDate", 10}, {"SummaryCaseClassification", 11},
                    {"idfsFinalDiagnosis", 12}, {"idfsCaseProgressStatus", 13}, {"DiseaseReportTypeID", 14}, {"idfPersonEnteredBy", 15},
                    {"idfOfficeEnteredBy", 16}
        };

        protected Dictionary<int, string> labelDict0 = new Dictionary<int, string> {
                    {0, "Disease"}, {1, "ReportID"},
                    {2, "LegacyID"}, {3, "ReportStatus"}, {4, "PersonID"}, {5, "ReportType"}, {6, "PersonName"},
                    {7, "DateEntered"}, {8, "EnteredBy"}, {9, "EnteredByOrganization"}, {10, "DateLastUpdated"}, {11, "CaseClassification"},
                    {12, "Disease"}, {13, "ReportStatus"}, {14, "ReportType"}, {15, "EnteredBy"},
                    {16, "EnteredByOrganization"}
        };

        protected Dictionary<string, int> keyDict = new Dictionary<string, int> {
                    {"datCompletionPaperFormDate", 0}, {"strLocalIdentifier", 1},
                    {"SummaryIdfsFinalDiagnosis", 2}, {"datDateOfDiagnosis", 3}, {"datNotificationDate", 4}, {"PatientStatus", 5},
                    {"SentByOffice", 6}, {"SentByPerson", 7}, {"ReceivedByOffice", 8}, {"ReceivedByPerson", 9},
                    {"HospitalizationStatus", 10}, {"strCurrentLocation", 11},
                    {"idfsFinalDiagnosis", 12}, {"idfsFinalState", 13}, {"idfSentByOffice", 14}, {"idfSentByPerson", 15},
                    {"idfReceivedByOffice", 16}, {"idfReceivedByPerson", 17}, {"idfsHospitalizationStatus", 18}
        };

        protected Dictionary<string, int> keyDict2 = new Dictionary<string, int> {
                    {"datOnSetDate", 0}, {"InitialCaseStatus", 1},{"idfCSObservation",2 }, {"idfsInitialCaseStatus", 3}
         };

        protected Dictionary<string, int> keyDict3 = new Dictionary<string, int> {
                    {"PreviouslySoughtCare", 0}, {"datFirstSoughtCareDate", 1}, {"strSoughtCareFacility", 2}, {"NonNotifiableDiagnosis", 3},
                    {"YNHospitalization", 4}, {"datHospitalizationDate", 5}, {"datDischargeDate", 6}, {"HospitalName", 7}, 
                    {"idfsYNHospitalization", 8}, {"idfSoughtCareFacility", 9}, {"idfsNonNotifiableDiagnosis", 10}, {"idfsYNPreviouslySoughtCare", 11}, {"idfHospital", 12}
        };

        protected Dictionary<string, int> keyDict4 = new Dictionary<string, int> {
                    {"YNAntimicrobialTherapy", 0},{"idfsYNAntimicrobialTherapy", 1}};

        protected Dictionary<string, int> keyDict5 = new Dictionary<string, int> {
                     {"YNSpecificVaccinationAdministered", 0 },{"idfsYNSpecificVaccinationAdministered", 1}};

        protected Dictionary<string, int> keyDict6 = new Dictionary<string, int> {
                    {"YNSpecimenCollected", 0},{"idfsYNSpecimenCollected", 1}};

        protected Dictionary<string, int> keyDict7 = new Dictionary<string, int> {
                    {"YNTestConducted", 0},{"idfsYNTestsConducted", 1}};

        protected Dictionary<string, int> keyDict8 = new Dictionary<string, int> {
                    {"InvestigatedByOffice", 0}, {"StartDateofInvestigation", 1}, 
            //{"YNRelatedToOutBreak", 2}, 
                    {"strOutbreakID", 2}, {"strNote", 3},
                    {"YNExposureLocationKnown", 4}, {"datExposureDate", 5}, 
                    {"ExposureLocationType", 6}, 
            //, {"ExposureLocationDescription", 6}
                    {"Country", 7}, {"Region",8}, {"Rayon", 9}, {"Settlement",10}, 
                    {"dblPointLatitude", 11}, {"dblPointLongitude", 12}, {"dblPointElevation", 13},
                    {"strGroundType", 14}, {"dblPointDistance", 15}, {"dblPointAlignment", 16}, 
                    {"strPointForeignAddress", 17},
                    {"idfPointGeoLocation", 18}, {"idfsYNExposureLocationKnown", 19}, {"idfsPointGeoLocationType", 20}, 
                    {"idfsPointRegion", 21}, {"idfsPointRayon", 22}, {"idfsPointSettlement", 23},
                    {"idfsPointCountry", 24},
                    {"idfsPointGroundType", 25},
                    {"idfInvestigatedByOffice", 26},     
                    //{"dblPointDistance", 22},
                    //{"dblPointAlignment", 23},
                    //{"strPointForeignAddress", 24},
                    {"idfOutbreak", 27}

            //, {"idfsYNRelatedToOutbreak", 23}
        };
        protected Dictionary<int, string> labelDict8 = new Dictionary<int, string>
                    {{0, "InvestigatedByOffice"}, {1, "StartDateofInvestigation"}, 
            //{2, "YNRelatedToOutBreak"},
                    {2, "strOutbreakID"}, {3, "strNote"},
                    {4, "YNExposureLocationKnown"}, {5, "datExposureDate"},
                    {6, "ExposureLocationType"}, 
            //, {6, "ExposureLocationDescription"}
                    {7, "Country"}, {8, "Region"}, {9, "Rayon"}, {10, "Settlement"},
                    {11, "dblPointLatitude"}, {12, "dblPointLongitude"}, {13, "dblPointElevation"},
                    {14, "GroundType"}, {15, "Distance"}, {16, "Direction"},
                    {17, "ForeignAddress"},
                    {18, "GeoLocation"}, {19, "YNExposureLocationKnown"}, {20, "idfsPointGeoLocationType"},
                    {21, "Region"}, {22, "Rayon"}, {23, "Settlement"},
                    {24, "Country"}, {25, "GroundType"},
                    {26, "InvestigatedByOffice"},
                    {27, "strOutbreakID"}
            //, {22, "YNRelatedToOutBreak"}
            };
        protected Dictionary<string, int> keyDict9 = new Dictionary<string, int> {
                   {"idfEpiObservation",0 }
         };
        protected Dictionary<int, string> labelDict = new Dictionary<int, string> {
                    {0, "CompletionPaperFormDate"}, {1, "LocalIdentifier"},
                    {2, "Disease"}, {3, "DateOfDisease"}, {4, "NotificationDate"}, {5, "PatientStatus"}, {6, "SentByOffice"},
                    {7, "SentByPerson"}, {8, "ReceivedByOffice"}, {9, "ReceivedByPerson"}, {10, "PatientCurrentLocation"}, {11, "OtherLocation"},
                    {12, "Disease"}, {13, "PatientStatus"}, {14, "SentByOffice"}, {15, "SentByPerson"},
                    {16, "ReceivedByOffice"}, {17, "ReceivedByPerson"}, {18, "PatientCurrentLocation"}
        };

        protected Dictionary<string, int> keyDict10 = new Dictionary<string, int> {
                    {"idfHumanCase",0 }};
        protected Dictionary<int, string> labelDict10 = new Dictionary<int, string>
                    {{0,"idfHumanCase" }};
        protected Dictionary<int, string> labelDict11 = new Dictionary<int, string>
        {{0, "FinalCaseStatus"}, {1, "DateofClassification"}, {2, "BasisofDiagnosis"}, {3, "Outcome"}
            ,{4,"strEpidemiologistsName"}
            //,{5,"datDateOfDeath"}
            , {5,"strSummaryNotes"}
            , {6, "FinalCaseStatus"}, {7, "Outcome"}
            , {8,"strEpidemiologistsName"}
        };


    protected Dictionary<string, int> keyDict11 = new Dictionary<string, int> {
                    {"FinalCaseStatus", 0}, {"DateofClassification", 1}, {"strClinicalDiagnosis", 2}, {"Outcome", 3},
        {"strEpidemiologistsName", 4 }, 
        //{"datDateOfDeath",5},
        {"strSummaryNotes",5},
        {"idfsFinalCaseStatus",6}, {"idfsOutCome", 7}
        ,{"idfInvestigatedByPerson",8} 
    };


    protected Dictionary<int, string> labelDict2 = new Dictionary<int, string>
                    {{0, "datOnSetDate"}, { 1, "InitialCaseStatus"},{2,"idfCSObservation" }, { 3, "InitialCaseStatus"}};

        protected Dictionary<int, string> labelDict3 = new Dictionary<int, string>
                    {{0, "PreviouslySoughtCare"}, {1, "datFirstSoughtCareDate"}, {2, "strSoughtCareFacility"}, {3, "NonNotifiableDiagnosis"},
                    {4, "YNHospitalization"}, {5, "datHospitalizationDate"}, {6, "datDischargeDate"}, {7, "HospitalName"},
                    {8, "idfsYNHospitalization"}, {9, "strSoughtCareFacility"}, {10, "NonNotifiableDiagnosis"}, {11, "PreviouslySoughtCare"}, {12, "HospitalName"}
        };

        protected Dictionary<int, string> labelDict4 = new Dictionary<int, string>
                    {{0, "YNAntimicrobialTherapy"},{1, "YNAntimicrobialTherapy"}};

        protected Dictionary<int, string> labelDict5 = new Dictionary<int, string>
                    {{0, "YNSpecificVaccinationAdministered"},{ 1, "YNSpecificVaccinationAdministered"}};

        protected Dictionary<int, string> labelDict6 = new Dictionary<int, string>
                    {{0, "YNSpecimenCollected"},{1, "YNSpecimenCollected"}};

        protected Dictionary<int, string> labelDict7 = new Dictionary<int, string>
                    {{0, "YNTestConducted"},{1, "YNTestConducted"}};

        //protected Dictionary<int, string> labelDict8 = new Dictionary<int, string>
        //            {{0, "InvestigatedByOffice"}, {1, "StartDateofInvestigation"}, {2, "RelatedToOutbreak"},
        //            {3, "OutbreakID"}, {4, "ExposureLocationKnown"}, {5, "ExposureDate"}, {6, "ExposureLocation"}, {7, "ExposureLocationDescription"}, {8, "Country"},
        //            {9, "Region"}, {10, "Rayon"}, {11, "Settlement"}, {12, "Latitude"}, {13, "Longitude"},
        //            {14, "Elevation"}, {15, "OutbreakID"}, {16, "ExposureLocationKnown"},
        //            {17, "ExposureLocation"}, {18, "Region"}, {19, "Rayon"}, {20, "Settlement"},
        //            {21, "Country"}, {22, "InvestigatedByOffice"}
        //    //, {23, "idfsYNRelatedToOutbreak"}
        //};
        protected Dictionary<int, string> labelDict9 = new Dictionary<int, string>
                    {{0,"idfEpiObservation" }};

        protected Dictionary<string, int> keyDict12 = new Dictionary<string, int> {
                    {"strClinicalNotes",0 }};

        protected Dictionary<int, string> labelDict12 = new Dictionary<int, string>
                    {{0,"strClinicalNotes" }};

        #endregion

        #region Protected and Public Methods
        public void OnTabChange(int index)
        {
            switch (index)
            {
                case 0:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Summary;
                    showPreviousButton = false;
                    showNextButton = true;
                    break;
                case 1:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Notification;
                    showPreviousButton = false;
                    showNextButton = true;
                    break;
                case 2:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Symptoms;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 3:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.FacilityDetails;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 4:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.AntibioticVaccineHistory;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 5:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Samples;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 6:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.Test;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 7:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.CaseInvestigation;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 8:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.RiskFactors;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 9:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.ContactList;
                    showPreviousButton = true;
                    showNextButton = true;
                    break;
                case 10:
                    HumanDiseaseReportDeduplicationService.Tab = HumanDiseaseReportDeduplicationTabEnum.FinalOutcome;
                    showPreviousButton = true;
                    showNextButton = false;
                    break;
            }

            HumanDiseaseReportDeduplicationService.TabChangeIndicator = true;
        }

        protected bool IsInTabSummary(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationSummaryConstants.Disease:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.ReportID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.LegacyID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.ReportStatus:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.PersonID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.ReportType:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.PersonName:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.DateEntered:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.EnteredBy:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.EnteredByOrganization:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.DateLastUpdated:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.CaseClassification:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.DiseaseID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.ReportStatusID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.ReportTypeID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.EnteredByPersonID:
                    return true;
                case DiseasereportDeduplicationSummaryConstants.EnteredByOrganizationID:
                    return true;
            }
            return false;
        }

        protected bool IsInTabNotification(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationNotificationConstants.CompletionPaperFormDate:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.LocalIdentifier:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.Disease:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.DateOfDisease:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.NotificationDate:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.PatientStatus:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.SentByOffice:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.SentByPerson:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.ReceivedByOffice:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.ReceivedByPerson:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.PatientCurrentLocation:
                    return true;
                //case DiseasereportDeduplicationNotificationConstants.HospitalName:
                //    return true;
                case DiseasereportDeduplicationNotificationConstants.OtherLocation:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.DiseaseID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.PatientStatusID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.SentByOfficeID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.SentByPersonID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.ReceivedByOfficeID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.ReceivedByPersonID:
                    return true;
                case DiseasereportDeduplicationNotificationConstants.PatientCurrentLocationID:
                    return true;
                    //case DiseasereportDeduplicationNotificationConstants.HospitalID:
                    //    return true;
            }
            return false;
        }

        protected bool IsInTabSymptoms(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationSymptomsConstants.InitialCaseStatus:
                    return true;
                case DiseasereportDeduplicationSymptomsConstants.OnSetDate:
                    return true;
                case DiseasereportDeduplicationSymptomsConstants.idfCSObservation:
                    return true;
                case DiseasereportDeduplicationSymptomsConstants.InitialCaseStatusID:
                    return true;
            }
            return false;
        }

        protected bool IsInTabClinicalFacilityDetails(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCare:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCare:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FirstSoughtCareDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosis:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.Hospitalization:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalizationDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.DischargeDate:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.PreviouslySoughtCareID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.FacilityFirstSoughtCareID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.NonNotifiableDiagnosisID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalizationID:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalName:
                    return true;
                case DiseasereportDeduplicationFacilityDetailsConstants.HospitalID:
                    return true;
            }
            return false;
        }

        protected bool IsInTabAntibioticHistory(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy:
                    return true;
                case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapyID:
                    return true;
                //case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase:
                //    return true;
            }
            return false;
        }

        protected bool IsInTabVaccineHistory(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministered:
                    return true;
                case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministeredID:
                    return true;
                //case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase:
                //    return true;
            }
            return false;
        }

        protected bool IsInTabClinicalNotes(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationAntibioticVaccineHistoryConstants.strClinicalNotes:
                    return true;
            }
            return false;
        }

        protected bool IsInTabSamples(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationSamplesConstants.SampleCollected:
                    return true;
                case DiseasereportDeduplicationSamplesConstants.SampleCollectedID:
                    return true;
                //case DiseasereportDeduplicationSamplesConstants.idfHumanCase:
                //    return true;
            }
            return false;
        }

        protected bool IsInTabTest(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationTestConstants.TestCollected:
                    return true;
                case DiseasereportDeduplicationTestConstants.TestCollectedID:
                    return true;
                //case DiseasereportDeduplicationTestConstants.idfHumanCase:
                //    return true;
            }
            return false;
        }

        protected bool IsInTabCaseInvestigationDetails(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOffice:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.StartDateofInvestigation:
                    return true;
                //case DiseasereportDeduplicationCaseInvestigationDetailsConstants.RelatedToOutbreak:
                //    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Outbreak:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Comments:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnown:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureDate:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationType:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Country:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Region:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Rayon:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Settlement:
                    return true;                 
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Latitude:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Longitude:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Elevation:
                    return true;
                //case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Description:
                //    return true;                
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.GroundType:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Distance:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.Direction:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.PointForeignAddress:
                    return true;           
                //case DiseasereportDeduplicationCaseInvestigationDetailsConstants.RelatedToOutbreakID:
                //    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.OutbreakID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.ExposureLocationKnownID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationTypeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.RegionID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.RayonID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.SettlementID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.CountryID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.InvestigatedByOfficeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.GroundTypeID:
                    return true;
                case DiseasereportDeduplicationCaseInvestigationDetailsConstants.LocationID:
                    return true;
            }
            return false;
        }

        protected bool IsInTabRiskFactors(string strName)
        {
            switch (strName)
            {    
                case DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation:
                    return true;               
            }
            return false;
        }

        protected bool IsInTabContacts(string strName)
        {
            switch (strName)
            {
                case DiseasereportDeduplicationContactsConstants.idfHumanCase:
                    return true;
            }
            return false;
        }

        protected bool IsInTabFinalOutcome(string strName)
        {
            switch (strName)
            {            
                case DiseasereportDeduplicationFinalOutcomeConstants.FinalCaseStatus:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.DateofClassification:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.BasisofDiagnosis:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.Outcome:
                    return true;
                //case DiseasereportDeduplicationFinalOutcomeConstants.DateofDeath:
                  //  return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.strEpidemiologistsName:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.strSummaryNotes:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.idfsFinalCaseStatus:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.idfsOutCome:
                    return true;
                case DiseasereportDeduplicationFinalOutcomeConstants.idfInvestigatedByPerson:
                    return true;
            }
            return false;
        }

        protected async Task OnRecordSelectionChangeAsync(int value)
		{
			Boolean bFirst = false;
			if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList == null)
				bFirst = true;

            UnCheckAll();
            if (bFirst == false)
                ReloadTabs();

            switch (value)
			{
				case 1:
					HumanDiseaseReportDeduplicationService.RecordSelection = 1;
					HumanDiseaseReportDeduplicationService.Record2Selection = 2;
					HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
					HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;

                    HumanDiseaseReportDeduplicationService.SurvivorSummaryList = HumanDiseaseReportDeduplicationService.SummaryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorNotificationList = HumanDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsList= HumanDiseaseReportDeduplicationService.SymptomsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList= HumanDiseaseReportDeduplicationService.FacilityDetailsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSamplesList = HumanDiseaseReportDeduplicationService.SamplesList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorTestsList = HumanDiseaseReportDeduplicationService.TestsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList0.Select(a => a.Copy()).ToList();
                    //HumanDiseaseReportDeduplicationService.SurvivorContactsList = HumanDiseaseReportDeduplicationService.ContactsList.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList0.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorfields(false);
                    SelectAllSurvivorRowsAndFlexForm(false);

                    break;
				case 2:
					HumanDiseaseReportDeduplicationService.RecordSelection = 2;
					HumanDiseaseReportDeduplicationService.Record2Selection = 1;
					HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
					HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;

                    HumanDiseaseReportDeduplicationService.SurvivorSummaryList = HumanDiseaseReportDeduplicationService.SummaryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorNotificationList = HumanDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsList = HumanDiseaseReportDeduplicationService.SymptomsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList = HumanDiseaseReportDeduplicationService.FacilityDetailsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSamplesList = HumanDiseaseReportDeduplicationService.SamplesList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorTestsList = HumanDiseaseReportDeduplicationService.TestsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList02.Select(a => a.Copy()).ToList();
                    //HumanDiseaseReportDeduplicationService.SurvivorContactsList = HumanDiseaseReportDeduplicationService.ContactsList2.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList02.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorfields(true);
                    SelectAllSurvivorRowsAndFlexForm(true);
                    break;
				default:
					break;
			}

			await InvokeAsync(StateHasChanged);
		}
		protected async Task OnRecord2SelectionChangeAsync(int value)
		{
			Boolean bFirst = false;
			if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList == null)
				bFirst = true;

            UnCheckAll();
            if (bFirst == false)
                ReloadTabs();

            switch (value)
			{
				case 1:
					HumanDiseaseReportDeduplicationService.RecordSelection = 2;
					HumanDiseaseReportDeduplicationService.Record2Selection = 1;
					HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
					HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SupersededAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SupersededVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SupersededSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SupersededTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SupersededContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;

                    HumanDiseaseReportDeduplicationService.SurvivorSummaryList = HumanDiseaseReportDeduplicationService.SummaryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorNotificationList = HumanDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsList = HumanDiseaseReportDeduplicationService.SymptomsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList = HumanDiseaseReportDeduplicationService.FacilityDetailsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSamplesList = HumanDiseaseReportDeduplicationService.SamplesList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorTestsList = HumanDiseaseReportDeduplicationService.TestsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList02.Select(a => a.Copy()).ToList();
                    //HumanDiseaseReportDeduplicationService.SurvivorContactsList = HumanDiseaseReportDeduplicationService.ContactsList2.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList02.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorfields(true);
                    SelectAllSurvivorRowsAndFlexForm(true);
                    break;
                case 2:
                    HumanDiseaseReportDeduplicationService.RecordSelection = 1;
                    HumanDiseaseReportDeduplicationService.Record2Selection = 2;
                    HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;
                    HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID;
                    HumanDiseaseReportDeduplicationService.SupersededContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.HumanDiseaseReportID2;

                    HumanDiseaseReportDeduplicationService.SurvivorSummaryList = HumanDiseaseReportDeduplicationService.SummaryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorNotificationList = HumanDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsList = HumanDiseaseReportDeduplicationService.SymptomsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFacilityDetailsList = HumanDiseaseReportDeduplicationService.FacilityDetailsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorSamplesList = HumanDiseaseReportDeduplicationService.SamplesList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorTestsList = HumanDiseaseReportDeduplicationService.TestsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorCaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList0.Select(a => a.Copy()).ToList();
                    //HumanDiseaseReportDeduplicationService.SurvivorContactsList = HumanDiseaseReportDeduplicationService.ContactsList.Select(a => a.Copy()).ToList();
                    HumanDiseaseReportDeduplicationService.SurvivorFinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList0.Select(a => a.Copy()).ToList();

                    CheckAllSurvivorfields(false);
                    SelectAllSurvivorRowsAndFlexForm(false);
                    break;
                default:
					break;
			}

			await InvokeAsync(StateHasChanged);
		}

        protected void CheckAllSurvivorfields(bool record2)
        {
            if (record2 == false)
            {
                foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Checked = false;
                }
                //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
                //{
                //    item.Checked = true;
                //    HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Checked = false;
                //}
                foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Checked = false;
                }
            }
            else
            {
                foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SummaryList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.NotificationList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.SamplesList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.TestsList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList[item.Index].Checked = false;
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList[item.Index].Checked = false;
                }
                //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList2)
                //{
                //    item.Checked = true;
                //    HumanDiseaseReportDeduplicationService.ContactsList[item.Index].Checked = false;
                //}
                foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList2)
                {
                    item.Checked = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList[item.Index].Checked = false;
                }
            }
        }

        protected void SelectAllSurvivorRowsAndFlexForm(bool record2)
        {
            if (record2 == false)
            {
                HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest;
                HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest;

                HumanDiseaseReportDeduplicationService.SurvivorAntibiotics = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.Antibiotics);
                HumanDiseaseReportDeduplicationService.SelectedAntibiotics = CopyAllInList(HumanDiseaseReportDeduplicationService.Antibiotics);
                //HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.antibioticsHistory);
                //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory);
                HumanDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.Vaccinations);
                HumanDiseaseReportDeduplicationService.SelectedVaccinations = CopyAllInList(HumanDiseaseReportDeduplicationService.Vaccinations);
                //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples);
                HumanDiseaseReportDeduplicationService.SurvivorSamples = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples);
                HumanDiseaseReportDeduplicationService.SelectedSamples = CopyAllInList(HumanDiseaseReportDeduplicationService.Samples);

                //foreach (var item in HumanDiseaseReportDeduplicationService.Samples2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorSamples.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorTests = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.Tests);
                HumanDiseaseReportDeduplicationService.SelectedTests = CopyAllInList(HumanDiseaseReportDeduplicationService.Tests);
                //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails);
                //foreach (var item in HumanDiseaseReportDeduplicationService.testsDetails2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    { 
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.contactsDetails);
                HumanDiseaseReportDeduplicationService.SurvivorContacts = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.contactsDetails);
                HumanDiseaseReportDeduplicationService.SelectedContacts = CopyAllInList(HumanDiseaseReportDeduplicationService.Contacts);
                //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
                //    }
                //}

                //Additional Fields
                HumanDiseaseReportDeduplicationService.SurvivorparentHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.parentHumanDiseaseReportID;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedParentHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedParentHumanDiseaseReportIdList;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedChildHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedChildHumanDiseaseReportIdList;
                HumanDiseaseReportDeduplicationService.SurvivoridfHuman = HumanDiseaseReportDeduplicationService.idfHuman;
                HumanDiseaseReportDeduplicationService.SurvivoridfHumanActual = HumanDiseaseReportDeduplicationService.idfHumanActual;
                HumanDiseaseReportDeduplicationService.SurvivoridfsCaseProgressStatus = HumanDiseaseReportDeduplicationService.idfsCaseProgressStatus;
                HumanDiseaseReportDeduplicationService.SurvivoridfsYNRelatedToOutbreak = HumanDiseaseReportDeduplicationService.idfsYNRelatedToOutbreak;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedHumanDiseaseReportIdList;
                HumanDiseaseReportDeduplicationService.SurvivorDiseaseReportTypeID = HumanDiseaseReportDeduplicationService.DiseaseReportTypeID;
                HumanDiseaseReportDeduplicationService.SurvivorstrHumanCaseId = HumanDiseaseReportDeduplicationService.strHumanCaseId;
                //HumanDiseaseReportDeduplicationService.SurvivordatCompletionPaperFormDate = HumanDiseaseReportDeduplicationService.datCompletionPaperFormDate;
                //HumanDiseaseReportDeduplicationService.SurvivorstrLocalIdentifier = HumanDiseaseReportDeduplicationService.strLocalIdentifier;
                HumanDiseaseReportDeduplicationService.SurvivorblnClinicalDiagBasis = HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis;
                HumanDiseaseReportDeduplicationService.SurvivorblnLabDiagBasis = HumanDiseaseReportDeduplicationService.blnLabDiagBasis;
                HumanDiseaseReportDeduplicationService.SurvivorblnEpiDiagBasis = HumanDiseaseReportDeduplicationService.blnEpiDiagBasis;
                //HumanDiseaseReportDeduplicationService.SurvivorInitialCaseStatus = HumanDiseaseReportDeduplicationService.InitialCaseStatus;
                HumanDiseaseReportDeduplicationService.SurvivorstrNote = HumanDiseaseReportDeduplicationService.strNote;
            }
            else
            {
                HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2;
                HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2;

                HumanDiseaseReportDeduplicationService.SurvivorAntibiotics = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.Antibiotics2);
                HumanDiseaseReportDeduplicationService.SelectedAntibiotics2 = CopyAllInList(HumanDiseaseReportDeduplicationService.Antibiotics2);
                //HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.antibioticsHistory2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.Vaccinations2);
                HumanDiseaseReportDeduplicationService.SelectedVaccinations2 = CopyAllInList(HumanDiseaseReportDeduplicationService.Vaccinations2);
                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples2);
                HumanDiseaseReportDeduplicationService.SurvivorSamples = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples2);
                HumanDiseaseReportDeduplicationService.SelectedSamples2 = CopyAllInList(HumanDiseaseReportDeduplicationService.Samples2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.Samples)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorSamples.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails2);
                HumanDiseaseReportDeduplicationService.SurvivorTests = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.Tests2);
                HumanDiseaseReportDeduplicationService.SelectedTests2 = CopyAllInList(HumanDiseaseReportDeduplicationService.Tests2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.Tests)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorTests.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
                //    }
                //}
                //HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.contactsDetails2);
                HumanDiseaseReportDeduplicationService.SurvivorContacts = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.Contacts2);
                HumanDiseaseReportDeduplicationService.SelectedContacts2 = CopyAllInList(HumanDiseaseReportDeduplicationService.Contacts2);

                //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
                //    }
                //}
                //Additional Fields
                HumanDiseaseReportDeduplicationService.SurvivorparentHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.parentHumanDiseaseReportID2;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedParentHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedParentHumanDiseaseReportIdList2;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedChildHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedChildHumanDiseaseReportIdList2;
                HumanDiseaseReportDeduplicationService.SurvivoridfHuman = HumanDiseaseReportDeduplicationService.idfHuman2;
                HumanDiseaseReportDeduplicationService.SurvivoridfHumanActual = HumanDiseaseReportDeduplicationService.idfHumanActual2;
                HumanDiseaseReportDeduplicationService.SurvivoridfsCaseProgressStatus = HumanDiseaseReportDeduplicationService.idfsCaseProgressStatus2;
                HumanDiseaseReportDeduplicationService.SurvivoridfsYNRelatedToOutbreak = HumanDiseaseReportDeduplicationService.idfsYNRelatedToOutbreak2;
                HumanDiseaseReportDeduplicationService.SurvivorrelatedHumanDiseaseReportIdList = HumanDiseaseReportDeduplicationService.relatedHumanDiseaseReportIdList2;
                HumanDiseaseReportDeduplicationService.SurvivorDiseaseReportTypeID = HumanDiseaseReportDeduplicationService.DiseaseReportTypeID2;
                HumanDiseaseReportDeduplicationService.SurvivorstrHumanCaseId = HumanDiseaseReportDeduplicationService.strHumanCaseId2;
                //HumanDiseaseReportDeduplicationService.SurvivordatCompletionPaperFormDate = HumanDiseaseReportDeduplicationService.datCompletionPaperFormDate2;
                //HumanDiseaseReportDeduplicationService.SurvivorstrLocalIdentifier = HumanDiseaseReportDeduplicationService.strLocalIdentifier2;
                HumanDiseaseReportDeduplicationService.SurvivorblnClinicalDiagBasis = HumanDiseaseReportDeduplicationService.blnClinicalDiagBasis2;
                HumanDiseaseReportDeduplicationService.SurvivorblnLabDiagBasis = HumanDiseaseReportDeduplicationService.blnLabDiagBasis2;
                HumanDiseaseReportDeduplicationService.SurvivorblnEpiDiagBasis = HumanDiseaseReportDeduplicationService.blnEpiDiagBasis2;
                //HumanDiseaseReportDeduplicationService.SurvivorInitialCaseStatus = HumanDiseaseReportDeduplicationService.InitialCaseStatus2;
                HumanDiseaseReportDeduplicationService.SurvivorstrNote = HumanDiseaseReportDeduplicationService.strNote2;
            }

            HumanDiseaseReportDeduplicationService.AntibioticsCount = HumanDiseaseReportDeduplicationService.Antibiotics?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.VaccinationsCount = HumanDiseaseReportDeduplicationService.Vaccinations?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SamplesCount = HumanDiseaseReportDeduplicationService.Samples?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.TestsCount = HumanDiseaseReportDeduplicationService.Tests?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.ContactsCount = HumanDiseaseReportDeduplicationService.Contacts?.Count ?? 0;

            HumanDiseaseReportDeduplicationService.AntibioticsCount2 = HumanDiseaseReportDeduplicationService.Antibiotics2?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.VaccinationsCount2 = HumanDiseaseReportDeduplicationService.Vaccinations2?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SamplesCount2 = HumanDiseaseReportDeduplicationService.Samples2?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.TestsCount2 = HumanDiseaseReportDeduplicationService.Tests2?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.ContactsCount2 = HumanDiseaseReportDeduplicationService.Contacts2?.Count ?? 0;

            HumanDiseaseReportDeduplicationService.SurvivorAntibioticsCount = HumanDiseaseReportDeduplicationService.SurvivorAntibiotics?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SurvivorVaccinationsCount = HumanDiseaseReportDeduplicationService.SurvivorVaccinations?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SurvivorSamplesCount = HumanDiseaseReportDeduplicationService.SurvivorSamples?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SurvivorTestsCount = HumanDiseaseReportDeduplicationService.SurvivorTests?.Count ?? 0;
            HumanDiseaseReportDeduplicationService.SurvivorContactsCount = HumanDiseaseReportDeduplicationService.SurvivorContacts?.Count ?? 0;
        }

        protected IList<TModel> CopyAllInList<TModel>(IList<TModel> listToCopy)
        {
            if (listToCopy != null)
            {
                IList<TModel> list = new List<TModel>();
                foreach (var row in listToCopy)
                {
                    list.Add(row);
                }

                return list;
            }
            else
                return null;
        }

        protected void UnCheckAll()
		{
			HumanDiseaseReportDeduplicationService.chkCheckAll = false;
			HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;
			HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms = false;
			HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms2 = false;
			HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails = false;
			HumanDiseaseReportDeduplicationService.chkCheckAllFacilityDetails2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllSamples = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllTest = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllTest2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation= false;
            HumanDiseaseReportDeduplicationService.chkCheckAllCaseInvestigation2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllContactList = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllContactList2 = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome = false;
            HumanDiseaseReportDeduplicationService.chkCheckAllFinalOutcome2 = false;

        }

        protected void ReloadTabs()
        {
            //if (HumanDiseaseReportDeduplicationService.RecordSelection != 0 && HumanDiseaseReportDeduplicationService.Record2Selection != 0)
            //{
            //Bind Tab Summary
            HumanDiseaseReportDeduplicationService.SummaryList = new List<Field>();
            HumanDiseaseReportDeduplicationService.SummaryList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.SummaryList = HumanDiseaseReportDeduplicationService.SummaryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SummaryList2 = HumanDiseaseReportDeduplicationService.SummaryList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                }

                //All fields in Summary except Disease, ReportStatus, and ReportType are non-editable fields
                if (item.Key != DiseasereportDeduplicationSummaryConstants.Disease
                    && item.Key != DiseasereportDeduplicationSummaryConstants.ReportStatus
                    && item.Key != DiseasereportDeduplicationSummaryConstants.ReportType)
                {
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                }
            }

            //Bind Tab Notification
            HumanDiseaseReportDeduplicationService.NotificationList = new List<Field>();
            HumanDiseaseReportDeduplicationService.NotificationList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.NotificationList = HumanDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.NotificationList2 = HumanDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                }

                //Notification Sent by Name and Notification Received by Name are non-editable fields
                if (item.Key == DiseasereportDeduplicationNotificationConstants.SentByPerson
                    || item.Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                {
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.NotificationValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.NotificationValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Symptoms
            HumanDiseaseReportDeduplicationService.SymptomsList = new List<Field>();
            HumanDiseaseReportDeduplicationService.SymptomsList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.SymptomsList = HumanDiseaseReportDeduplicationService.SymptomsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SymptomsList2 = HumanDiseaseReportDeduplicationService.SymptomsList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.SymptomsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.SymptomsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Facility Details
            HumanDiseaseReportDeduplicationService.FacilityDetailsList = new List<Field>();
            HumanDiseaseReportDeduplicationService.FacilityDetailsList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.FacilityDetailsList = HumanDiseaseReportDeduplicationService.FacilityDetailsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.FacilityDetailsList2 = HumanDiseaseReportDeduplicationService.FacilityDetailsList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.FacilityDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.FacilityDetailsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);


            //Bind Tab Antibiotic History 
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList = new List<Field>();
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList2 = HumanDiseaseReportDeduplicationService.AntibioticHistoryList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.AntibioticHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.AntibioticHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Vaccine History
            HumanDiseaseReportDeduplicationService.VaccineHistoryList = new List<Field>();
            HumanDiseaseReportDeduplicationService.VaccineHistoryList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.VaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.VaccineHistoryList2 = HumanDiseaseReportDeduplicationService.VaccineHistoryList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Disabled = true;
                }
            }

            //Bind Tab Clinical Notes
            HumanDiseaseReportDeduplicationService.ClinicalNotesList = new List<Field>();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList2 = HumanDiseaseReportDeduplicationService.ClinicalNotesList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.VaccineHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.VaccineHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Samples
            HumanDiseaseReportDeduplicationService.SamplesList = new List<Field>();
            HumanDiseaseReportDeduplicationService.SamplesList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.SamplesList = HumanDiseaseReportDeduplicationService.SamplesList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SamplesList2 = HumanDiseaseReportDeduplicationService.SamplesList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.SamplesValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.SamplesValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Test
            HumanDiseaseReportDeduplicationService.TestsList = new List<Field>();
            HumanDiseaseReportDeduplicationService.TestsList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.TestsList = HumanDiseaseReportDeduplicationService.TestsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.TestsList2 = HumanDiseaseReportDeduplicationService.TestsList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.TestsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.TestsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Case Investigation Details
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList = new List<Field>();
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2 = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Disabled = true;
                }

                //Fields after Location of Exposure is known are in a group and are non-editable fields
                if (item.Index > YNExposureLocationKnown)
                {
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Case Investigation Risk Factors
            HumanDiseaseReportDeduplicationService.RiskFactorsList = new List<Field>();
            HumanDiseaseReportDeduplicationService.RiskFactorsList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.RiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.RiskFactorsList2 = HumanDiseaseReportDeduplicationService.RiskFactorsList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.RiskFactorsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.RiskFactorsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Contact List 
            //HumanDiseaseReportDeduplicationService.ContactsList = new List<Field>();
            //HumanDiseaseReportDeduplicationService.ContactsList2 = new List<Field>();
            //HumanDiseaseReportDeduplicationService.ContactsList = HumanDiseaseReportDeduplicationService.ContactsList0.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.ContactsList2 = HumanDiseaseReportDeduplicationService.ContactsList02.Select(a => a.Copy()).ToList();

            //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
            //{
            //    if (item.Checked == true)
            //    {
            //        item.Checked = true;
            //        item.Disabled = true;
            //        HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Checked = true;
            //        HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Disabled = true;
            //    }
            //}

            //HumanDiseaseReportDeduplicationService.ContactsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.ContactsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Final Outcome  
            HumanDiseaseReportDeduplicationService.FinalOutcomeList = new List<Field>();
            HumanDiseaseReportDeduplicationService.FinalOutcomeList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.FinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.FinalOutcomeList2 = HumanDiseaseReportDeduplicationService.FinalOutcomeList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.FinalOutcomeValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.FinalOutcomeValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);

            HumanDiseaseReportDeduplicationService.SelectedAntibiotics = null;
            HumanDiseaseReportDeduplicationService.SelectedVaccinations = null;
            HumanDiseaseReportDeduplicationService.SelectedSamples = null;
            HumanDiseaseReportDeduplicationService.SelectedTests = null;
            HumanDiseaseReportDeduplicationService.SelectedContacts = null;
            HumanDiseaseReportDeduplicationService.SelectedAntibiotics2 = null;
            HumanDiseaseReportDeduplicationService.SelectedVaccinations2 = null;
            HumanDiseaseReportDeduplicationService.SelectedSamples2 = null;
            HumanDiseaseReportDeduplicationService.SelectedTests2 = null;
            HumanDiseaseReportDeduplicationService.SelectedContacts2 = null;
        }

        protected bool AllFieldValuePairsUnmatched()
        {
            try
            {
                foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
                //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
                //{
                //    if (item.Value == HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Value && item.Value != null && item.Value != "")
                //    {
                //        return false;
                //    }
                //}

                foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
                {
                    if (item.Value == HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Value && item.Value != null && item.Value != "")
                    {
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return true;
        }

        protected async Task CheckAllAsync(IList<Field> list, IList<Field> list2, bool check, bool check2, IList<Field> survivorList, string strValidTabName)
        {
            try
            {
                string value = string.Empty;
                string label = string.Empty;

                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    UnCheckAll();
                }
                else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    UnCheckAll();
                }
                else
                {
                    if (check == true)
                    {
                        check2 = false;
                        //Session(strValidTabName) = true;
                        foreach (Field item in list)
                        {
                            if (item.Checked == false)
                            {
                                item.Checked = true;
                                list2[item.Index].Checked = false;
                                value = item.Value;
                                if (survivorList != null)
                                {
                                    if (survivorList.Count > 0)
                                    {
                                        label = survivorList[item.Index].Label;

                                        if (value == null)
                                        {
                                            if (survivorList[item.Index].Value == null)
                                                survivorList[item.Index].Label = label.Replace(": ", ": " + string.Empty);
                                            else
                                                survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, "");
                                        }
                                        else if (survivorList[item.Index].Value == null)
                                        {
                                            //survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
                                            survivorList[item.Index].Label = label.Replace(": ", ": " + value);
                                        }
                                        else if (survivorList[item.Index].Value == string.Empty)
                                        {
                                            //survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
                                            survivorList[item.Index].Label = label.Replace(": ", ": " + value);
                                        }
                                        else
                                        {
                                            survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, value);
                                        }

                                        survivorList[item.Index].Value = value;
                                    }
                                }
                            }
                        }

                        foreach (Field item in list)
                        {
                            if (item.Checked == true & list2[item.Index].Checked == true)
                            {
                                item.Disabled = true;
                            }
                        }
                    }
                }

                await EableDisableMergeButtonAsync();

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected bool TabSummaryValid()
        {
            if (IsSummaryValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabNotificationValid()
        {
            if (IsNotificationValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabSymptomsValid()
        {
            if (IsSymptomsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }
        protected bool TabFacilityDetailsValid()
        {
            if (IsFacilityDetailsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabAntibioticVaccineHistoryValid()
        {
            if (IsAntibioticVaccineHistoryValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabSamplesValid()
        {
            if (IsSamplesValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabTestValid()
        {
            if (IsTestValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabCaseInvestigationDetailsValid()
        {
            if (IsCaseInvestigationDetailsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabRiskFactorsValid()
        {
            if (IsRiskFactorsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabContactsValid()
        {
            if (IsContactsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected bool TabFinalOutcomeValid()
        {
            if (IsFinalOutcomeValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            return true;
        }

        protected async Task BindTabSummaryAsync()
        {
            HumanDiseaseReportDeduplicationService.SummaryList = HumanDiseaseReportDeduplicationService.SummaryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SummaryList2 = HumanDiseaseReportDeduplicationService.SummaryList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                }

                //All fields in Summary except Disease, ReportStatus, and ReportType are non-editable fields
                if (item.Key != DiseasereportDeduplicationSummaryConstants.Disease
                    && item.Key != DiseasereportDeduplicationSummaryConstants.ReportStatus
                    && item.Key != DiseasereportDeduplicationSummaryConstants.ReportType)
                {
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Disabled = true;
                }
            }

            //HumanDiseaseReportDeduplicationService.NotificationValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.NotificationValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabSummaryValid();
        }
        protected async Task BindTabNotificationAsync()
        {
            HumanDiseaseReportDeduplicationService.NotificationList = HumanDiseaseReportDeduplicationService.NotificationList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.NotificationList2 = HumanDiseaseReportDeduplicationService.NotificationList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                }

                //Notification Sent by Name and Notification Received by Name are non-editable fields
                if (item.Key == DiseasereportDeduplicationNotificationConstants.SentByPerson
                    || item.Key == DiseasereportDeduplicationNotificationConstants.ReceivedByPerson)
                {
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.NotificationValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.NotificationValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabNotificationValid();
        }

        protected async Task BindTabSymptomsAsync()
        {
            HumanDiseaseReportDeduplicationService.SymptomsList = HumanDiseaseReportDeduplicationService.SymptomsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SymptomsList2 = HumanDiseaseReportDeduplicationService.SymptomsList02.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.InfoList = HumanDiseaseReportDeduplicationService.InfoList0;
            //HumanDiseaseReportDeduplicationService.InfoList2 = HumanDiseaseReportDeduplicationService.InfoList02;

            foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.SymptomsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.SymptomsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SymptomsList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabSymptomsValid();
        }

        protected async Task BindTabFacilityDetailsAsync()
        {
            HumanDiseaseReportDeduplicationService.FacilityDetailsList = HumanDiseaseReportDeduplicationService.FacilityDetailsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.FacilityDetailsList2 = HumanDiseaseReportDeduplicationService.FacilityDetailsList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.FacilityDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.FacilityDetailsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FacilityDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabFacilityDetailsValid();
        }

        protected async Task BindTabAntibioticVaccineHistoryAsync()
        {
            //Antibiotic History
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList = HumanDiseaseReportDeduplicationService.AntibioticHistoryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.AntibioticHistoryList2 = HumanDiseaseReportDeduplicationService.AntibioticHistoryList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.AntibioticHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.AntibioticHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Vaccine History
            HumanDiseaseReportDeduplicationService.VaccineHistoryList = HumanDiseaseReportDeduplicationService.VaccineHistoryList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.VaccineHistoryList2 = HumanDiseaseReportDeduplicationService.VaccineHistoryList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.VaccineHistoryValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.VaccineHistoryValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            //Bind Tab Clinical Notes
            HumanDiseaseReportDeduplicationService.ClinicalNotesList = new List<Field>();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList2 = new List<Field>();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList = HumanDiseaseReportDeduplicationService.ClinicalNotesList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.ClinicalNotesList2 = HumanDiseaseReportDeduplicationService.ClinicalNotesList02.Select(a => a.Copy()).ToList();

            foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Disabled = true;
                }
            }

            await EableDisableMergeButtonAsync();
            TabAntibioticVaccineHistoryValid();
        }

        protected async Task BindTabSamplesAsync()
        {
            HumanDiseaseReportDeduplicationService.SamplesList = HumanDiseaseReportDeduplicationService.SamplesList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.SamplesList2 = HumanDiseaseReportDeduplicationService.SamplesList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.SamplesValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.SamplesValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.SamplesList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabSamplesValid();
        }

        protected async Task BindTabTestsAsync()
        {
            HumanDiseaseReportDeduplicationService.TestsList = HumanDiseaseReportDeduplicationService.TestsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.TestsList2 = HumanDiseaseReportDeduplicationService.TestsList02.Select(a => a.Copy()).ToList();
            foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.TestsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.TestsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.TestsList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabTestValid();
        }

        protected async Task BindTabCaseInvestigationDetailsAsync()
        {
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2 = HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList02.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.InfoList = HumanDiseaseReportDeduplicationService.InfoList0;
            //HumanDiseaseReportDeduplicationService.InfoList2 = HumanDiseaseReportDeduplicationService.InfoList02;

            foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabCaseInvestigationDetailsValid();
        }
        protected async Task BindTabRiskFactorsAsync()
        {
            HumanDiseaseReportDeduplicationService.RiskFactorsList = HumanDiseaseReportDeduplicationService.RiskFactorsList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.RiskFactorsList2 = HumanDiseaseReportDeduplicationService.RiskFactorsList02.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.InfoList = HumanDiseaseReportDeduplicationService.InfoList0;
            //HumanDiseaseReportDeduplicationService.InfoList2 = HumanDiseaseReportDeduplicationService.InfoList02;

            foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.RiskFactorsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.RiskFactorsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.RiskFactorsList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabRiskFactorsValid();
        }

        protected async Task BindTabContactsAsync()
        {
            //HumanDiseaseReportDeduplicationService.ContactsList = HumanDiseaseReportDeduplicationService.ContactsList0.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.ContactsList2 = HumanDiseaseReportDeduplicationService.ContactsList02.Select(a => a.Copy()).ToList();
            ////HumanDiseaseReportDeduplicationService.InfoList = HumanDiseaseReportDeduplicationService.InfoList0;
            ////HumanDiseaseReportDeduplicationService.InfoList2 = HumanDiseaseReportDeduplicationService.InfoList02;

            //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
            //{
            //    if (item.Checked == true)
            //    {
            //        item.Checked = true;
            //        item.Disabled = true;
            //        HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Checked = true;
            //        HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Disabled = true;
            //    }
            //}

            //HumanDiseaseReportDeduplicationService.ContactsValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList.Where(s => s.Checked == true).Select(s => s.Index);
            //HumanDiseaseReportDeduplicationService.ContactsValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.ContactsList2.Where(s => s.Checked == true).Select(s => s.Index);

            //await EableDisableMergeButtonAsync();
            //TabContactsValid();

           
            //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
            //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
            //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
            //if (idfHumanCase == recordIdfHumanCase)
            //{
            //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails;
            //}
            //else
            //{
            //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails2;
            //}
        }

        protected async Task BindTabFinalOutcomeAsync()
        {
            HumanDiseaseReportDeduplicationService.FinalOutcomeList = HumanDiseaseReportDeduplicationService.FinalOutcomeList0.Select(a => a.Copy()).ToList();
            HumanDiseaseReportDeduplicationService.FinalOutcomeList2 = HumanDiseaseReportDeduplicationService.FinalOutcomeList02.Select(a => a.Copy()).ToList();
            //HumanDiseaseReportDeduplicationService.InfoList = HumanDiseaseReportDeduplicationService.InfoList0;
            //HumanDiseaseReportDeduplicationService.InfoList2 = HumanDiseaseReportDeduplicationService.InfoList02;

            foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
            {
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Checked = true;
                    HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Disabled = true;
                }
            }

            HumanDiseaseReportDeduplicationService.FinalOutcomeValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList.Where(s => s.Checked == true).Select(s => s.Index);
            HumanDiseaseReportDeduplicationService.FinalOutcomeValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.FinalOutcomeList2.Where(s => s.Checked == true).Select(s => s.Index);

            await EableDisableMergeButtonAsync();
            TabFinalOutcomeValid();
        }

        protected async Task EableDisableMergeButtonAsync()
        {
            if (AllTabValid() == true)
            {
                disableMergeButton = false;
                await InvokeAsync(StateHasChanged);
            }
            else
                disableMergeButton = true;

            await InvokeAsync(StateHasChanged);
        }

        

        protected bool GroupAllChecked(int index, int length, IList<Field> list)
        {
            bool AllChecked = true;

            foreach (Field item in list)
            {
                if (item.Index > index && item.Index <= index + length - 1 && item.Checked == false)
                {
                    AllChecked = false;
                    //return false;
                }
            }

            return AllChecked;
        }

        

        protected bool AllTabValid()
        {

            if (IsNotificationValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            if (IsSymptomsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            if (IsFacilityDetailsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            if (IsAntibioticVaccineHistoryValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            if (IsSamplesValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }

            if (IsTestValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }

            if (IsCaseInvestigationDetailsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }
            if (IsRiskFactorsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }

            if (IsContactsValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }

            if (IsFinalOutcomeValid() == false)
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
                return false;
            }
            else
            {
                //spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
            }         
            return true;
        }

        protected void SelectAndUnSelectIDfield(int i, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
        {
            try
            {
                string value = string.Empty;
            string label = string.Empty;

            list[i].Checked = true;
            list2[i].Checked = false;
            //value = control.Items(i).Value;
            value = list[i].Value;
            if (listSurvivor != null)
            {
                if (listSurvivor.Count > 0)
                {
                    listSurvivor[i].Checked = true;
                    label = listSurvivor[i].Label;
                    //if (value == null)
                    //{
                    //    listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
                    //}
                    //else 
                    if (listSurvivor[i].Value == null)
                    {
                        listSurvivor[i].Label = label.Replace(": ", ": " + value);
                        //listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
                    }
                    else if (listSurvivor[i].Value == value)
                    {
                        listSurvivor[i].Label = label;
                    }
                    else if (listSurvivor[i].Value == "")
                    {
                        listSurvivor[i].Label = label.Replace(": ", ": " + value);
                        //listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
                    }
                    else
                    {
                        listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
                    }
                    listSurvivor[i].Value = value;
                }
            }

                //control.Items(i).Selected = true;
                //control2.Items(i).Selected = false;

                //BindCheckBoxList(control, list)
                //BindCheckBoxList(control2, list2)
            }
            catch (Exception ex)
            {
                Log.Error(MethodBase.GetCurrentMethod().Name + LoggingConstants.ExceptionWasThrownMessage, ex);
                throw ex;
            }
        }

        protected void SelectAllAndUnSelectAll(int index, int length, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
        {
            try
            {
                string value = string.Empty;
                string label = string.Empty;

                for (int i = index; i <= index + length - 1; i++)
                {
                    list[i].Checked = true;
                    list2[i].Checked = false;
                    value = list[i].Value;
                    if (listSurvivor != null)
                    {
                        if (listSurvivor.Count > 0)
                        {
                            listSurvivor[i].Checked = true;
                            label = listSurvivor[i].Label;
                            if (value == null)
                            {
                                if (listSurvivor[i].Value == null)
                                    listSurvivor[i].Label = label.Replace(": ", ": " + string.Empty);
                                else
                                    listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");

                                //listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
                            }
                            else if (listSurvivor[i].Value == null)
                            {
                                listSurvivor[i].Label = label.Replace(": ", ": " + value);
                                //listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
                            }
                            else if (listSurvivor[i].Value == value)
                            {
                                listSurvivor[i].Label = label;
                            }
                            else if (listSurvivor[i].Value == "")
                            {
                                //listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
                                listSurvivor[i].Label = label.Replace(": ", ": " + value);
                            }
                            else
                            {
                                listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
                            }
                            listSurvivor[i].Value = value;
                        }
                    }
                }

             //   BindCheckBoxList(index, length, list);
              //  BindCheckBoxList(index, length, list2);

                for (int i = 0; i <= list.Count - 1; i++)
                {
                    if (list[i].Checked == true & list2[i].Checked == true)
                    {
                        //control.Items(i).Enabled = false;
                        //control2.Items(i).Enabled = false;
                        list[i].Disabled = true;
                        list2[i].Disabled = true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

       

        public async Task<dynamic> ShowWarningMessage(string message, string localizedMessage)
        {
            List<DialogButton> buttons = new();
            var okButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning }
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams);
        }

        protected void AddTestsToSurvivorList(IList<DiseaseReportTestDetailForDiseasesViewModel> listToAdd)
        {
            HumanDiseaseReportDeduplicationService.SurvivorTests ??= new List<DiseaseReportTestDetailForDiseasesViewModel>();
            foreach (var row in listToAdd)
            {
                var list = HumanDiseaseReportDeduplicationService.SurvivorTests
                    .Where(x => x.idfTesting == row.idfTesting).ToList();
                if (list.Count == 0)
                    HumanDiseaseReportDeduplicationService.SurvivorTests.Add(row);
            }
        }

        protected void AddTestsToSelectedList(IList<DiseaseReportTestDetailForDiseasesViewModel> listToAdd, bool record2)
        {
            foreach (var row in listToAdd)
                if (record2 == false)
                {
                    HumanDiseaseReportDeduplicationService.SelectedTests ??=
                        new List<DiseaseReportTestDetailForDiseasesViewModel>();
                    var list = HumanDiseaseReportDeduplicationService.SelectedTests
                        .Where(x => x.idfTesting == row.idfTesting).ToList();
                    if (list.Count == 0)
                        HumanDiseaseReportDeduplicationService.SelectedTests.Add(row);
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SelectedTests2 ??=
                        new List<DiseaseReportTestDetailForDiseasesViewModel>();
                    var list = HumanDiseaseReportDeduplicationService.SelectedTests2
                        .Where(x => x.idfTesting == row.idfTesting).ToList();
                    if (list.Count == 0)
                        HumanDiseaseReportDeduplicationService.SelectedTests2.Add(row);
                }
        }

        protected IList<TModel> RemoveListFromList<TModel>(IList<TModel> list, IList<TModel> listToRemove)
        {
            if (list == null) return null;
            foreach (var row in listToRemove) list.Remove(row);

            return list;
        }
        #endregion
        #region Private Methods

        private bool IsSummaryValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.SummaryList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.SummaryList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }
        private bool IsNotificationValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.NotificationList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.NotificationList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }
        private bool IsSymptomsValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.SymptomsList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.SymptomsList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsFacilityDetailsValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.FacilityDetailsList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.FacilityDetailsList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsAntibioticVaccineHistoryValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.AntibioticHistoryList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            foreach (Field item in HumanDiseaseReportDeduplicationService.VaccineHistoryList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.VaccineHistoryList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            foreach (Field item in HumanDiseaseReportDeduplicationService.ClinicalNotesList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.ClinicalNotesList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsSamplesValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.SamplesList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.SamplesList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsTestValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.TestsList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.TestsList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsCaseInvestigationDetailsValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.CaseInvestigationDetailsList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }
        private bool IsRiskFactorsValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.RiskFactorsList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.RiskFactorsList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }

        private bool IsContactsValid()
        {
            //foreach (Field item in HumanDiseaseReportDeduplicationService.ContactsList)
            //{
            //    if (item.Checked == false & HumanDiseaseReportDeduplicationService.ContactsList2[item.Index].Checked == false)
            //    {
            //        return false;
            //    }
            //}
            return true;
        }

        private bool IsFinalOutcomeValid()
        {
            foreach (Field item in HumanDiseaseReportDeduplicationService.FinalOutcomeList)
            {
                if (item.Checked == false & HumanDiseaseReportDeduplicationService.FinalOutcomeList2[item.Index].Checked == false)
                {
                    return false;
                }
            }
            return true;
        }


        #endregion
    }
}
#endregion