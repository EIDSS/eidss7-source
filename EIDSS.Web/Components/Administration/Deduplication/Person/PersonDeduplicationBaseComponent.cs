using EIDSS.Domain.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Person
{
    public class PersonDeduplicationBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected PersonDeduplicationSessionStateContainerService PersonDeduplicationService { get; set; }

		//[Inject]
		//protected ProtectedSessionStorage BrowserStorage { get; set; }

		[Inject]
		private ILogger<PersonDeduplicationBaseComponent> Logger { get; set; }
		#endregion

		#region Private Variables

		//private CancellationTokenSource source;
		//private CancellationToken token;

		#endregion

		#region Protected and Public Variables

		protected const int HUMANADDRESSNUMBERFIELD = 11;
		protected const int HUMANALTADDRESSNUMBERFIELD = 9;
		protected const int EMPLOYERADDRESSNUMBERFIELD = 9;
		protected const int SCHOOLADDRESSNUMBERFIELD = 9;

		protected const int GenderTypeID = 11;
		protected const int CitizenshipTypeID = 12;
		protected const int PersonalIDType = 13;
		protected const int ReportedAge = 14;
		protected const int ReportedAgeUOMID = 15;

		protected const int HumanidfsRegion = 41;
		protected const int IsEmployedTypeID = 34;

		protected const int ADDRESSNUMBERFIELD = 5;

        protected const int HumanAltidfsRegion = 47;
        protected const int HumanAltidfsCountry = 46;
        protected const int ContactPhoneTypeID = 52;
        protected const int ContactPhone2TypeID = 53;

		protected const int HumanPermidfsRegion = 54;

		protected const int EmployeridfsRegion = 35;
        protected const int EmployerGeoLocationID = 39;
        protected const int EmployeridfsCountry = 40;
		protected const int OccupationTypeID = 48;

		protected const int IsStudentTypeID = 41;
        protected const int SchoolidfsRegion = 42;
        protected const int SchoolGeoLocationID = 46;
        protected const int SchoolidfsCountry = 47;

        //protected bool disableMergeButton = true;
        protected bool disableMergeButton;
        protected bool showNextButton;
		protected bool showPreviousButton;
		protected bool showDetails = true;
		protected bool showReview = false;

		//public PersonDeduplicationTabEnum Tab { get; set; }


		protected Dictionary<string, int> keyDict = new Dictionary<string, int> {
	{
		"EIDSSPersonID",
		0
	},
	{
		"PersonalIDTypeName",
		1
	},
	{
		"PersonalID",
		2
	},
	{
		"LastOrSurname",
		3
	},
	{
		"SecondName",
		4
	},
	{
		"FirstOrGivenName",
		5
	},
	{
		"DateOfBirth",
		6
	},
	{
		"Age",
		7
	},
	{
		"GenderTypeName",
		8
	},
	{
		"CitizenshipTypeName",
		9
	},
	{
		"PassportNumber",
		10
	},
	{
		"GenderTypeID",
		11
	},
	{
		"CitizenshipTypeID",
		12
	},
	{
		"PersonalIDType",
		13
	},
	{
		"ReportedAge",
		14
	},
	{
		"ReportedAgeUOMID",
		15
	}

};
		protected Dictionary<string, int> keyDict2 = new Dictionary<string, int>()
{
	{
		"HumanRegion",
		0
	},
	{
		"HumanRayon",
		1
	},
	{
		"HumanSettlementType",
		2
	},
	{
		"HumanSettlement",
		3
	},
	{
		"HumanstrStreetName",
		4
	},
	{
		"HumanstrHouse",
		5
	},
	{
		"HumanstrBuilding",
		6
	},
	{
		"HumanstrApartment",
		7
	},
	{
		"HumanstrPostalCode",
		8
	},
	{
		"HumanstrLatitude",
		9
	},
	{
		"HumanstrLongitude",
		10
	},
	{
		"YNAnotherAddress",
		11
	},
	{
		"YNHumanAltForeignAddress",
		12
	},
	{
		"HumanAltCountry",
		13
	},
	{
		"HumanAltForeignAddressString",
		14
	},
	{
		"HumanAltRegion",
		15
	},
	{
		"HumanAltRayon",
		16
	},
	{
		"HumanAltSettlementType",
		17
	},
	{
		"HumanAltSettlement",
		18
	},
	{
		"HumanAltstrStreetName",
		19
	},
	{
		"HumanAltstrHouse",
		20
	},
	{
		"HumanAltstrBuilding",
		21
	},
	{
		"HumanAltstrApartment",
		22
	},
	{
		"HumanAltstrPostalCode",
		23
	},
	{
		"ContactPhoneCountryCode",
		24
	},
	{
		"ContactPhone",
		25
	},
	{
		"ContactPhoneTypeName",
		26
	},
	{
		"IsAnotherPhone",
		27
	},
	{
		"ContactPhone2CountryCode",
		28
	},
	{
		"ContactPhone2",
		29
	},
	{
		"ContactPhone2TypeName",
		30
	},
	{
		"YNPermanentSameAddress",
		31
	},
	{
		"HumanPermRegion",
		32
	},
	{
		"HumanPermRayon",
		33
	},
	{
		"HumanPermSettlementType",
		34
	},
	{
		"HumanPermSettlement",
		35
	},
	{
		"HumanPermstrStreetName",
		36
	},
	{
		"HumanPermstrHouse",
		37
	},
	{
		"HumanPermstrBuilding",
		38
	},
	{
		"HumanPermstrApartment",
		39
	},
	{
		"HumanPermstrPostalCode",
		40
	},
	{
		"HumanidfsRegion",
		41
	},
	{
		"HumanidfsRayon",
		42
	},
	{
		"HumanidfsSettlementType",
		43
	},
	{
		"HumanidfsSettlement",
		44
	},
	{
		"HumanGeoLocationID",
		45
	},
	{
		"HumanAltidfsCountry",
		46
	},
	{
		"HumanAltidfsRegion",
		47
	},
	{
		"HumanAltidfsRayon",
		48
	},
	{
		"HumanAltidfsSettlementType",
		49
	},
	{
		"HumanAltidfsSettlement",
		50
	},
	{
		"HumanAltGeoLocationID",
		51
	},
	{
		"ContactPhoneTypeID",
		52
	},
	{
		"ContactPhone2TypeID",
		53
	},
		{
		"HumanPermidfsRegion",
		54
	},
	{
		"HumanPermidfsRayon",
		55
	},
	{
		"HumanPermidfsSettlementType",
		56
	},
	{
		"HumanPermidfsSettlement",
		57
	},
	{
		"HumanPermGeoLocationID",
		58
	}
};
		protected Dictionary<string, int> keyDict3 = new Dictionary<string, int> {
	{
		"IsEmployedTypeName",
		0
	},
	{
		"OccupationTypeName",
		1
	},
	{
		"EmployerName",
		2
	},
	{
		"EmployedDateLastPresent",
		3
	},
	{
		"YNWorkSameAddress",
		4
	},
	{
		"YNEmployerForeignAddress",
		5
	},
	{
		"EmployerCountry",
		6
	},
	{
		"EmployerForeignAddressString",
		7
	},
	{
		"EmployerRegion",
		8
	},
	{
		"EmployerRayon",
		9
	},
	{
		"EmployerSettlementType",
		10
	},
	{
		"EmployerSettlement",
		11
	},
	{
		"EmployerstrStreetName",
		12
	},
	{
		"EmployerstrHouse",
		13
	},
	{
		"EmployerstrBuilding",
		14
	},
	{
		"EmployerstrApartment",
		15
	},
	{
		"EmployerstrPostalCode",
		16
	},
	{
		"EmployerPhone",
		17
	},
	{
		"IsStudentTypeName",
		18
	},
	{
		"SchoolName",
		19
	},
	{
		"SchoolDateLastAttended",
		20
	},
	{
		"YNSchoolForeignAddress",
		21
	},
	{
		"SchoolCountry",
		22
	},
	{
		"SchoolForeignAddressString",
		23
	},
	{
		"SchoolRegion",
		24
	},
	{
		"SchoolRayon",
		25
	},
	{
		"SchoolAltSettlementType",
		26
	},
	{
		"SchoolSettlement",
		27
	},
	{
		"SchoolstrStreetName",
		28
	},
	{
		"SchoolstrHouse",
		29
	},
	{
		"SchoolstrBuilding",
		30
	},
	{
		"SchoolstrApartment",
		31
	},
	{
		"SchoolstrPostalCode",
		32
	},
	{
		"SchoolPhone",
		33
	},
	{
		"IsEmployedTypeID",
		34
	},
	{
		"EmployeridfsRegion",
		35
	},
	{
		"EmployeridfsRayon",
		36
	},
	{
		"EmployeridfsSettlementType",
		37
	},
	{
		"EmployeridfsSettlement",
		38
	},
	{
		"EmployerGeoLocationID",
		39
	},
	{
		"EmployeridfsCountry",
		40
	},
	{
		"IsStudentTypeID",
		41
	},
	{
		"SchoolidfsRegion",
		42
	},
	{
		"SchoolidfsRayon",
		43
	},
	{
		"SchoolAltidfsSettlementType",
		44
	},
	{
		"SchoolidfsSettlement",
		45
	},
	{
		"SchoolGeoLocationID",
		46
	},
	{
		"SchoolidfsCountry",
		47
	},
	{
		"OccupationTypeID",
		48
	}

};
		protected Dictionary<int, string> labelDict = new Dictionary<int, string> {
	{
		0,
		"Person_ID"
	},
	{
		1,
		"Personal_ID_Type"
	},
	{
		2,
		"Personal_ID"
	},
	{
		3,
		"Last_Name"
	},
	{
		4,
		"Middle_Name"
	},
	{
		5,
		"First_Name"
	},
	{
		6,
		"Date_Of_Birth"
	},
	{
		7,
		"Age"
	},
	{
		8,
		"Gender"
	},
	{
		9,
		"Citizenship"
	},
	{
		10,
		"Passport_Number"
	},
	{
		11,
		"Gender"
	},
	{
		12,
		"Citizenship"
	},
	{
		13,
		"Personal_ID_Type"
	},
	{
		14,
		"Age"
	},
	{
		15,
		"Age"
	}
};
		protected Dictionary<int, string> labelDict2 = new Dictionary<int, string> {
	{
		0,
		"Region"
	},
	{
		1,
		"Rayon"
	},
	{
		2,
		"SettlementType"
	},
	{
		3,
		"Settlement"
	},
	{
		4,
		"Street"
	},
	{
		5,
		"House"
	},
	{
		6,
		"Building"
	},
	{
		7,
		"Apartment/Unit"
	},
	{
		8,
		"PostalCode"
	},
	{
		9,
		"Latitude"
	},
	{
		10,
		"Longitude"
	},
	{
		11,
		"AnotherAddress"
	},
	{
		12,
		"ForeignAddress"
	},
	{
		13,
		"ForeignAddressCountry"
	},
	{
		14,
		"AltOtherForeignAddress"
	},
	{
		15,
		"AltRegion"
	},
	{
		16,
		"AltRayon"
	},
	{
		17,
		"AltSettlementType"
	},
	{
		18,
		"AltSettlement"
	},
	{
		19,
		"AltStreet"
	},
	{
		20,
		"AltHouse"
	},
	{
		21,
		"AltBuilding"
	},
	{
		22,
		"AltApartment/Unit"
	},
	{
		23,
		"AltPostalCode"
	},
	{
		24,
		"CountryCode"
	},
	{
		25,
		"PhoneNumber"
	},
	{
		26,
		"PhoneType"
	},
	{
		27,
		"AnotherPhone"
	},
	{
		28,
		"AltCountryCode"
	},
	{
		29,
		"AltPhoneNumber"
	},
	{
		30,
		"AltPhoneType"
	},
	{
		31,
		"PermanentSameAddress"
	},
	{
		32,
		"HumanPermRegion"
	},
	{
		33,
		"HumanPermRayon"
	},
	{
		34,
		"HumanPermSettlementType"
	},
	{
		35,
		"HumanPermSettlement"
	},
	{
		36,
		"HumanPermStreet"
	},
	{
		37,
		"HumanPermHouse"
	},
	{
		38,
		"HumanPermBuilding"
	},
	{
		39,
		"HumanPermApartment/Unit"
	},
	{
		40,
		"HumanPermPostalCode"
	},
	{
		41,
		"Region"
	},
	{
		42,
		"Rayon"
	},
	{
		43,
		"SettlementType"
	},
	{
		44,
		"Settlement"
	},
	{
		45,
		"HumanGeoLocationID"
	},
	{
		46,
		"HumanAltidfsCountry"
	},
	{
		47,
		"AltRegion"
	},
	{
		48,
		"AltRayon"
	},
	{
		49,
		"AltSettlementType"
	},
	{
		50,
		"AltSettlement"
	},
	{
		51,
		"HumanAltGeoLocationID"
	},
	{
		52,
		"PhoneType"
	},
	{
		53,
		"AltPhoneType"
	},
	{
		54,
		"PermRegion"
	},
	{
		55,
		"PermRayon"
	},
	{
		56,
		"PermSettlementType"
	},
	{
		57,
		"PermSettlement"
	},
	{
		58,
		"HumanPermGeoLocationID"
	}
};
		protected Dictionary<int, string> labelDict3 = new Dictionary<int, string> {
	{
		0,
		"Employed"
	},
	{
		1,
		"Occupation"
	},
	{
		2,
		"EmployerName"
	},
	{
		3,
		"EmployedDate"
	},
	{
		4,
		"SameWorkAddress"
	},
	{
		5,
		"WorkForeignAddressIndicator"
	},
	{
		6,
		"WorkCountry"
	},
	{
		7,
		"WorkForeignAddress"
	},
	{
		8,
		"WorkRegion"
	},
	{
		9,
		"WorkRayon"
	},
	{
		10,
		"WorkSettlementType"
	},
	{
		11,
		"WorkSettlement"
	},
	{
		12,
		"WorkStreet"
	},
	{
		13,
		"WorkHouse"
	},
	{
		14,
		"WorkBuilding"
	},
	{
		15,
		"WorkApartment/Unit"
	},
	{
		16,
		"WorkPostalCode"
	},
	{
		17,
		"WorkPhoneNumber"
	},
	{
		18,
		"CurrentlyInSchool"
	},
	{
		19,
		"SchoolName"
	},
	{
		20,
		"SchoolDate"
	},
	{
		21,
		"SchoolForeignAddressIndicator"
	},
	{
		22,
		"SchoolCountry"
	},
	{
		23,
		"SchoolForeignAddress"
	},
	{
		24,
		"SchoolRegion"
	},
	{
		25,
		"SchoolRayon"
	},
	{
		26,
		"SchoolSettlementType"
	},
	{
		27,
		"SchoolSettlement"
	},
	{
		28,
		"SchoolStreet"
	},
	{
		29,
		"SchoolHouse"
	},
	{
		30,
		"SchoolBuilding"
	},
	{
		31,
		"SchoolApartment/Unit"
	},
	{
		32,
		"SchoolPostalCode"
	},
	{
		33,
		"SchoolPhoneNumber"
	},
	{
		34,
		"Employed"
	},
	{
		35,
		"WorkRegion"
	},
	{
		36,
		"WorkRayon"
	},
	{
		37,
		"WorkSettlementType"
	},
	{
		38,
		"WorkSettlement"
	},
	{
		39,
		"WorkLocation"
	},
	{
		40,
		"WorkCountry"
	},
	{
		41,
		"CurrentlyInSchool"
	},
	{
		42,
		"SchoolRegion"
	},
	{
		43,
		"SchoolRayon"
	},
	{
		44,
		"SchoolSettlementType"
	},
	{
		45,
		"SchoolSettlement"
	},
	{
		46,
		"SchoolLocation"
	},
	{
		47,
		"SchoolCountry"
	},
	{
		48,
		"Occupation"
	}
};
		#endregion
		#endregion

		#region Protected and Public Methods
		public void OnTabChange(int index)
		{
			switch (index)
			{
				case 0:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Information;
					showPreviousButton = false;
					showNextButton = true;
					break;
				case 1:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Address;
					showPreviousButton = true;
					showNextButton = true;
					break;
				case 2:
					PersonDeduplicationService.Tab = PersonDeduplicationTabEnum.Employment;
					showPreviousButton = true;
					showNextButton = false;
					break;
			}

			PersonDeduplicationService.TabChangeIndicator = true;
		}
		protected bool IsInTabInfo(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationInfoConstants.EIDSSPersonID:
					return true;
				case PersonDeduplicationInfoConstants.PersonalIDType:
					return true;
				case PersonDeduplicationInfoConstants.PersonalID:
					return true;
				case PersonDeduplicationInfoConstants.LastOrSurname:
					return true;
				case PersonDeduplicationInfoConstants.SecondName:
					return true;
				case PersonDeduplicationInfoConstants.FirstOrGivenName:
					return true;
				case PersonDeduplicationInfoConstants.DateOfBirth:
					return true;
				case PersonDeduplicationInfoConstants.ReportedAge:
					return true;
				case PersonDeduplicationInfoConstants.GenderTypeID:
					return true;
				case PersonDeduplicationInfoConstants.CitizenshipTypeID:
					return true;
				case PersonDeduplicationInfoConstants.PassportNumber:
					return true;
				case PersonDeduplicationInfoConstants.GenderTypeName:
					return true;
				case PersonDeduplicationInfoConstants.CitizenshipTypeName:
					return true;
				case PersonDeduplicationInfoConstants.PersonalIDTypeName:
					return true;
				case PersonDeduplicationInfoConstants.Age:
					return true;
				case PersonDeduplicationInfoConstants.ReportedAgeUOMID:
					return true;
			}
			return false;
		}

		protected bool IsInTabAddress(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationAddressConstants.HumanidfsRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrStreetName:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrHouse:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrBuilding:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrApartment:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrPostalCode:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrLatitude:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrLongitude:
					return true;
				case PersonDeduplicationAddressConstants.HumanGeoLocationID:
					return true;
				//Case PersonDeduplicationAddressConstants.HumanAltForeignAddressIndicator
				//    Return True
				case PersonDeduplicationAddressConstants.HumanAltForeignAddressString:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltGeoLocationID:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrStreetName:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrHouse:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrBuilding:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrApartment:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrPostalCode:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsCountry:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhoneCountryCode:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhone:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhoneTypeID:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhone2CountryCode:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhone2:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhone2TypeID:
					return true;
				case PersonDeduplicationAddressConstants.HumanRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanSettlement:
					return true;
				//Case PersonDeduplicationAddressConstants.HumanCountry
				//    Return True
				case PersonDeduplicationAddressConstants.HumanAltRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltCountry:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhoneTypeName:
					return true;
				case PersonDeduplicationAddressConstants.ContactPhone2TypeName:
					return true;
				//Case PersonDeduplicationAddressConstants.HumanidfsCountry
				//    Return True
				case PersonDeduplicationAddressConstants.IsAnotherPhone:
					return true;
				case PersonDeduplicationAddressConstants.YNAnotherAddress:
					return true;
				case PersonDeduplicationAddressConstants.YNHumanAltForeignAddress:
					return true;
				case PersonDeduplicationAddressConstants.YNPermanentSameAddress:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermidfsRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermidfsRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermidfsSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermidfsSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermstrStreetName:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermstrHouse:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermstrBuilding:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermstrApartment:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermstrPostalCode:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermGeoLocationID:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermSettlementType:
					return true;
				case PersonDeduplicationAddressConstants.HumanPermSettlement:
					return true;
			}
			return false;
		}

		protected bool IsInTabEmp(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationEmpConstants.IsEmployedTypeID:
					return true;
				case PersonDeduplicationEmpConstants.OccupationTypeID:
					return true;
				case PersonDeduplicationEmpConstants.EmployerName:
					return true;
				case PersonDeduplicationEmpConstants.EmployedDateLastPresent:
					return true;
				case PersonDeduplicationEmpConstants.EmployerPhone:
					return true;
				//Case PersonDeduplicationEmpConstants.EmployerForeignAddressIndicator
				//    Return True
				case PersonDeduplicationEmpConstants.EmployerForeignAddressString:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsRegion:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsRayon:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsSettlement:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrStreetName:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrHouse:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrBuilding:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrApartment:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrPostalCode:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsCountry:
					return true;
				case PersonDeduplicationEmpConstants.IsStudentTypeID:
					return true;
				case PersonDeduplicationEmpConstants.SchoolName:
					return true;
				case PersonDeduplicationEmpConstants.SchoolDateLastAttended:
					return true;
				//Case PersonDeduplicationEmpConstants.SchoolForeignAddressIndicator
				//    Return True
				case PersonDeduplicationEmpConstants.SchoolForeignAddressString:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsRegion:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsRayon:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsSettlement:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrStreetName:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrHouse:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrBuilding:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrApartment:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrPostalCode:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsCountry:
					return true;
				case PersonDeduplicationEmpConstants.SchoolPhone:
					return true;
				case PersonDeduplicationEmpConstants.IsEmployedTypeName:
					return true;
				case PersonDeduplicationEmpConstants.OccupationTypeName:
					return true;
				case PersonDeduplicationEmpConstants.EmployerRegion:
					return true;
				case PersonDeduplicationEmpConstants.EmployerRayon:
					return true;
				case PersonDeduplicationEmpConstants.EmployerSettlement:
					return true;
				case PersonDeduplicationEmpConstants.EmployerCountry:
					return true;
				case PersonDeduplicationEmpConstants.IsStudentTypeName:
					return true;
				case PersonDeduplicationEmpConstants.SchoolCountry:
					return true;
				case PersonDeduplicationEmpConstants.SchoolRegion:
					return true;
				case PersonDeduplicationEmpConstants.SchoolRayon:
					return true;
				case PersonDeduplicationEmpConstants.SchoolSettlement:
					return true;
				case PersonDeduplicationEmpConstants.EmployerGeoLocationID:
					return true;
				case PersonDeduplicationEmpConstants.SchoolGeoLocationID:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsSettlementType:
					return true;
				case PersonDeduplicationEmpConstants.SchoolAltidfsSettlementType:
					return true;
				case PersonDeduplicationEmpConstants.EmployerSettlementType:
					return true;
				case PersonDeduplicationEmpConstants.SchoolAltSettlementType:
					return true;
				case PersonDeduplicationEmpConstants.YNEmployerForeignAddress:
					return true;
				case PersonDeduplicationEmpConstants.YNSchoolForeignAddress:
					return true;
				case PersonDeduplicationEmpConstants.YNWorkSameAddress:
					return true;
			}
			return false;
		}

		protected async Task OnRecordSelectionChangeAsync(int value)
		{
			Boolean bFirst = false;
			if (PersonDeduplicationService.SurvivorInfoList == null)
				bFirst = true;

			UnCheckAll();
			if (bFirst == false)
				ReloadTabs();

			switch (value)
			{
				case 1:
					PersonDeduplicationService.RecordSelection = 1;
					PersonDeduplicationService.Record2Selection = 2;
					PersonDeduplicationService.SurvivorHumanMasterID = PersonDeduplicationService.HumanMasterID;
					PersonDeduplicationService.SupersededHumanMasterID = PersonDeduplicationService.HumanMasterID2;

					PersonDeduplicationService.SurvivorInfoList = PersonDeduplicationService.InfoList.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorAddressList = PersonDeduplicationService.AddressList0.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorEmpList = PersonDeduplicationService.EmpList0.Select(a => a.Copy()).ToList();

					CheckAllSurvivorfields(PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2);
					break;
				case 2:
					PersonDeduplicationService.RecordSelection = 2;
					PersonDeduplicationService.Record2Selection = 1;
					PersonDeduplicationService.SurvivorHumanMasterID = PersonDeduplicationService.HumanMasterID2;
					PersonDeduplicationService.SupersededHumanMasterID = PersonDeduplicationService.HumanMasterID;

					PersonDeduplicationService.SurvivorInfoList = PersonDeduplicationService.InfoList2.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorAddressList = PersonDeduplicationService.AddressList02.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorEmpList = PersonDeduplicationService.EmpList02.Select(a => a.Copy()).ToList();

					CheckAllSurvivorfields(PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList);
					break;
				default:
					break;
			}

            PersonDeduplicationService.chkCheckAll = value == 1;
            PersonDeduplicationService.chkCheckAll2 = value == 2;
            PersonDeduplicationService.chkCheckAllAddress = value == 1;
            PersonDeduplicationService.chkCheckAllAddress2 = value == 2;
            PersonDeduplicationService.chkCheckAllEmp = value == 1;
            PersonDeduplicationService.chkCheckAllEmp2 = value == 2;

            await InvokeAsync(StateHasChanged);
		}
		protected async Task OnRecord2SelectionChangeAsync(int value)
		{
			Boolean bFirst = false;
			if (PersonDeduplicationService.SurvivorInfoList == null)
				bFirst = true;

			UnCheckAll();
			if (bFirst == false)
				ReloadTabs();

			switch (value)
			{
				case 1:
					PersonDeduplicationService.RecordSelection = 2;
					PersonDeduplicationService.Record2Selection = 1;
					PersonDeduplicationService.SurvivorHumanMasterID = PersonDeduplicationService.HumanMasterID2;
					PersonDeduplicationService.SupersededHumanMasterID = PersonDeduplicationService.HumanMasterID;

					PersonDeduplicationService.SurvivorInfoList = PersonDeduplicationService.InfoList2.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorAddressList = PersonDeduplicationService.AddressList02.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorEmpList = PersonDeduplicationService.EmpList02.Select(a => a.Copy()).ToList();

					CheckAllSurvivorfields(PersonDeduplicationService.InfoList2, PersonDeduplicationService.InfoList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.EmpList2, PersonDeduplicationService.EmpList);
					break;
				case 2:
					PersonDeduplicationService.RecordSelection = 1;
					PersonDeduplicationService.Record2Selection = 2;
					PersonDeduplicationService.SurvivorHumanMasterID = PersonDeduplicationService.HumanMasterID;
					PersonDeduplicationService.SupersededHumanMasterID = PersonDeduplicationService.HumanMasterID2;

					PersonDeduplicationService.SurvivorInfoList = PersonDeduplicationService.InfoList.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorAddressList = PersonDeduplicationService.AddressList0.Select(a => a.Copy()).ToList();
					PersonDeduplicationService.SurvivorEmpList = PersonDeduplicationService.EmpList0.Select(a => a.Copy()).ToList();

					CheckAllSurvivorfields(PersonDeduplicationService.InfoList, PersonDeduplicationService.InfoList2, PersonDeduplicationService.AddressList, PersonDeduplicationService.AddressList2, PersonDeduplicationService.EmpList, PersonDeduplicationService.EmpList2);
					break;
				default:
					break;
			}

            PersonDeduplicationService.chkCheckAll = value == 2;
            PersonDeduplicationService.chkCheckAll2 = value == 1;
            PersonDeduplicationService.chkCheckAllAddress = value == 2;
            PersonDeduplicationService.chkCheckAllAddress2 = value == 1;
            PersonDeduplicationService.chkCheckAllEmp = value == 2;
            PersonDeduplicationService.chkCheckAllEmp2 = value == 1;

            await InvokeAsync(StateHasChanged);
		}

		protected void UnCheckAll()
		{
			PersonDeduplicationService.chkCheckAll = false;
			PersonDeduplicationService.chkCheckAll2 = false;
			PersonDeduplicationService.chkCheckAllAddress = false;
			PersonDeduplicationService.chkCheckAllAddress2 = false;
			PersonDeduplicationService.chkCheckAllEmp = false;
			PersonDeduplicationService.chkCheckAllEmp2 = false;
		}

        protected void ReloadTabs()
        {
			//if (PersonDeduplicationService.RecordSelection != 0 && PersonDeduplicationService.Record2Selection != 0)
			//{
			//Bind Tab Info
			PersonDeduplicationService.InfoList = null;
			PersonDeduplicationService.InfoList2 = null;
			PersonDeduplicationService.InfoList = PersonDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
				PersonDeduplicationService.InfoList2 = PersonDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();

				foreach (Field item in PersonDeduplicationService.InfoList)
				{
					if (item.Checked == true)
					{
						item.Checked = true;
						item.Disabled = true;
						PersonDeduplicationService.InfoList2[item.Index].Checked = true;
						PersonDeduplicationService.InfoList2[item.Index].Disabled = true;
					}
				}

				PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			//Bind Tab Address
			PersonDeduplicationService.AddressList = null;
			PersonDeduplicationService.AddressList2 = null;
			PersonDeduplicationService.AddressList = PersonDeduplicationService.AddressList0.Select(a => a.Copy()).ToList();
				PersonDeduplicationService.AddressList2 = PersonDeduplicationService.AddressList02.Select(a => a.Copy()).ToList();

				foreach (Field item in PersonDeduplicationService.AddressList)
				{
					if (item.Checked == true)
					{
						item.Checked = true;
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Checked = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
					else
					if (IsInHumanAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
					else if (IsInHumanAltAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
					}
				}

				foreach (Field item in PersonDeduplicationService.AddressList)
				{
					if (item.Key == PersonDeduplicationAddressConstants.HumanRegion && item.Checked == true)
					{
						if (GroupAllChecked(item.Index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
						{
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.AddressList2[item.Index].Checked = false;
							PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
						}
					}
					else if (item.Key == PersonDeduplicationAddressConstants.HumanAltRegion && item.Checked == true)
					{
						if (GroupAllChecked(item.Index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
						{
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.AddressList2[item.Index].Checked = false;
							PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
						}
					}
				}

				PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);

			//Bind Tab Emp 
			PersonDeduplicationService.EmpList = null;
			PersonDeduplicationService.EmpList2 = null;
			PersonDeduplicationService.EmpList = PersonDeduplicationService.EmpList0.Select(a => a.Copy()).ToList();
				PersonDeduplicationService.EmpList2 = PersonDeduplicationService.EmpList02.Select(a => a.Copy()).ToList();

				foreach (Field item in PersonDeduplicationService.EmpList)
				{
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    PersonDeduplicationService.EmpList2[item.Index].Checked = true;
                    PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
                }
                else
                if (IsInEmployerAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
					}
					else if (IsInSchoolAddressGroup(item.Key) == true)
					{
						item.Disabled = true;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
					}
				}

				foreach (Field item in PersonDeduplicationService.EmpList)
				{
					if (item.Key == PersonDeduplicationEmpConstants.EmployerRegion && item.Checked == true)
					{
						if (GroupAllChecked(item.Index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
						{
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.EmpList2[item.Index].Checked = false;
							PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
						}
					}
					else if (item.Key == PersonDeduplicationEmpConstants.SchoolRegion && item.Checked == true)
					{
						if (GroupAllChecked(item.Index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
						{
							item.Checked = false;
							item.Disabled = false;
							PersonDeduplicationService.EmpList2[item.Index].Checked = false;
							PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
						}
					}
				}

				PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
				PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);
			//}
		}

		protected void CheckAllSurvivorfields(IList<Field> list, IList<Field> list2, IList<Field> listAddress, IList<Field> listAddress2, IList<Field> listEmp, IList<Field> listEmp2)
		{
			foreach (Field item in list)
			{
				item.Checked = true;
				list2[item.Index].Checked = false;
			}

			foreach (Field item in listAddress)
			{
				item.Checked = true;
				listAddress2[item.Index].Checked = false;
			}

			foreach (Field item in listEmp)
			{
				item.Checked = true;
				listEmp2[item.Index].Checked = false;
			}
		}

		protected bool AllFieldValuePairsUnmatched()
		{
			//try
			//{
			foreach (Field item in PersonDeduplicationService.InfoList)
			{
				if (item.Value == PersonDeduplicationService.InfoList2[item.Index].Value && item.Value != null && item.Value != "")
				{
					return false;
				}
			}

			foreach (Field item in PersonDeduplicationService.AddressList)
			{
				if (item.Value == PersonDeduplicationService.AddressList2[item.Index].Value && item.Value != null && item.Value != "")
				{
					return false;
				}
			}

			foreach (Field item in PersonDeduplicationService.EmpList)
			{
				if (item.Value == PersonDeduplicationService.EmpList2[item.Index].Value && item.Value != null && item.Value != "")
				{
					return false;
				}
			}

			return true;
			//}
			//catch (Exception ex)
			//{
			//	_logger.LogError(ex.Message);
			//}
		}

		protected async Task CheckAllAsync(IList<Field> list, IList<Field> list2, bool check, bool check2, IList<Field> survivorList, string strValidTabName)
		{
			try
			{
				string value = string.Empty;
				string label = string.Empty;

				if (AllFieldValuePairsUnmatched() == true)
				{
					await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
					UnCheckAll();
				}
				else if (PersonDeduplicationService.RecordSelection == 0 && PersonDeduplicationService.Record2Selection == 0)
				{
					await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
					UnCheckAll();
				}
				else
				{
					if (check == true)
					{
						check2 = false;
						//Session(strValidTabName) = true;
						foreach (Field item in list)
						{
							if (item.Checked == false)
							{
								item.Checked = true;
								list2[item.Index].Checked = false;
								value = item.Value;
								if (survivorList != null)
								{
									if (survivorList.Count > 0)
									{
										label = survivorList[item.Index].Label;

										if (value == null)
										{
											if (survivorList[item.Index].Value == null)
												survivorList[item.Index].Label = label.Replace(": ", ": " + string.Empty);
											else
												survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, "");
										}
										else if (survivorList[item.Index].Value == null)
										{
											//survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
											survivorList[item.Index].Label = label.Replace(": ", ": " + value);
										}
										else if (survivorList[item.Index].Value == string.Empty)
										{
											//survivorList[item.Index].Label = label.Replace("<br><font style='color:#333;font-size:12px;font-weight:normal'>", "<br><font style='color:#333;font-size:12px;font-weight:normal'>" + value);
											survivorList[item.Index].Label = label.Replace(": ", ": " + value);
										}
										else
										{
											survivorList[item.Index].Label = label.Replace(survivorList[item.Index].Value, value);
										}

										survivorList[item.Index].Value = value;
									}
								}
							}
						}

						foreach (Field item in list)
						{
							if (item.Checked == true && list2[item.Index].Checked == true)
							{
								item.Disabled = true;
							}
						}
					}
				}

				await EableDisableMergeButtonAsync();

			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		protected bool TabInfoValid()
		{
			if (IsInfoValid() == false)
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			return true;
		}

		protected async Task BindTabInfoAsync()
		{
			PersonDeduplicationService.InfoList = PersonDeduplicationService.InfoList0.Select(a => a.Copy()).ToList();
			PersonDeduplicationService.InfoList2 = PersonDeduplicationService.InfoList02.Select(a => a.Copy()).ToList();
			//PersonDeduplicationService.InfoList = PersonDeduplicationService.InfoList0;
			//PersonDeduplicationService.InfoList2 = PersonDeduplicationService.InfoList02;

			foreach (Field item in PersonDeduplicationService.InfoList)
			{
				if (item.Checked == true)
				{
					item.Checked = true;
					item.Disabled = true;
					PersonDeduplicationService.InfoList2[item.Index].Checked = true;
					PersonDeduplicationService.InfoList2[item.Index].Disabled = true;
				}
			}

			PersonDeduplicationService.InfoValues = (IEnumerable<int>)PersonDeduplicationService.InfoList.Where(s => s.Checked == true).Select(s => s.Index);
			PersonDeduplicationService.InfoValues2 = (IEnumerable<int>)PersonDeduplicationService.InfoList2.Where(s => s.Checked == true).Select(s => s.Index);

			await EableDisableMergeButtonAsync();
			TabInfoValid();
		}

		protected async Task EableDisableMergeButtonAsync()
		{
			if (AllTabValid() == true)
			{
				disableMergeButton = false;
				await InvokeAsync(StateHasChanged);
			}
			else
				disableMergeButton = true;

			await InvokeAsync(StateHasChanged);
		}

		protected bool TabAddressValid()
		{
			if (IsAddressValid() == false)
			{
				//spAddress.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spAddress.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			return true;
		}

		protected async Task BindTabAddressAsync()
		{
			PersonDeduplicationService.AddressList = PersonDeduplicationService.AddressList0.Select(a => a.Copy()).ToList();
			PersonDeduplicationService.AddressList2 = PersonDeduplicationService.AddressList02.Select(a => a.Copy()).ToList();
			//PersonDeduplicationService.AddressList = PersonDeduplicationService.AddressList0;
			//PersonDeduplicationService.AddressList2 = PersonDeduplicationService.AddressList02;

			foreach (Field item in PersonDeduplicationService.AddressList)
			{
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    PersonDeduplicationService.AddressList2[item.Index].Checked = true;
                    PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
                }
                else
                if (IsInHumanAddressGroup(item.Key) == true)
				{
					item.Disabled = true;
					PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
				}
				else if (IsInHumanAltAddressGroup(item.Key) == true)
				{
					item.Disabled = true;
					PersonDeduplicationService.AddressList2[item.Index].Disabled = true;
				}
			}

			foreach (Field item in PersonDeduplicationService.AddressList)
			{
				if (item.Key == PersonDeduplicationAddressConstants.HumanRegion && item.Checked == true)
				{
					if (GroupAllChecked(item.Index, HUMANADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
					{
						item.Checked = false;
						item.Disabled = false;
						PersonDeduplicationService.AddressList2[item.Index].Checked = false;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
					}
				}
				else if (item.Key == PersonDeduplicationAddressConstants.HumanAltRegion && item.Checked == true)
				{
					if (GroupAllChecked(item.Index, HUMANALTADDRESSNUMBERFIELD, PersonDeduplicationService.AddressList) == false)
					{
						item.Checked = false;
						item.Disabled = false;
						PersonDeduplicationService.AddressList2[item.Index].Checked = false;
						PersonDeduplicationService.AddressList2[item.Index].Disabled = false;
					}
				}
			}

			PersonDeduplicationService.AddressValues = (IEnumerable<int>)PersonDeduplicationService.AddressList.Where(s => s.Checked == true).Select(s => s.Index);
			PersonDeduplicationService.AddressValues2 = (IEnumerable<int>)PersonDeduplicationService.AddressList2.Where(s => s.Checked == true).Select(s => s.Index);

			await EableDisableMergeButtonAsync();

			TabAddressValid();

		}

		protected bool IsInHumanAddressGroup(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationAddressConstants.HumanRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrStreetName:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrHouse:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrBuilding:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrApartment:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrPostalCode:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrLatitude:
					return true;
				case PersonDeduplicationAddressConstants.HumanstrLongitude:
					return true;
				case PersonDeduplicationAddressConstants.HumanSettlementType:
					return true;
			}
			return false;
		}

		protected bool IsInHumanAltAddressGroup(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationAddressConstants.HumanAltRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrStreetName:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrHouse:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrBuilding:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrApartment:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltstrPostalCode:
					return true;
				//Case PersonDeduplicationAddressConstants.HumanAltCountry
				//    Return True
				case PersonDeduplicationAddressConstants.HumanAltSettlementType:
					return true;
			}
			return false;
		}

		protected bool IsInEmployerAddressGroup(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationEmpConstants.EmployerRayon:
					return true;
				case PersonDeduplicationEmpConstants.EmployerSettlement:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrStreetName:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrHouse:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrBuilding:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrApartment:
					return true;
				case PersonDeduplicationEmpConstants.EmployerstrPostalCode:
					return true;
				case PersonDeduplicationEmpConstants.EmployerSettlementType:
					return true;
			}
			return false;
		}

		protected bool IsInSchoolAddressGroup(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationEmpConstants.SchoolRayon:
					return true;
				case PersonDeduplicationEmpConstants.SchoolSettlement:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrStreetName:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrHouse:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrBuilding:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrApartment:
					return true;
				case PersonDeduplicationEmpConstants.SchoolstrPostalCode:
					return true;
				case PersonDeduplicationEmpConstants.SchoolAltSettlementType:
					return true;
			}
			return false;
		}

		protected bool GroupAllChecked(int index, int length, IList<Field> list)
		{
			bool AllChecked = true;

			foreach (Field item in list)
			{
				if (item.Index > index && item.Index <= index + length - 1 && item.Checked == false)
				{
					AllChecked = false;
					//return false;
				}
			}

			return AllChecked;
		}

		protected bool TabEmpValid()
		{
			if (IsEmpValid() == false)
			{
				//spEmp.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spEmp.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			return true;
		}

		protected async Task BindTabEmpAsync()
		{
			//Bind Tab Emp 
			PersonDeduplicationService.EmpList = PersonDeduplicationService.EmpList0.Select(a => a.Copy()).ToList();
			PersonDeduplicationService.EmpList2 = PersonDeduplicationService.EmpList02.Select(a => a.Copy()).ToList();

			foreach (Field item in PersonDeduplicationService.EmpList)
			{
                if (item.Checked == true)
                {
                    item.Checked = true;
                    item.Disabled = true;
                    PersonDeduplicationService.EmpList2[item.Index].Checked = true;
                    PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
                }
                else
                if (IsInEmployerAddressGroup(item.Key) == true)
				{
					item.Disabled = true;
					PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
				}
				else if (IsInSchoolAddressGroup(item.Key) == true)
				{
					item.Disabled = true;
					PersonDeduplicationService.EmpList2[item.Index].Disabled = true;
				}
			}

			foreach (Field item in PersonDeduplicationService.EmpList)
			{
				if (item.Key == PersonDeduplicationEmpConstants.EmployerRegion && item.Checked == true)
				{
					if (GroupAllChecked(item.Index, EMPLOYERADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
					{
						item.Checked = false;
						item.Disabled = false;
						PersonDeduplicationService.EmpList2[item.Index].Checked = false;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
					}
				}
				else if (item.Key == PersonDeduplicationEmpConstants.SchoolRegion && item.Checked == true)
				{
					if (GroupAllChecked(item.Index, SCHOOLADDRESSNUMBERFIELD, PersonDeduplicationService.EmpList) == false)
					{
						item.Checked = false;
						item.Disabled = false;
						PersonDeduplicationService.EmpList2[item.Index].Checked = false;
						PersonDeduplicationService.EmpList2[item.Index].Disabled = false;
					}
				}
			}

			PersonDeduplicationService.EmpValues = (IEnumerable<int>)PersonDeduplicationService.EmpList.Where(s => s.Checked == true).Select(s => s.Index);
			PersonDeduplicationService.EmpValues2 = (IEnumerable<int>)PersonDeduplicationService.EmpList2.Where(s => s.Checked == true).Select(s => s.Index);

			await EableDisableMergeButtonAsync();

			TabEmpValid();
		}

		protected bool AllTabValid()
		{
			if (IsInfoValid() == false)
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spInfo.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			if (IsAddressValid() == false)
			{
				//spAddress.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spAddress.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			if (IsEmpValid() == false)
			{
				//spEmp.Attributes("class") = "glyphicon glyphicon-ok normalcheckmark";
				return false;
			}
			else
			{
				//spEmp.Attributes("class") = "glyphicon glyphicon-ok passcheckmark";
			}
			return true;
		}

		protected void SelectAndUnSelectIDfield(int i, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
		{
			//try
			//{
			string value = string.Empty;
			string label = string.Empty;

			list[i].Checked = true;
			list2[i].Checked = false;
			//value = control.Items(i).Value;
			value = list[i].Value;
			if (listSurvivor != null)
			{
				if (listSurvivor.Count > 0)
				{
					listSurvivor[i].Checked = true;
					label = listSurvivor[i].Label;
					if (value == null)
					{
						listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
					}
					else if (listSurvivor[i].Value == null)
					{
						listSurvivor[i].Label = label.Replace(": ", ": " + value);
						//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
					}
					else if (listSurvivor[i].Value == value)
					{
						listSurvivor[i].Label = label;
					}
					else if (listSurvivor[i].Value == "")
					{
						listSurvivor[i].Label = label.Replace(": ", ": " + value);
						//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
					}
					else
					{
						listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
					}
					listSurvivor[i].Value = value;
				}
			}

			//control.Items(i).Selected = true;
			//control2.Items(i).Selected = false;

			//BindCheckBoxList(control, list)
			//BindCheckBoxList(control2, list2)
			//}
			//catch (Exception ex)
			//{
			//	Log.Error(MethodBase.GetCurrentMethod().Name + LoggingConstants.ExceptionWasThrownMessage, ex);
			//	throw ex;
			//}
		}

		protected void SelectAllAndUnSelectAll(int index, int length, IList<Field> list, IList<Field> list2, IList<Field> listSurvivor)
		{
            try
            {
				string value = string.Empty;
				string label = string.Empty;

				for (int i = index; i <= index + length - 1; i++)
				{
					list[i].Checked = true;
					list2[i].Checked = false;
					value = list[i].Value;
					if (listSurvivor != null)
					{
						if (listSurvivor.Count > 0)
						{
							listSurvivor[i].Checked = true;
							label = listSurvivor[i].Label;
							if (value == null)
							{
								if (listSurvivor[i].Value == null)
									listSurvivor[i].Label = label.Replace(": ", ": " + string.Empty);
								else
									listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");

								//listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, "");
							}
							else if (listSurvivor[i].Value == null)
							{
								listSurvivor[i].Label = label.Replace(": ", ": " + value);
								//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
							}
							else if (listSurvivor[i].Value == value)
							{
								listSurvivor[i].Label = label;
							}
							else if (listSurvivor[i].Value == "")
							{
								//listSurvivor[i].Label = label.Replace("</font>", value + "</font>");
								listSurvivor[i].Label = label.Replace(": ", ": " + value);
							}
							else
							{
								listSurvivor[i].Label = label.Replace(listSurvivor[i].Value, value);
							}
							listSurvivor[i].Value = value;
						}
					}
				}

				BindCheckBoxList(index, length, list);
				BindCheckBoxList(index, length, list2);

				for (int i = 0; i <= list.Count - 1; i++)
				{
					if (list[i].Checked == true && list2[i].Checked == true)
					{
						//control.Items(i).Enabled = false;
						//control2.Items(i).Enabled = false;
						list[i].Disabled = true;
						list2[i].Disabled = true;
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		protected static bool IsOneOfLocationIDs(string strName)
		{
			switch (strName)
			{
				case PersonDeduplicationAddressConstants.HumanGeoLocationID:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanidfsSettlement:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltGeoLocationID:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsCountry:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsRegion:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsRayon:
					return true;
				case PersonDeduplicationAddressConstants.HumanAltidfsSettlement:
					return true;
				case PersonDeduplicationEmpConstants.EmployerGeoLocationID:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsCountry:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsRegion:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsRayon:
					return true;
				case PersonDeduplicationEmpConstants.EmployeridfsSettlement:
					return true;
				case PersonDeduplicationEmpConstants.SchoolGeoLocationID:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsRegion:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsRayon:
					return true;
				case PersonDeduplicationEmpConstants.SchoolidfsSettlement:
					return true;
			}
			return false;
		}

		public async Task<dynamic> ShowWarningMessage(string message, string localizedMessage)
		{
			List<DialogButton> buttons = new();
			var okButton = new DialogButton()
			{
				ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
				ButtonType = DialogButtonType.OK
			};
			buttons.Add(okButton);

			Dictionary<string, object> dialogParams = new()
			{
				{ nameof(EIDSSDialog.DialogButtons), buttons },
				{ nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
				{ nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
				{ nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning }
			};

			return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams);
		}

		#endregion
		#region Private Methods

		private bool IsInfoValid()
		{
			foreach (Field item in PersonDeduplicationService.InfoList)
			{
				if (item.Checked == false && PersonDeduplicationService.InfoList2[item.Index].Checked == false)
				{
					return false;
				}
			}
			return true;
		}

		private bool IsAddressValid()
		{
			foreach (Field item in PersonDeduplicationService.AddressList)
			{
				if (item.Checked == false && PersonDeduplicationService.AddressList2[item.Index].Checked == false)
				{
					return false;
				}
			}
			return true;
		}

		private bool IsEmpValid()
		{
			foreach (Field item in PersonDeduplicationService.EmpList)
			{
				if (item.Checked == false && PersonDeduplicationService.EmpList2[item.Index].Checked == false)
				{
					return false;
				}
			}
			return true;
		}

		private void BindCheckBoxList(int index, int length, IList<Field> list)
		{
			try
			{

				for (int i = index; i <= index + length - 1; i++)
				{
					if (list[i].Checked == true)
					{
						//list[i].Checked = true;
						if (IsInEmployerAddressGroup(list[i].Key) == true || IsInSchoolAddressGroup(list[i].Key) == true || IsInHumanAddressGroup(list[i].Key) == true || IsInHumanAltAddressGroup(list[i].Key) == true)
						{
							list[i].Disabled = true;
						}
					}
					else if (IsInEmployerAddressGroup(list[i].Key) == true)
					{
						list[i].Disabled = true;
					}
					else if (IsInSchoolAddressGroup(list[i].Key) == true)
					{
						list[i].Disabled = true;
					}
					else if (IsInHumanAddressGroup(list[i].Key) == true)
					{
						list[i].Disabled = true;
					}
					else if (IsInHumanAltAddressGroup(list[i].Key) == true)
					{
						list[i].Disabled = true;
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}

		#endregion
	}
}
