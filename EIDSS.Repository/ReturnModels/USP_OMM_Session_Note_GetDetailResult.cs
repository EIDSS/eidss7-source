﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_OMM_Session_Note_GetDetailResult
    {
        public long idfOutbreakNote { get; set; }
        public long NoteRecordUID { get; set; }
        public long idfOutbreak { get; set; }
        public string strNote { get; set; }
        public DateTime? datNoteDate { get; set; }
        public long idfPerson { get; set; }
        public string UserName { get; set; }
        public string Organization { get; set; }
        public int intRowStatus { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
        public long? UpdatePriorityID { get; set; }
        public string strPriority { get; set; }
        public string UpdateRecordTitle { get; set; }
        public string UploadFileName { get; set; }
        public string UploadFileDescription { get; set; }
        public byte[] UploadFileObject { get; set; }
    }
}