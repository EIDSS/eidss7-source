﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_FF_Template_GetDetailResult
    {
        public long idfsFormTemplate { get; set; }
        public string FormTemplate { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public long? idfsFormType { get; set; }
        public string strNote { get; set; }
        public bool blnUNI { get; set; }
    }
}
