﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VET_DISEASE_REPORT_GETListResult
    {
        public long ReportKey { get; set; }
        public string ReportID { get; set; }
        public long? OutbreakKey { get; set; }
        public string OutbreakID { get; set; }
        public long ReportCategoryTypeID { get; set; }
        public string ReportStatusTypeName { get; set; }
        public string ReportTypeName { get; set; }
        public string SpeciesTypeName { get; set; }
        public string ClassificationTypeName { get; set; }
        public DateTime? ReportDate { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? FinalDiagnosisDate { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public string ReportedByPersonName { get; set; }
        public int TotalSickAnimalQuantity { get; set; }
        public int TotalAnimalQuantity { get; set; }
        public int TotalDeadAnimalQuantity { get; set; }
        public string SpeciesList { get; set; }
        public string FarmID { get; set; }
        public long? FarmMasterKey { get; set; }
        public string FarmName { get; set; }
        public long? FarmOwnerKey { get; set; }
        public string FarmOwnerID { get; set; }
        public string FarmOwnerName { get; set; }
        public string FarmLocation { get; set; }
        public string FarmAddress { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string EnteredByPersonName { get; set; }
        public long SiteKey { get; set; }
        public long idfFarm { get; set; }
        public bool? ReadPermissionindicator { get; set; }
        public bool? AccessToPersonalDataPermissionIndicator { get; set; }
        public bool? AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool? WritePermissionIndicator { get; set; }
        public bool? DeletePermissionIndicator { get; set; }
        public int? TotalRowCount { get; set; }
        public int? TotalCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
