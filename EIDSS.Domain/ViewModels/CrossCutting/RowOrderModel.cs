using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class RowOrderModel
    {
        public long KeyId { get; set; }
        public int NewData { get; set; }
        public int OldData { get; set; }
    }
}
