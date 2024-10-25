using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VectorSessionSetRequestModel
    {
        public long? idfVectorSurveillanceSession { get; set; }
        public string strSessionID { get; set; }
        public string strFieldSessionID { get; set; }
        public long? idfsVectorSurveillanceStatus { get; set; }
        public DateTime? datStartDate { get; set; }
        public DateTime? datCloseDate { get; set; }
        public long? idfOutbreak { get; set; }
        public int? intCollectionEffort { get; set; }
        public long? idfGeoLocation { get; set; }
        public long? idfsGeolocationType { get; set; }
        public long? idfsLocation { get; set; }
        public double? dblLatitude { get; set; }
        public double? dblLongitude { get; set; }
        public string strDescription { get; set; }
        public long? idfsGroundType { get; set; }
        public double? dblDistance { get; set; }
        public double? dblDirection { get; set; }
        public double? Elevation { get; set; }
        public string strStreetName { get; set; }
        public string strPostalCode { get; set; }
        public string strApartment { get; set; }
        public string strBuilding { get; set; }
        public string strHouse { get; set; }
        public bool? blnForeignAddress { get; set; }
        public string strForeignAddress { get; set; }
        public bool? blnGeoLocationShared { get; set; }
        public string strLocationDescription { get; set; }
        public long? SiteID { get; set; }
        public string AuditUser { get; set; }
        public string AggregateCollections { get; set; }
        public string DiagnosisInfo { get; set; }
        public string DetailedCollections { get; set; }
        public string Events { get; set; }
    }
}