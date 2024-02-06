using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Vector
{
    public class VectorCollectionSamplesLabsDetailModel
    {
        public bool IsSampleModel { get; set; }
        public bool IsFieldTestModel { get; set; }
        public long? idfVector { get; set; }
        public long? idfVectorType { get; set; }
        public string strVectorType { get; set; }
        public string strSpecies { get; set; }
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

        public long? idfsEctoparASitesCollected { get; set; }
        public string strComment { get; set; }

        public long? idfsSpecies { get; set; }
        public string PoolVectorId { get; set; }
        public long VectorSessionId { get; set; }
        public string SessionID { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }
        public string PoolFieldVectorId { get; set; }
        public String DialogName { get; set; }
        //Samples
        public ViewModels.Vector.Samples Samples { get { return _samples; } set { _samples = value; } }
        private ViewModels.Vector.Samples _samples;

        //public List<ViewModels.Vector.Samples> SamplesList { get { return _samplesList; } set { _samplesList = value; } }
        //private List<ViewModels.Vector.Samples> _samplesList;

        public List<USP_VCTS_SAMPLE_GetListResponseModels> SamplesList { get { return _samplesList; } set { _samplesList = value; } }
        private List<USP_VCTS_SAMPLE_GetListResponseModels> _samplesList;
        public List<USP_VCTS_SAMPLE_GetListResponseModels> EditedSamplesList { get { return _editedSamplesList; } set { _editedSamplesList = value; } }
        private List<USP_VCTS_SAMPLE_GetListResponseModels> _editedSamplesList;

        public List<USP_VCTS_FIELDTEST_GetListResponseModel> FieldTestResponseModelList { get { return _fieldTestResponseModelList; } set { _fieldTestResponseModelList = value; } }
        private List<USP_VCTS_FIELDTEST_GetListResponseModel> _fieldTestResponseModelList;

        public List<USP_VCTS_FIELDTEST_GetListResponseModel> EditedFieldTestResponseModelList { get { return _editeFieldTestResponseModelList; } set { _editeFieldTestResponseModelList = value; } }
        private List<USP_VCTS_FIELDTEST_GetListResponseModel> _editeFieldTestResponseModelList;
        //Location
        List<FieldTest> _fieldTest;
        public List<FieldTest> FieldTestList { get { return _fieldTest; } set { _fieldTest = value; } }



        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;

        public List<BaseReferenceEditorsViewModel> SpeciesList { get; set; }

        public List<VectorTypeSampleTypeMatrixViewModel> SampleTypeMatrixList;

        public USP_VCTS_VECTCollection_GetDetailResponseModel _vectorCollectionDetailResponseModel { get; set; }
        public USP_VCTS_VECTCollection_GetDetailResponseModel vectorCollectionDetailResponseModel { get { return _vectorCollectionDetailResponseModel; } set { _vectorCollectionDetailResponseModel = value; } }

        List<USP_VCTS_VECT_GetDetailResponseModel> _hostVectorRecords = new List<USP_VCTS_VECT_GetDetailResponseModel>();
        public List<USP_VCTS_VECT_GetDetailResponseModel> hostVectorRecords { get { return _hostVectorRecords; } set { _hostVectorRecords = value; } }


        public long? gislocationType { get; set; }

        //Flex FOrm
     
        public FlexFormQuestionnaireGetRequestModel FlexFormRequest { get; set; }


        public VectorCollectionSamplesLabsDetailModel()
        {
            _samples = new Samples();
            //_samplesList = new List<USP_VCTS_SAMPLE_GetListResponseModels>();
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
            _vectorCollectionDetailResponseModel = new USP_VCTS_VECTCollection_GetDetailResponseModel();
            _hostVectorRecords = new List<USP_VCTS_VECT_GetDetailResponseModel>();
           // _fieldTestResponseModelList = new List<USP_VCTS_FIELDTEST_GetListResponseModel>();
            _fieldTest = new List<FieldTest>();
            _editeFieldTestResponseModelList = new List<USP_VCTS_FIELDTEST_GetListResponseModel>();
            _editedSamplesList = new List<USP_VCTS_SAMPLE_GetListResponseModels>();
        }

        //Field Test
        public List<ItemKPV> SampleIDList { get; set; }
        public List<ItemKPV> FieldTestIDList { get; set; }
        public USP_VCTS_FIELDTEST_GetListResponseModel FieldTestItem { get; set; }
        public string SampleType { get; set; }
        public DateTime? CollectionDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public List<BaseReferenceEditorsViewModel> TestName { get; set; }
        public List<BaseReferenceTypeListViewModel> TestCategory { get; set; }
        public List<OrganizationGetListViewModel> TestedByInstitution { get; set; }
        public List<EmployeeListViewModel> TestedByPerson { get; set; }
        public List<TestNameTestResultsMatrixViewModel> TestResult { get; set; }
        public List<BaseReferenceEditorsViewModel> Disease { get; set; }

        public List<ConfigurationMatrixViewModel> configurationMatrixViewModels { get; set; }


        public long SelectedSampleFieldId { get; set; }
        public string SelectedSampleFieldIdName { get; set; }
        public long SelectedTest { get; set; }
        public string SelectedTestName { get; set; }
        public long SelectedDisease { get; set; }
        public string SelectedDiseaseName { get; set; }
        public long SelectedTestedByPerson { get; set; }
        public string SelectedTestedByPersonName { get; set; }
        public long SelectedTestedByInstitution { get; set; }
        public string SelectedTestedByInstitutionName { get; set; }
        public long SelectedTestCategory { get; set; }
        public string SelectedTestCategoryName { get; set; }
        public long SelectedTestResult { get; set; }
        public string SelectedTestResultName { get; set; }

        public long SelectdSampleTypeId { get; set; }
        public string SelectdSampleTypeName { get; set; }
        public long idfTesting { get; set; }
      
        public class ItemKPV
        {
            public string ItemText { get; set; }
            public long ItemVal { get; set; }
        }


        public class FieldTest
        {
            public long idfTesting { get; set; }
            public string strFieldBarcode { get; set; }
            public long idfMaterial { get; set; }
            public long idfsSampleType { get; set; }
            public string SampleType { get; set; }
            public long idfSpecies { get; set; }
            public string Species { get; set; }
            public string strAnimalCode { get; set; }
            public long idfsTestName { get; set; }
            public string TestName { get; set; }
            public long idfsTestResult { get; set; }
            public string Result { get; set; }
            public DateTime? ResultDate { get; set; }
            public long idfsTestCategory { get; set; }
            public long idfTestedByPerson { get; set; }
            public long idfTestedByInstitution { get; set; }

            public long idfsDiagnosis { get; set; }
            public int intRowStatus { get; set; }
            public string RowAction { get; set; }

            public string DiagnosisName { get; set; }

        }
    }
}
