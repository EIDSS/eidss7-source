﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_ReportForm_GetListResult
    {
        public int? TotalRowCount { get; set; }
        public long ReportFormId { get; set; }
        public long ReportFormTypeID { get; set; }
        public long AdministrativeUnitID { get; set; }
        public long SentByOrganizationID { get; set; }
        public string SentByOrganizationName { get; set; }
        public long SentByPersonID { get; set; }
        public string SentByPersonName { get; set; }
        public long EnteredByOrganizationID { get; set; }
        public string EnteredByOrganizationName { get; set; }
        public long EnteredByPersonID { get; set; }
        public string EnteredByPersonName { get; set; }
        public string SentByDate { get; set; }
        public DateTime? DisplaySentByDate { get; set; }
        public string EnteredByDate { get; set; }
        public DateTime? DisplayEnteredByDate { get; set; }
        public string StartDate { get; set; }
        public DateTime? DisplayStartDate { get; set; }
        public string FinishDate { get; set; }
        public DateTime? DisplayFinishDate { get; set; }
        public string EIDSSReportID { get; set; }
        public int? AdministrativeUnitTypeID { get; set; }
        public string AdministrativeUnitTypeName { get; set; }
        public long idfsDiagnosis { get; set; }
        public string diseaseDefaultName { get; set; }
        public string diseaseName { get; set; }
        public string Total { get; set; }
        public int? Notified { get; set; }
        public string Comments { get; set; }
        public long AdminLevel0 { get; set; }
        public string AdminLevel0Name { get; set; }
        public long? AdminLevel1 { get; set; }
        public string AdminLevel1Name { get; set; }
        public long? AdminLevel2 { get; set; }
        public string AdminLevel2Name { get; set; }
        public long? idfsSettlement { get; set; }
        public string SettlementName { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}