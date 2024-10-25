using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class DiseasePensideTestMatrixViewModel
    {
        public long IdfPensideTestForDisease { get; set; }
        public long IdfsPensideTestName { get; set; }
        public string StrPensideTestName { get; set; }
        public long IdfsDiagnosis { get; set; }
        public string StrDisease { get; set; }
    }
}
