namespace EIDSS.Domain.ResponseModels.PIN
{
    public class PINLoginReponse
    {
        public string LoginResult { get; set; }
    }
    public enum PINPersonGendersEnum : int
    {

        Unknown = 1,

        Male = 2,

        Female = 4,
    }
    public class PINGetPersonInfoResponse : object
    {
        public string ID { get; set; }
        public string PersonalID { get; set; }
        public string PasportID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }    
        public System.Nullable<System.DateTime> BirthDate { get; set; }
        public System.Nullable<System.DateTime> RejectDate { get; set; }
        public PINPersonGendersEnum Gender { get; set; }
        public string GenderCode { get; set; }
        public int Age { get; set; }
        public int AppDataID { get; set; }
        public string AddressSourceID { get; set; }
        public string AddressID { get; set; }
        public string Address { get; set; }
        public System.Nullable<long> RegionID { get; set; }
        public string Region { get; set; }
        public bool IsActive { get; set; }
        public bool IsAlive { get; set; }
        public bool IsFound { get; set; }
        public bool CraError { get; set; }
        public bool InsError { get; set; }
        public byte[] Photo { get; set; }
        public string Tel { get; set; }
        public System.Nullable<int> Status { get; set; }
        public System.Nullable<int> Condition { get; set; }
        public string MiddleName { get; set; }
        public string BirthPlace { get; set; }
        public int BirthPlaceCountryID { get; set; }
        public string BirthPlaceCountry { get; set; }
        public string BirthPlaceRaionID { get; set; }
        public string BirthPlaceRaion { get; set; }
        public string CitizenshipName { get; set; }
        public string CitizenshipCode { get; set; }
        public string DoubleCitizenshipName { get; set; }
        public string DoubleCitizenshipCode { get; set; }
        public bool HaveActiveCitizenship { get; set; }
        public System.Nullable<bool> IsBeneficiary { get; set; }
        public PINPersonDataSourcesEnum PersonDataSource { get; set; }
    }
    public enum PINPersonDataSourcesEnum : int
    {
        CRA = 0,
        LocalDB = 1,
    }
    public class PINGetPersonInfoExResponse
    {
        public string ID { get; set; }
        public string PrivateNumber { get; set; }
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public string BirthDate { get; set; }
        public string GenderName { get; set; }
        public string GenderID { get; set; }
        public string PersonStatus { get; set; }
        public string PersonStatusId { get; set; }
        public string BirthPlace { get; set; }
        public string BirthPlaceCountryId { get; set; }
        public string BirthPlaceCountry { get; set; }
        public string BirthPlaceRaionId { get; set; }
        public string BirthPlaceRaion { get; set; }
        public string CitizenshipCountry { get; set; }
        public string CitizenshipCountryID { get; set; }
        public string MainDataId { get; set; }
        public string AppDataId { get; set; }
        public PINRegistration Registration { get; set; }
        public PINPersonAdditionalStatuses PersonAdditionalStatuses { get; set; }
    }
    public class PINRegistration
    {
        public string OA_ID { get; set; }
        public string AddrStatus { get; set; }
        public string AddrStatusID { get; set; }
        public string ActiveAddress { get; set; }
        public string ActiveAddressAddressID { get; set; }
        public string ActiveAddressAddressSource { get; set; }
        public string ActiveAddressAddressSourceID { get; set; }
        public string ActiveAddressCountry { get; set; }
        public string ActiveAddressRegion { get; set; }
        public string ActiveAddressRaion { get; set; }
        public string ActiveAddressCity { get; set; }
        public string ActiveAddressTownship { get; set; }
        public string ActiveAddressVillage { get; set; }
    }
    public class PINPersonAdditionalStatuses
    {
        public string DeActID { get; set; }
        public string DeActRegDate { get; set; }
        public string DeDeathDate { get; set; }

    }
  }
