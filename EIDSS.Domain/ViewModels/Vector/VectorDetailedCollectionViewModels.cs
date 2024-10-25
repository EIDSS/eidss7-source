using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Domain.ViewModels.Vector
{
    public class VectorDetailedCollectionViewModel
    {
        public VectorDetailedCollectionViewModel ShallowCopy() => (VectorDetailedCollectionViewModel)MemberwiseClone();

        public long VectorSessionKey { get; set; }
        public long? VectorSessionDetailKey { get; set; }
        public long? HostVectorID { get; set; }
        public string DetailSessionID { get; set; }
        public string FieldVectorID { get; set; }
        public long? GeoLocationID { get; set; }
        public long? ResidentTypeID { get; set; }
        public long? GroundTypeID { get; set; }
        public long? GeoLocationTypeID { get; set; }
        public long? LocationID { get; set; }
        public string Apartment { get; set; }
        public string Building { get; set; }
        public string StreetName { get; set; }
        public string House { get; set; }
        public string PostCode { get; set; }
        public string Description { get; set; }
        public double? Distance { get; set; }
        public double? Longitude { get; set; }
        public double? Latitude { get; set; }
        public double? Accuracy { get; set; }
        public double? Alignment { get; set; }
        public double Elevation { get; set; }
        public bool? IsForeignAddress { get; set; }
        public string ForeignAddress { get; set; }
        public bool IsGeoLocationShared { get; set; }
        public int? DetailedElevation { get; set; }
        public long? DetailedSurroundings { get; set; }
        public string GeoReferenceSource { get; set; }
        public long? CollectedByOfficeID { get; set; }
        public long? CollectionByPersonID { get; set; }
        public DateTime? CollectionDateTime { get; set; }
        public long? CollectionMethodID { get; set; }
        public long? BasisOfRecordID { get; set; }
        public long? VectorTypeID { get; set; }
        public string VectorType { get; set; }
        public long? VectorSubTypeID { get; set; }
        public int? Quantity { get; set; }
        public long? SexID { get; set; }
        public long? IdentifiedByFieldOfficeID { get; set; }
        public long? IdentifiedByPersonID { get; set; }
        public DateTime? IdentifiedDateTime { get; set; }
        public long? IdentificationMethodID { get; set; }
        public long? ObservationID { get; set; }
        public long? FormTemplateID { get; set; }
        public long? DayPeriodID { get; set; }
        public string Comment { get; set; }
        public long? EctoparasitesCollectionID { get; set; }
        public LocationViewModel LocationViewModel { get; set; }
        public IList<VectorSampleGetListViewModel> Samples { get; set; }
        public IList<FieldTestGetListViewModel> FieldTests { get; set; }
        public IList<VectorSampleGetListViewModel> PendingSamples { get; set; }
        public IList<FieldTestGetListViewModel> PendingFieldTests { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }

}
