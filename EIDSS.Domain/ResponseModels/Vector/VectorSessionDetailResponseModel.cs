using System;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class VectorSessionDetailResponseModel : BaseModel
    {
        public VectorSessionDetailResponseModel ShallowCopy() => (VectorSessionDetailResponseModel)MemberwiseClone();
        public long idfsVSSessionSummary { get; set; }
        public long idfVectorSurveillanceSession { get; set; }
        public string strVSSessionSummaryID { get; set; }
        public long? idfGeoLocation { get; set; }
        public long? idfsGeoLocationType { get; set; }
        public long? AdminLevel0Value { get; set; }
        public string AdminLevel0Text { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
        public long? PostalCodeID { get; set; }
        public string PostalCode { get; set; }
        public long? StreetID { get; set; }
        public string StreetName { get; set; }
        public string House { get; set; }
        public string Building { get; set; }
        public string Apartment { get; set; }
        public double? dblLongitude { get; set; }
        public double? dblLatitude { get; set; }
        public double? dblAlignment { get; set; }
        public double? dblAccuracy { get; set; }
        public double? dblElevation { get; set; }
        public DateTime? datCollectionDateTime { get; set; }
        public long? idfsVectorType { get; set; }
        public string strVectorType { get; set; }
        public long? idfsVectorSubType { get; set; }
        public string strVectorSubType { get; set; }
        public long? idfsSex { get; set; }
        public string strSex { get; set; }
        public int? intQuantity { get; set; }
        public int intRowStatus { get; set; }
        public long? idfsGroundType { get; set; }
        public double? dblDistance { get; set; }
        public double? dblDirection { get; set; }
        public string strDescription { get; set; }
        public string strForeignAddress { get; set; }
        public string PositiveDiseasesList { get; set; }
        public int RowAction { get; set; }
    }
}
