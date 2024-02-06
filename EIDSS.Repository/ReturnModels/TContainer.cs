using System;
using System.Collections.Generic;

#nullable disable

namespace EIDSS.Repository.ReturnModels
{
    public partial class TContainer
    {
        public int ContainerId { get; set; }
        public string ContainerName { get; set; }
        public int? ContainerTypeId { get; set; }
        public decimal? SortOrder { get; set; }
        public string PreHtml { get; set; }
        public string PostHtml { get; set; }
        public string SideHtml { get; set; }
        public int? ReelId { get; set; }
        public int? LayoutId { get; set; }
        public DateTime DateCreated { get; set; }
        public int CreatedBy { get; set; }
        public DateTime? DateModified { get; set; }
        public int? ModifiedBy { get; set; }
        public bool IsPublished { get; set; }
        public DateTime? PublishDate { get; set; }
        public DateTime? ExpirationDate { get; set; }
        public int? ParentId { get; set; }
        public string Url { get; set; }
        public int? TargetContainerId { get; set; }
        public bool OpenTargetInNewWindow { get; set; }
        public string DocColumn1Header { get; set; }
        public string DocColumn2Header { get; set; }
        public bool? ShowVideoColumn { get; set; }
    }
}
