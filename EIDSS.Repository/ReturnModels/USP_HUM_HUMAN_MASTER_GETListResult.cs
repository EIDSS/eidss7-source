﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_HUM_HUMAN_MASTER_GETListResult
    {
        public int? TotalRowCount { get; set; }
        public long HumanMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? AddressID { get; set; }
        public string FirstOrGivenName { get; set; }
        public string SecondName { get; set; }
        public string LastOrSurname { get; set; }
        public string FullName { get; set; }
        public string DateOfBirth { get; set; }
        public string PersonalID { get; set; }
        public string PersonIDTypeName { get; set; }
        public string StreetName { get; set; }
        public string AddressString { get; set; }
        public string LongitudeLatitude { get; set; }
        public int? ContactPhoneCountryCode { get; set; }
        public string ContactPhoneNumber { get; set; }
        public long? ContactPhoneNbrTypeID { get; set; }
        public int? Age { get; set; }
        public string PassportNumber { get; set; }
        public long? CitizenshipTypeID { get; set; }
        public string CitizenshipTypeName { get; set; }
        public long? GenderTypeID { get; set; }
        public string GenderTypeName { get; set; }
        public long? CountryID { get; set; }
        public string CountryName { get; set; }
        public long? RegionID { get; set; }
        public string RegionName { get; set; }
        public long? RayonID { get; set; }
        public string RayonName { get; set; }
        public long? SettlementID { get; set; }
        public string SettlementName { get; set; }
        public string FormattedAddressString { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
