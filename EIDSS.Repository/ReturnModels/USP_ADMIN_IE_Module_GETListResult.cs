﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_IE_Module_GETListResult
    {
        public string DefaultName { get; set; }
        public long idfResourceHierarchy { get; set; }
        public long idfsResourceSet { get; set; }
        public string ResourceSetNode { get; set; }
        public short? Level { get; set; }
        public string TranslatedName { get; set; }
    }
}