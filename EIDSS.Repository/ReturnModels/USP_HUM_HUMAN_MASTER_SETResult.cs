﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_HUM_HUMAN_MASTER_SETResult
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? HumanMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? HumanID { get; set; }
    }
}