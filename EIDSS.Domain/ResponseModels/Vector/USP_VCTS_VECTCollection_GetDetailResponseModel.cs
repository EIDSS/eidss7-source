using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_VECTCollection_GetDetailResponseModel
    {
        public long idfVector { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string strSessionID { get; set; }
        public long idfsVectorType { get; set; }
        public string strVectorType { get; set; }
        public string strSpecies { get; set; }
        public long? idfsSex { get; set; }
        public string strSex { get; set; }
        public long idfsVectorSubType { get; set; }
        public string strVectorID { get; set; }
        public string strFieldVectorID { get; set; }
        public int? intCollectionEffort { get; set; }
        public string strForeignAddress { get; set; }
        public long? idfsGroundType { get; set; }
        public string strGroundType { get; set; }
        public double? dblDistance { get; set; }
        public string strDescription { get; set; }
        public int? intElevation { get; set; }
        public long? idfsSurrounding { get; set; }
        public string strSurrounding { get; set; }
        public string strGEOReferenceSources { get; set; }
        public long? idfsBasisOfRecord { get; set; }
        public string strBasisOfRecord { get; set; }
        public long idfCollectedByOffice { get; set; }
        public string CollectedByOfffice { get; set; }
        public long? idfCollectedByPerson { get; set; }
        public string strCollectedByPerson { get; set; }
        public DateTime datCollectionDateTime { get; set; }
        public long? idfsDayPeriod { get; set; }
        public string DayPeriod { get; set; }
        public long? idfsCollectionMethod { get; set; }
        public string strCollectionMethod { get; set; }
        public long? idfsEctoparasitesCollected { get; set; }
        public string strEctoParasitesCollected { get; set; }
        public int intQuantity { get; set; }
        public long? idfIdentifiedByOffice { get; set; }
        public string IdentifiedByOfffice { get; set; }
        public long? idfIdentifiedByPerson { get; set; }
        public string strIdentifiedByPerson { get; set; }
        public long? idfLocation { get; set; }
        public long idfsGeoLocationType { get; set; }
        public long? AdminLevel0Value { get; set; }
        public string AdminLevel0Text { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
        public long? AdminLevel4Value { get; set; }
        public string AdminLevel4Text { get; set; }
        public long? AdminLevel5Value { get; set; }
        public string AdminLevel5Text { get; set; }
        public long? AdminLevel6Value { get; set; }
        public string AdminLevel6Text { get; set; }
        public double? dblLatitude { get; set; }
        public double? dblLongitude { get; set; }
        public string strStreetName { get; set; }
        public string strBuilding { get; set; }
        public string strHouse { get; set; }
        public string strApartment { get; set; }
        public long? idfsIdentificationMethod { get; set; }
        public DateTime? datIdentifiedDateTime { get; set; }
        public long? idfObservation { get; set; }
        public long? idfsGeolocationGroundType { get; set; }
        public double? dblDirection { get; set; }
        public string strComment { get; set; }
        public string strPostCode { get; set; }
        public long? idfHostVector { get; set; }
    }
}
