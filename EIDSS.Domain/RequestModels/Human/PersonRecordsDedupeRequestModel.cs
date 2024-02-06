using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class PersonRecordsDedupeRequestModel
    {
        public long HumanMasterID { get; set; }
        public long SupersededHumanMasterID { get; set; }
        public bool? CopyToHumanIndicator { get; set; }
        public long? PersonalIDType { get; set; }
        public string EIDSSPersonID { get; set; }
        public string PersonalID { get; set; }
        public string FirstName { get; set; }
        public string SecondName { get; set; }
        public string LastName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public DateTime? DateOfDeath { get; set; }
        public int? ReportedAge { get; set; }
        public long? ReportAgeUOMID { get; set; }
        public long? HumanGenderTypeID { get; set; }
        public long? OccupationTypeID { get; set; }
        public long? CitizenshipTypeID { get; set; }
        public string PassportNumber { get; set; }
        public long? IsEmployedTypeID { get; set; }
        public string EmployerName { get; set; }
        public DateTime? EmployedDateLastPresent { get; set; }
        public bool? EmployerForeignAddressIndicator { get; set; }
        public string EmployerForeignAddressString { get; set; }
        public long? EmployerGeoLocationID { get; set; }
        public long? EmployeridfsLocation { get; set; }
        public string EmployerstrStreetName { get; set; }
        public string EmployerstrApartment { get; set; }
        public string EmployerstrBuilding { get; set; }
        public string EmployerstrHouse { get; set; }
        public string EmployeridfsPostalCode { get; set; }
        public string EmployerPhone { get; set; }
        public long? IsStudentTypeID { get; set; }
        public string SchoolName { get; set; }
        public DateTime? SchoolDateLastAttended { get; set; }
        public bool? SchoolForeignAddressIndicator { get; set; }
        public string SchoolForeignAddressString { get; set; }
        public long? SchoolGeoLocationID { get; set; }
        public long? SchoolidfsLocation { get; set; }
        public string SchoolstrStreetName { get; set; }
        public string SchoolstrApartment { get; set; }
        public string SchoolstrBuilding { get; set; }
        public string SchoolstrHouse { get; set; }
        public string SchoolidfsPostalCode { get; set; }
        public string SchoolPhone { get; set; }
        public long? HumanGeoLocationID { get; set; }
        public long? HumanidfsLocation { get; set; }
        public string HumanstrStreetName { get; set; }
        public string HumanstrApartment { get; set; }
        public string HumanstrBuilding { get; set; }
        public string HumanstrHouse { get; set; }
        public string HumanidfsPostalCode { get; set; }
        public double? HumanstrLatitude { get; set; }
        public double? HumanstrLongitude { get; set; }
        public double? HumanstrElevation { get; set; }
        public long? HumanAltGeoLocationID { get; set; }
        public long? HumanAltidfsLocation { get; set; }
        public bool? HumanAltForeignAddressIndicator { get; set; }
        public string HumanAltForeignAddressString { get; set; }
        public string HumanAltstrStreetName { get; set; }
        public string HumanAltstrApartment { get; set; }
        public string HumanAltstrBuilding { get; set; }
        public string HumanAltstrHouse { get; set; }
        public string HumanAltidfsPostalCode { get; set; }
        public long? HumanPermGeoLocationID { get; set; }
        public long? HumanPermidfsLocation { get; set; }
        public string HumanPermstrStreetName { get; set; }
        public string HumanPermstrApartment { get; set; }
        public string HumanPermstrBuilding { get; set; }
        public string HumanPermstrHouse { get; set; }
        public string HumanPermidfsPostalCode { get; set; }
        public double? HumanAltstrLatitude { get; set; }
        public double? HumanAltstrLongitude { get; set; }
        public double? HumanAltstrElevation { get; set; }
        public string RegistrationPhone { get; set; }
        public string HomePhone { get; set; }
        public string WorkPhone { get; set; }
        public int? ContactPhoneCountryCode { get; set; }
        public string ContactPhone { get; set; }
        public long? ContactPhoneTypeID { get; set; }
        public int? ContactPhone2CountryCode { get; set; }
        public string ContactPhone2 { get; set; }
        public long? ContactPhone2TypeID { get; set; }
        public string AuditUser { get; set; }
    }
}
