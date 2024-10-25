using EIDSS.Api.Provider;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Providers
{
	public class TlbPerson
	{
		[Key]
		public long idfPerson { get; set; }
		public long idfsStaffPosition { get; set; }	
		public long idfInstitution { get; set; }
		public long idfDepartment { get; set; }
		public string strFamilyName { get; set; }
		public string strFirstName { get; set; }
		public string strSecondName { get; set; }
		public string strContactPhone { get; set; }
		public string strBarcode { get; set; }
		public Guid rowguid { get; set; }
		public int intRowStatus { get; set; }
		public string strMaintenanceFlag { get; set; }
		public string strReservedAttribute { get; set; }
		public string PersonalIDValue { get; set; }
		public long? PersonalIDTypeID { get; set; }
		public string SourceSystemKeyValue { get; set; }
		public string AuditCreateUser { get; set; }
		public DateTime AuditCreateDTM { get; set; }
		public DateTime AuditUpdateUser { get; set; }
		public DateTime AuditUpdateDTM { get; set; }

		[ForeignKey("idfPerson")]
		public virtual TlbEmployee TlbEmployee { get; set; }
	}
}
