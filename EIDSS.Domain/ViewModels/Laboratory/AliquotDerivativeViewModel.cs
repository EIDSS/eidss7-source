using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class AliquotDerivativeViewModel
    {
        public string LabSampleID { get; set; }
        public string SampleType { get; set; }
        public int NewSampleCount { get; set; }
        public long? SelectedDerivativeID { get; set; }
        public int FormationType { get; set; }
    }
}
