﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_FF_Parameter_GETResult
    {
        public long? idfsEditor { get; set; }
        public string Editor { get; set; }
        public long? idfsParameterType { get; set; }
        public string ParameterTypeName { get; set; }
        public string DefaultName { get; set; }
        public string DefaultLongName { get; set; }
        public string NationalName { get; set; }
        public string NationalLongName { get; set; }
        public int? ParameterUsed { get; set; }
    }
}