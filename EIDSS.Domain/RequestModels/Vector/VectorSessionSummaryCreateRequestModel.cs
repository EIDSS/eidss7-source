using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VectorSessionSummaryCreateRequestModel
    {
        public long? idfsVSSessionSummary { get; set; }
        public long? idfDiagnosisVectorSurveillanceSession { get; set; }
        public string strVSSessionSummaryID { get; set; }
        public long? DiagnosisidfGeoLocation { get; set; }
        public long? lucAggregateCollectionidfsResidentType { get; set; }
        public long? lucAggregateCollectionidfsGroundType { get; set; }
        public long? lucAggregateCollectionidfsGeolocationType { get; set; }
        public long? lucAggregateCollectionLocationID { get; set; }
        public string lucAggregateCollectionstrApartment { get; set; }
        public string lucAggregateCollectionstrBuilding { get; set; }
        public string lucAggregateCollectionstrStreetName { get; set; }
        public string lucAggregateCollectionstrHouse { get; set; }
        public string lucAggregateCollectionstrPostCode { get; set; }
        public string lucAggregateCollectionstrDescription { get; set; }
        public double? lucAggregateCollectiondblDistance { get; set; }
        public double? lucAggregateCollectionstrLatitude { get; set; }
        public double? lucAggregateCollectionstrLongitude { get; set; }
        public double? lucAggregateCollectiondblAccuracy { get; set; }
        public double? lucAggregateCollectiondblAlignment { get; set; }
        public bool? blnForeignAddress { get; set; }
        public string strForeignAddress { get; set; }
        public bool? blnGeoLocationShared { get; set; }
        public DateTime? datSummaryCollectionDateTime { get; set; }
        public long? SummaryInfoSpecies { get; set; }
        public long? SummaryInfoSex { get; set; }
        public long? PoolsVectors { get; set; }
        public string AuditUser { get; set; }
    }
}
