using System;
using System.Collections.Generic;

#nullable disable

namespace EIDSS.Repository.ReturnModels
{
    public partial class TDocumentGroupMapping
    {
        public int DocumentId { get; set; }
        public int DocumentGroupId { get; set; }
        public decimal SortOrder { get; set; }
    }
}
