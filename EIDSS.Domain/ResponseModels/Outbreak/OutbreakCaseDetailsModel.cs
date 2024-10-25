using EIDSS.Domain.Abstracts;
using System;
namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakCaseDetailsModel : BaseModel
    {
        public string strLastName { get; set; }
        public string strFirstName { get; set; }
        public string strMiddleName { get; set; }
        public DateTime? datDateofBirth { get; set; }
        public int? strAge { get; set; }
        public string strCitizenship { get; set; }
        public string strGender { get; set; }
        public long? idfsCountry { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public string strStreetName { get; set; }
        public string strPostCode { get; set; }
        public string strBuilding { get; set; }
        public string strHouse { get; set; }
        public string strApartment { get; set; }
        public string strAddressString { get; set; }
        public string ContactPhoneNbr { get; set; }
        public string Region { get; set; }
        public string Rayon { get; set; }
        public string Settlement { get; set; }
        public long? idfsPersonContactType { get; set; }
        public DateTime? datDateOfLastContact { get; set; }
        public string strPlaceInfo { get; set; }
        public string strComments { get; set; }
        public long? ContactStatusID { get; set; }
    }
}
