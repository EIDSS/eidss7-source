﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_FF_Rule_GetDetailsResult
    {
        public long idfsRule { get; set; }
        public string defaultRuleName { get; set; }
        public string RuleName { get; set; }
        public long? idfsRuleMessage { get; set; }
        public string defaultRuleMessage { get; set; }
        public string RuleMessage { get; set; }
        public long? idfsCheckPoint { get; set; }
        public long idfsRuleFunction { get; set; }
        public bool blnNot { get; set; }
        public long? idfsRuleAction { get; set; }
        public string strActionParameters { get; set; }
        public long? idfsFunctionParameter { get; set; }
        public string FillValue { get; set; }
    }
}
