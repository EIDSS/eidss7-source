﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_GIS_Location_ChildLevel_GetResult
    {
        public short? Level { get; set; }
        public long idfsGISReferenceType { get; set; }
        public string strGISReferenceTypeName { get; set; }
        public long idfsReference { get; set; }
        public string Name { get; set; }
        public string strNode { get; set; }
        public string strHASC { get; set; }
        public string strCode { get; set; }
        public long? LevelType { get; set; }
    }
}
