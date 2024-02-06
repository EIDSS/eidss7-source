using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;

namespace EIDSS.Web.ViewModels.Vector
{
    public class VectorSurveillancePageViewModel
    {

        #region Page Level Properties

        public string PageHeader { get; set; }
        public string SummaryHeader { get; set; }
        public long? idfsVSSessionSummary { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string RecordID { get; set; }
        public bool IsReadOnly { get; set; }
        public bool AddToOutbreakIndicator { get; set; }

        #endregion

        #region Location Properties
        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;
        public string LocationDescription { get; set; }
        public long? LocationDistance { get; set; }
        public long? LocationDirection { get; set; }
        public long? gislocationType { get; set; }
        public bool ShowCountry { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }
        public long? savedIdfGeoLocation { get; set; }
        public string LocationAddress { get; set; }
        public EIDSS.Domain.RequestModels.FlexForm.FlexFormQuestionnaireGetRequestModel flexFormModel { get; set; }
        #endregion

        #region Samples
        private ViewModels.Vector.Samples _samples;
        public ViewModels.Vector.Samples Samples { get { return _samples; } set { _samples = value; } }
        #endregion
      
        #region Vector Session Properties
        
        public int InvalidSection { get; set; }
        public long idfVector { get; set; }
        public string SessionID { get; set; }
        public string FieldSessionID { get; set; }
        public long? OutbreakKey { get; set; }
        public string OutbreakID { get; set; }
        public List<KeyValuePair<string, string>> Status { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? CloseDate { get; set; }
        public long VectorSessionId { get; set; }
        public string Description { get; set; }
        public string VectorTypes { get; set; }
        public long? VectorTypeID { get; set; }
        public string Diseases { get; set; }
        public long? DiseaseID { get; set; }
        public long? StatusID { get; set; }
        public int? CollectionEffort { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public long? savedIdfVectorSurveillanceSession { get; set; }
        #endregion

        #region Aggregate Collection 

        //Diagnosis
        private List<VectorDiagnosisItem> _vectorDiagnosisItems;
        public string strSelectedDiagnosis { get; set; }
        public List<VectorDiagnosisItem> vectorDiagnosisItems { get { return _vectorDiagnosisItems; } set { _vectorDiagnosisItems = value; } }
        #endregion


        #region Detailed Collections

        #endregion


        #region Set Request Model Properties
        private USP_VCTS_SESSIONSUMMARY_SETRequestModel _request;
        public USP_VCTS_SESSIONSUMMARY_SETRequestModel request { get { return _request; } set { _request = value; } }

        #endregion

        #region Get  Request Model Properties
        public List<USP_VCTS_VECT_GetDetailResponseModel> DetailedCollectionsList { get; set; }
        #endregion

        public VectorSurveillancePageViewModel()
        {
            _samples = new Samples();
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
            _vectorDiagnosisItems = new List<VectorDiagnosisItem>();
            _request = new USP_VCTS_SESSIONSUMMARY_SETRequestModel();
        }

        public static implicit operator VectorSurveillancePageViewModel(ProtectedBrowserStorageResult<VectorSurveillancePageViewModel> v)
        {
            throw new NotImplementedException();
        }
    }

    public class VectorDiagnosisItem
    {
        public long? idfsVSSessionSummaryDiagnosis { get; set; }
        public long? idfsVSSessionSummary { get; set; }
        public long? idfsDiagnosis { get; set; }
        public int intPositiveQuantity { get; set; }
        public Guid? rowguid { get; set; }
        public int intRowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
