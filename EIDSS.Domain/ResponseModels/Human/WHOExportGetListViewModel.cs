﻿using System;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class WHOExportGetListViewModel
    {
        public long idfCase { get; set; }
        public string strReportID { get; set; }
        public string strCaseID { get; set; }
        public string strAreaID { get; set; }
        public DateTime? datDRash { get; set; }
        public int intGenderID { get; set; }
        public DateTime? datDBirth { get; set; }
        public int? intAgeAtRashOnset { get; set; }
        public int? intNumOfVaccines { get; set; }
        public DateTime? datDvaccine { get; set; }
        public DateTime? datDNotification { get; set; }
        public DateTime? datDInvestigation { get; set; }
        public int? intClinFever { get; set; }
        public int? intClinCCC { get; set; }
        public int? intClinRashDuration { get; set; }
        public int? intClinOutcome { get; set; }
        public int? intClinHospitalization { get; set; }
        public int? intSrcInf { get; set; }
        public int? intSrcOutbreakRelated { get; set; }
        public string strSrcOutbreakID { get; set; }
        public int? intCompComplications { get; set; }
        public int? intCompEncephalitis { get; set; }
        public int? intCompPneumonia { get; set; }
        public int? intCompMalnutrition { get; set; }
        public int? intCompDiarrhoea { get; set; }
        public int? intCompOther { get; set; }
        public int? intFinalClassification { get; set; }
        public DateTime? datDSpecimen { get; set; }
        public string strSpecimen { get; set; }
        public DateTime? datDLabResult { get; set; }
        public int? intMeaslesIgm { get; set; }
        public int? intMeaslesVirusDetection { get; set; }
        public int? intRubellaIgm { get; set; }
        public int? intRubellaVirusDetection { get; set; }
        public string strComments { get; set; }
        public string strImportationCountry { get; set; }
        public int? intInitialDiagnosis { get; set; }
    }
}