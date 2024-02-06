using EIDSS.Domain.ResponseModels.Vector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Vector
{
    public class VectorServeillanceAddEditViewModal
    {
        public int InvalidSection { get; set; }
        public long idfVector { get; set; }
        public string PageHeader { get; set; }
        public string SummaryHeader { get; set; }
        public string SessionID { get; set; }
        public string FieldSessionID { get; set; }
        public string OutbreakID { get; set; }
        public List <KeyValuePair<string,string>> Status { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? CloseDate { get; set; }
        public long VectorSessionId { get; set; }
        public string Description { get; set; }

        public string VectorTypes { get; set; }
        public long? VectorTypeID { get; set; }
        public string Diseases { get; set; }
        public long? DiseaseID { get; set; }
        public long? StatusID { get; set; }
        public int?  CollectionEffort { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public long? savedIdfVectorSurveillanceSession { get; set; }
        public long? savedIdfGeoLocation { get; set; }
        //Samples
        private ViewModels.Vector.Samples _samples;
        public ViewModels.Vector.Samples Samples { get { return _samples; } set { _samples = value; } }

        //Location
        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;
        public string LocationDescription { get; set; }
        public long? LocationDistance { get; set; }
        public long? LocationDirection { get; set; }
        public long? gislocationType { get; set; }
        public bool ShowCountry { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }
        public VectorServeillanceAddEditViewModal()
        {
            _samples = new Samples();
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
        
        }

        public List<USP_VCTS_VECT_GetDetailResponseModel> DetailedCollectionsList { get; set; }
    }

   

    public class DetailedCollections
    {
        public int Copy { get; set; }
        public int PoolVetorID { get; set; }
        public int PoolVetorID2{ get; set; }
        public int VectorType { get; set; }
        public DateTime? CollectionDate { get; set; }
        public String Region { get; set; }
        public String Rayon { get; set; }
      
    }

    public class AggregateCollections
    {
        public int RecordId { get; set; }
        public int VectorType { get; set; }
        public DateTime? CollectionDate { get; set; }
        public int NumberOfPools { get; set; }
        public int NumberOfVectors { get; set; }
    }

    
}
