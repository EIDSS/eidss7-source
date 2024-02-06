using System;
using System.Collections.Generic;

#nullable disable

namespace EIDSS.Repository.ReturnModels
{
    public partial class TDocumentContainerMapping
    {
        public int DocumentId { get; set; }
        public int ContainerId { get; set; }
        public decimal SortOrder { get; set; }
    }
}
