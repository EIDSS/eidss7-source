using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.CodeGenerator
{

    internal class AuditingDirectiveCollection
    {
        public List<AuditingDirective> AuditingDirectives { get; set; }
    }

    internal class AuditingDirective
    {
        public long idfTable { get; set; }
        public string TableName { get; set; }   
        public string TableDescription { get; set; }
        public List<AuditColumn> AssociatedColumns { get; set; }
        
    }

    internal class AuditColumn
    {
        public long idfColumn { get; set; } 
        public string ColumnName { get; set; }
        public string ColumnDescription { get; set; }
    }
}

