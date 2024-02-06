using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class VectorTypeListViewModel : BaseModel
    {
        public long VectorTypeId { get; init; } 
        public string Default { get; set; } 
        public string Name { get; set; } 
        public string Code { get; set; }
        public bool CollectionByPool { get; set; }
        public int? Order { get; set; }
        public int RowStatus { get; set; }
    }
}
