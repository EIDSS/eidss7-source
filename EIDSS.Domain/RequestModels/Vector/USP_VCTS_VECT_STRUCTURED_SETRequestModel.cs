using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class USP_VCTS_VECT_STRUCTURED_SETRequestModel
    {
        public  string LangID { get; set; }
        public long? idfVector { get; set; }
        public long? idfsDetailedVectorSurveillanceSession { get; set; }
        public long? idfHostVector { get; set; }
        public string strVectorID { get; set; }
        public string strFieldVectorID { get; set; }
        public long? idfDetailedLocation { get; set; }
        public long? lucDetailedCollectionidfsResidentType { get; set; }
        public long? lucDetailedCollectionidfsGroundType { get; set; }
        public long? lucDetailedCollectionidfsGeolocationType { get; set; }
        public long? lucDetailedCollectionidfsLocation { get; set; }
        public string lucDetailedCollectionstrApartment { get; set; }
        public string lucDetailedCollectionstrBuilding { get; set; }
        public string lucDetailedCollectionstrStreetName { get; set; }
        public string lucDetailedCollectionstrHouse { get; set; }
        public string lucDetailedCollectionstrPostCode { get; set; }
        public string lucDetailedCollectionstrDescription { get; set; }
        public double? lucDetailedCollectiondblDistance { get; set; }
        public double? lucDetailedCollectionstrLatitude { get; set; }
        public double? lucDetailedCollectionstrLongitude { get; set; }
        public double? lucDetailedCollectiondblAccuracy { get; set; }
        public double? lucDetailedCollectiondblAlignment { get; set; }
        public bool? blnForeignAddress { get; set; }
        public string strForeignAddress { get; set; }
        public bool? blnGeoLocationShared { get; set; }
        public int? intDetailedElevation { get; set; }
        public long? DetailedSurroundings { get; set; }
        public string strGEOReferenceSource { get; set; }
        public long? idfCollectedByOffice { get; set; }
        public long? idfCollectedByPerson { get; set; }
        public DateTime? datCollectionDateTime { get; set; }
        public long? idfsCollectionMethod { get; set; }
        public long? idfsBasisOfRecord { get; set; }
        public long? idfDetailedVectorType { get; set; }
        public long? idfsVectorSubType { get; set; }
        public int? intQuantity { get; set; }
        public long? idfsSex { get; set; }
        public long? idfIdentIFiedByOffice { get; set; }
        public long? idfIdentIFiedByPerson { get; set; }
        public DateTime? datIdentIFiedDateTime { get; set; }
        public long? idfsIdentIFicationMethod { get; set; }
        public long? idfObservation { get; set; }
        public long? idfsFormTemplate { get; set; }
        public long? idfsDayPeriod { get; set; }
        public string strComment { get; set; }
        public long? idfsEctoparASitesCollected { get; set; }
        public string Samples { get; set; }
        public string FieldTests { get; set; }
        public string AuditUser { get; set; }

    }
}
