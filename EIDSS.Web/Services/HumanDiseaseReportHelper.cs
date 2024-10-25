using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{
    public class HumanDiseaseReportHelper
    {
        public string Name { get; set; }
        
        public HumanDiseaseReportHelper(string name)
        {
            Name = name;
        }
        public HumanDiseaseReportHelper()
        {
            
        }

        [JSInvokable]
        public string SayHello() => $"Hello, {Name}!";
    }
}
