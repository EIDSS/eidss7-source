﻿using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class DiseaseReportPersonalInformationViewModel
    {
        	
        public long? HumanActualId { get; set; }	
        public long HumanId { get; set; }
        public string PatientFarmOwnerName { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? OccupationTypeID { get; set; }
        public long? CitizenshipTypeID { get; set; }
        public string CitizenshipTypeName { get; set; }
        public long? GenderTypeID { get; set; }
        public string GenderTypeName { get; set; }
        public long? HumanGeoLocationID { get; set; }
        public long? HumanidfsCountry { get; set; }
        public string HumanCountry { get; set; }
        public long? HumanidfsRegion { get; set; }
        public string HumanRegion { get; set; }
        public long? HumanidfsRayon { get; set; }
        public string HumanRayon { get; set; }
        public long? HumanidfsSettlement { get; set; }
        public string HumanSettlement { get; set; }
        public long? HumanidfsSettlementType { get; set; }
        public string HumanSettlementType { get; set; }
        public string HumanstrPostalCode { get; set; }
        public string HumanstrStreetName { get; set; }
        public string HumanstrHouse { get; set; }
        public string HumanstrBuilding { get; set; }
        public string HumanstrApartment { get; set; }
        public string HumanDescription { get; set; }
        public double? HumanstrLatitude { get; set; }
        public double? HumanstrLongitude { get; set; }
        public bool? HumanForeignAddressIndicator { get; set; }
        public string HumanForeignAddressString { get; set; }
        public long? EmployerGeoLocationID { get; set; }
        public long? EmployeridfsCountry { get; set; }
        public string EmployerCountry { get; set; }
        public long? EmployeridfsRegion { get; set; }
        public string EmployerRegion { get; set; }
        public long? EmployeridfsRayon { get; set; }
        public string EmployerRayon { get; set; }
        public long? EmployeridfsSettlement { get; set; }
        public string EmployerSettlement { get; set; }
        public long? EmployeridfsSettlementType { get; set; }
        public string EmployerSettlementType { get; set; }
        public string EmployerstrPostalCode { get; set; }
        public string EmployerstrStreetName { get; set; }
        public string EmployerstrHouse { get; set; }
        public string EmployerstrBuilding { get; set; }
        public string EmployerstrApartment { get; set; }
        public string EmployerDescription { get; set; }
        public double? EmployerstrLatitude { get; set; }
        public double? EmployerstrLongitude { get; set; }
        public bool? EmployerForeignAddressIndicator { get; set; }
        public string EmployerForeignAddressString { get; set; }
        public long? HumanPermGeoLocationID { get; set; }
        public long? HumanPermidfsCountry { get; set; }
        public string HumanPermCountry { get; set; }
        public long? HumanPermidfsRegion { get; set; }
        public string HumanPermRegion { get; set; }
        public long? HumanPermidfsRayon { get; set; }
        public string HumanPermRayon { get; set; }
        public long? HumanPermidfsSettlement { get; set; }
        public string HumanPermSettlement { get; set; }
        public long? HumanPermidfsSettlementType { get; set; }
        public string HumanPermSettlementType { get; set; }
        public string HumanPermstrPostalCode { get; set; }
        public string HumanPermstrStreetName { get; set; }
        public string HumanPermstrHouse { get; set; }
        public string HumanPermstrBuilding { get; set; }
        public string HumanPermstrApartment { get; set; }
        public string HumanPermDescription { get; set; }
        public long? HumanAltGeoLocationID { get; set; }
        public long? HumanAltidfsCountry { get; set; }
        public string HumanAltCountry { get; set; }
        public long? HumanAltidfsRegion { get; set; }
        public string HumanAltRegion { get; set; }
        public long? HumanAltidfsRayon { get; set; }
        public string HumanAltRayon { get; set; }
        public long? HumanAltidfsSettlement { get; set; }
        public string HumanAltSettlement { get; set; }
        public long? HumanAltidfsSettlementType { get; set; }
        public string HumanAltSettlementType { get; set; }
        public string HumanAltstrPostalCode { get; set; }
        public string HumanAltstrStreetName { get; set; }
        public string HumanAltstrHouse { get; set; }
        public string HumanAltstrBuilding { get; set; }
        public string HumanAltstrApartment { get; set; }
        public string HumanAltDescription { get; set; }
        public double? HumanAltstrLatitude { get; set; }
        public double? HumanAltstrLongitude { get; set; }
        public bool? HumanAltForeignAddressIndicator { get; set; }
        public string HumanAltForeignAddressString { get; set; }
        public long? SchoolGeoLocationID { get; set; }
        public long? SchoolidfsCountry { get; set; }
        public long? SchoolidfsRegion { get; set; }
        public long? SchoolidfsRayon { get; set; }
        public long? SchoolidfsSettlement { get; set; }
        public long? SchoolAltidfsSettlementType { get; set; }
        public string SchoolAltSettlementType { get; set; }
        public string SchoolstrPostalCode { get; set; }
        public string SchoolstrStreetName { get; set; }
        public string SchoolstrHouse { get; set; }
        public string SchoolstrBuilding { get; set; }
        public string SchoolstrApartment { get; set; }
        public bool? SchoolForeignAddressIndicator { get; set; }
        public string SchoolForeignAddressString { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        public string DateOfBirth { get; set; }
        public string DateOfDeath { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? EnteredDate { get; set; }
        public string ModificationDate { get; set; }
        public string FirstOrGivenName { get; set; }
        public string SecondName { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PersonInformationLastNameFieldLabel))]
        public string LastOrSurname { get; set; }
        public string EmployerName { get; set; }
        public string HomePhone { get; set; }
        public string WorkPhone { get; set; }
        public long? PersonalIDType { get; set; }
        public string PersonalID { get; set; }
        public int? ReportedAge { get; set; }
        public long? ReportedAgeUOMID { get; set; }
        public string PassportNumber { get; set; }
        public long? IsEmployedTypeID { get; set; }
        public string IsEmployedTypeName { get; set; }
        public string EmployerPhone { get; set; }
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:MM/dd/yyyy}")]
        public DateTime? EmployedDateLastPresent { get; set; }
        public long? IsStudentTypeID { get; set; }
        public string IsStudentTypeName { get; set; }
        public string SchoolName { get; set; }
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:MM/dd/yyyy}")]
        public DateTime? SchoolDateLastAttended { get; set; }
        public string SchoolPhone { get; set; }
        public int? ContactPhoneCountryCode { get; set; }
        public string ContactPhone { get; set; }
        public long? ContactPhoneTypeID { get; set; }
        public string ContactPhoneTypeName { get; set; }
        public int? ContactPhone2CountryCode { get; set; }
        public string ContactPhone2 { get; set; }
        public long? ContactPhone2TypeID { get; set; }
        public string ContactPhone2TypeName { get; set; }
        public string PersonalIDTypeName { get; set; }
        public string OccupationTypeName { get; set; }
        public string SchoolCountry { get; set; }
        public string SchoolRegion { get; set; }
        public string SchoolRayon { get; set; }
        public string SchoolSettlement { get; set; }
        public string IsAnotherPhone { get; set; }
        public string Age { get; set; }
        public string YNAnotherAddress { get; set; }
        public string YNHumanForeignAddress { get; set; }
        public string YNEmployerForeignAddress { get; set; }
        public string YNHumanAltForeignAddress { get; set; }
        public string YNSchoolForeignAddress { get; set; }
        public string YNWorkSameAddress { get; set; }
        public string YNPermanentSameAddress { get; set; }
        //Custom
        public Dictionary<string, string> IsAnotherAddressList { get; set; }

        public Dictionary<string, string> IsAnotherPhoneList { get; set; }

        public Dictionary<string, string> IsThisPersonCurrentlyEmployed { get; set; }

        public Dictionary<string, string> IsThisPersonCurrentlyAttendSchool { get; set; }


    }
}