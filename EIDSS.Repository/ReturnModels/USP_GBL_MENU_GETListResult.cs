﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_MENU_GETListResult
    {
        public long idfsBaseReference { get; set; }
        public string MenuName { get; set; }
        public long idfsReferenceType { get; set; }
        public long EIDSSMenuId { get; set; }
        public long EIDSSParentMenuId { get; set; }
        public string PageName { get; set; }
        public long? PageTitleID { get; set; }
        public string PageLink { get; set; }
        public string ExceptionControlList { get; set; }
        public int? DisplayOrder { get; set; }
        public string IsOpenInNewWindow { get; set; }
        public string AppModuleGroupList { get; set; }
        public string Controller { get; set; }
        public string strAction { get; set; }
        public string Area { get; set; }
        public string SubArea { get; set; }
    }
}
