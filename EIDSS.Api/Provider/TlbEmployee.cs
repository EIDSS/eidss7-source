using EIDSS.Api.Providers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{
    public class TlbEmployee
    {
		[Key]
        public long idfEmployee { get; set; }
        public long idfsEmployeeType { get; set; }
        public long idfsSite { get; set; }
        public int intRowStatus { get; set; }
        public Guid rowguid { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
        public long? SourceSystemNameID { get; set; }
		public string SourceSystemKeyValue { get; set; }
		public string AuditCreateUser { get; set; }
		public DateTime AuditCreateDTM { get; set; }
		public string AuditUpdateUser { get; set; }
		public DateTime AuditUpdateDTM { get; set; }
		public long idfsEmployeeCategory { get; set; }

       



    }

}

