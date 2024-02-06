using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.PIN
{
    public class PersonalDataModel
    {
        public string ID { get; set; }
        public string PrivateNumber { get; set; }
        public string LastName { get; set; }
        public string LastNameEn { get; set; }
        public string FirstName { get; set; }
        public string FirstNameEn { get; set; }
        public string BirthDate { get; set; }
        public string GenderNameEn { get; set; }
        public string GenderName { get; set; }
        public string GenderID { get; set; }
        public string PersonStatus { get; set; }
        public string PersonStatusEn { get; set; }
        public string PersonStatusID { get; set; }
        public string BirthPlace { get; set; }
        public string BirthPlaceCountryID { get; set; }
        public string BirthPlaceCountry { get; set; }
        public string BirthPlaceRaionID { get; set; }
        public string BirthPlaceRaion { get; set; }
        public string CitizenshipCountry { get; set; }
        public string CitizenshipCountryID { get; set; }
        public string MainDataId { get; set; }
        public string AppDataId { get; set; }

        public RegistrationModel Registration { get; set; }

        public AdditionalStatusModel AdditionalStatus { get; set; }
    }

    public class RegistrationModel
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

    public class AdditionalStatusModel
    {

        public string DeActID { get; set; }
        public string DeActRegDate { get; set; }
        public string DeDeathDate { get; set; }
    }
}
