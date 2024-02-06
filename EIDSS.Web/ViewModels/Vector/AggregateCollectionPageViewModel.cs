using EIDSS.Domain.RequestModels.Vector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Vector
{
    public class AggregateCollectionPageViewModel
    {

       
        
        #region Location Properties
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }

        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;
        public string LocationDescription { get; set; }
        public long? LocationDistance { get; set; }
        public long? LocationDirection { get; set; }
        public long? gislocationType { get; set; }
        #endregion




        #region Set Request Object Properties
        private USP_VCTS_SESSIONSUMMARY_SETRequestModel _request;
        public USP_VCTS_SESSIONSUMMARY_SETRequestModel request { get { return _request; } set { _request = value; } }

        #endregion



        #region Request Object Properties

        #endregion
        public string RecordID { get; set; }

        public long? idfsVSSessionSummary { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }

     
        private List<VectorDiagnosisItem> _vectorDiagnosisItems;
        public List<VectorDiagnosisItem> vectorDiagnosisItems { get { return _vectorDiagnosisItems; } set { _vectorDiagnosisItems = value; } }

        public int MyProperty { get; set; }
        public string strSelectedDiagnosis { get; set; }

        public AggregateCollectionPageViewModel()
        {
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
            _request = new USP_VCTS_SESSIONSUMMARY_SETRequestModel();
            _vectorDiagnosisItems = new List<VectorDiagnosisItem>();
        }

       
    }

    #region SessionInformation

    #endregion
    #region DetailedCollections

    #endregion

    #region AggregateCollections

    #endregion
    //public class VectorDiagnosisItem
    //{
    //    public long? idfsVSSessionSummaryDiagnosis { get; set; }
    //    public long? idfsVSSessionSummary { get; set; }
    //    public long? idfsDiagnosis { get; set; }
    //    public int intPositiveQuantity { get; set; }
    //    public Guid? rowguid { get; set; }
    //    public int intRowStatus { get; set; }
    //    public string RowAction { get; set; }
    //}
}
