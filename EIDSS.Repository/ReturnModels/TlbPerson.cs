﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace EIDSS.Repository.ReturnModels
{
    /// <summary>
    /// Staff Persons (Officers)
    /// </summary>
    public partial class TlbPerson
    {
        public TlbPerson()
        {
            TstUserTable = new HashSet<TstUserTable>();
        }

        /// <summary>
        /// Officer identifier
        /// </summary>
        public long IdfPerson { get; set; }
        /// <summary>
        /// Staff position identifier
        /// </summary>
        public long? IdfsStaffPosition { get; set; }
        /// <summary>
        /// Institution identifier
        /// </summary>
        public long? IdfInstitution { get; set; }
        /// <summary>
        /// Department identifier
        /// </summary>
        public long? IdfDepartment { get; set; }
        /// <summary>
        /// Officer Last name
        /// </summary>
        public string StrFamilyName { get; set; }
        /// <summary>
        /// Officer First name
        /// </summary>
        public string StrFirstName { get; set; }
        /// <summary>
        /// Officer Middle name
        /// </summary>
        public string StrSecondName { get; set; }
        /// <summary>
        /// Officer contact phone number
        /// </summary>
        public string StrContactPhone { get; set; }
        /// <summary>
        /// Barcode (alphanumeric badge code)
        /// </summary>
        public string StrBarcode { get; set; }
        public Guid Rowguid { get; set; }
        public int IntRowStatus { get; set; }
        public string StrMaintenanceFlag { get; set; }
        public string StrReservedAttribute { get; set; }
        public string PersonalIdvalue { get; set; }
        public long? PersonalIdtypeId { get; set; }
        public long? SourceSystemNameId { get; set; }
        public string SourceSystemKeyValue { get; set; }
        public string AuditCreateUser { get; set; }
        public DateTime? AuditCreateDtm { get; set; }
        public string AuditUpdateUser { get; set; }
        public DateTime? AuditUpdateDtm { get; set; }

        public virtual TlbOffice IdfInstitutionNavigation { get; set; }
        public virtual TlbEmployee IdfPersonNavigation { get; set; }
        public virtual TrtBaseReference IdfsStaffPositionNavigation { get; set; }
        public virtual TrtBaseReference PersonalIdtype { get; set; }
        public virtual TrtBaseReference SourceSystemName { get; set; }
        public virtual ICollection<TstUserTable> TstUserTable { get; set; }
    }
}