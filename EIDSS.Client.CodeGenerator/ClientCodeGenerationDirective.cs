using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Client.CodeGenerator
{
    public class ClientCodeGenerationDirective
    {
        public string Classname { get; set; }
        public List<MethodDirectiveModel> MethodDirectives { get; set; } = new List<MethodDirectiveModel>();

    }

    public class MethodDirectiveModel
    {
        public string CallType { get; set; }
        public string Name { get; set; }
        public string Parameters { get; set; }
        public string ReturnType { get; set; }
        public string SummaryInfo { get; set; }
        public string URL { get; set; }
       
    }

    public class ClientCodeGenerationDirectiveContainer
    {
        public List<ClientCodeGenerationDirective> ClientDirectives { get; set; }
    }

}
