using System;
using System.Collections.Generic;

#nullable disable

namespace EIDSS.Repository.ReturnModels
{
    public partial class TDocumentGroup
    {
        public int DocumentGroupId { get; set; }
        public string DocumentGroupName { get; set; }
        public int SortOrder { get; set; }
    }
}
