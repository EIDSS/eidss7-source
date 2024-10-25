using System;
using System.Collections.Generic;

#nullable disable

namespace EIDSS.Repository.ReturnModels
{
    public partial class TDocument
    {
        public int DocumentId { get; set; }
        public string DocumentName { get; set; }
        public string FileName { get; set; }
        public string Url { get; set; }
        public string ShowMePath { get; set; }
        public DateTime CreatedDate { get; set; }
        public int CreatedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public int? LastModifiedBy { get; set; }
        public bool IsPublished { get; set; }
        public string TextOfDocument { get; set; }
        public string Swfsize { get; set; }
        public DateTime? PublishDate { get; set; }
        public DateTime? ExpirationDate { get; set; }
        public DateTime? DeliveryDate { get; set; }
        public decimal? SortOrder { get; set; }
        public int? CourseId { get; set; }
        public Guid? Guid { get; set; }
    }
}
