﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_FF_Parameters_GETResult
    {
        public long idfsParameter { get; set; }
        public long? idfsSection { get; set; }
        public long idfsFormType { get; set; }
        public long? idfsParameterType { get; set; }
        public string ParameterTypeName { get; set; }
        public long? idfsEditor { get; set; }
        public long? idfsParameterCaption { get; set; }
        public int intOrder { get; set; }
        public string strNote { get; set; }
        public int intHACode { get; set; }
        public int intRowStatus { get; set; }
        public string DefaultName { get; set; }
        public string DefaultLongName { get; set; }
        public string NationalName { get; set; }
        public string NationalLongName { get; set; }
        public string langid { get; set; }
        public int IsRealParameter { get; set; }
    }
}
