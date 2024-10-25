using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Human
{
    /// <summary>
    /// Page view model used to support the DiseaseReportSample Blazor Component
    /// Use this page view model to push data to the component while populating the view
    /// model from your specific domain view model like Human, Vet, etc.
    /// </summary>
    public class DiseaseReportTestPageViewModel
    {

        public List<BaseReferenceViewModel> YesNoChoices { get; set; }
        public long? TestsConducted { get; set; }

        public List<DiseaseReportTestDetailForDiseasesViewModel> TestDetails { get; set; } = [];
        public List<DiseaseReportTestDetailForDiseasesViewModel> TestDetailsForGrid { get; set; } = [];

        //Additional Fields From Other Page
        public long? idfHumanCase { get; set; }

        public long idfsSite { get; set; }

        public long? idfDisease { get; set; }

        public string? strDisease { get; set; }

        public string LocalSampleID { get; set; }

        public string strCaseId { get; set; }


        public List<DiseaseReportSamplePageSampleDetailViewModel> SamplesDetails { get; set; }

        public UserPermissions Permissions { get; set; }

        public DiseaseReportTestPageTestDetailViewModel AddTestModel { get; set; }



        public bool IsReportClosed { get; set; } = false;

        public List<EventSaveRequestModel> Events { get; set; } = new List<EventSaveRequestModel>();

        public bool TestsLoaded { get; set; } = false;
        //[IsValidDate]
        //  public DateTime? SymptomsOnsetDate { get; set; }





    }

    /// <summary>
    /// Detail of Test for the Tests grid. 
    /// Map your specifc domain model to this generic Blazor Component to 
    /// populate the Test grid for Human, Vet, etc.
    /// </summary>
    public class DiseaseReportTestPageTestDetailViewModel
    {
        public int RowID { get; set; }
        public long? idfHumanCase { get; set; }
        public long idfMaterial { get; set; }
        public string strBarcode { get; set; }
        public string strFieldBarcode { get; set; }
        public long idfsSampleType { get; set; }
        public string strSampleTypeName { get; set; }
        public DateTime? datFieldCollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public long? idfFieldCollectedByOffice { get; set; }
        public DateTime? datFieldSentDate { get; set; }
        public long? idfsSampleStatus { get; set; }
        public string SampleStatusTypeName { get; set; }
        public long? idfFieldCollectedByPerson { get; set; }
        public DateTime? datSampleStatusDate { get; set; }
        public Guid sampleGuid { get; set; }
        public long? idfTesting { get; set; }
        public long? idfsTestName { get; set; }
        public long? idfsTestCategory { get; set; }
        public string strTestCategory { get; set; }
        public long? idfsTestResult { get; set; }
        public long? idfsTestStatus { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDiagnosis { get; set; }
        public string strTestStatus { get; set; }
        public string strTestResult { get; set; }
        public string name { get; set; }
        public DateTime? datReceivedDate { get; set; }
        public DateTime? datConcludedDate { get; set; }
        public long? idfTestedByPerson { get; set; }
        public long? idfTestedByOffice { get; set; }
        public DateTime datInterpretedDate { get; set; }
        public long? idfsInterpretedStatus { get; set; }
        public string strInterpretedComment { get; set; }
        public string strInterpretedBy { get; set; }
        public DateTime datValidationDate { get; set; }
        public bool blnValidateStatus { get; set; }
        public string strValidateComment { get; set; }
        public string strValidatedBy { get; set; }
        public Guid? testGuid { get; set; }
        public int? intRowStatus { get; set; }
        public string strTestedByPerson { get; set; }
        public string strTestedByOffice { get; set; }
        public bool blnNonLaboratoryTest { get; set; }
        public long? idfInterpretedByPerson { get; set; }
        public long? idfValidatedByPerson { get; set; }

        
    }

    //public class HACodesViewModel : BaseModel
    //{
    //    public int? intHACode { get; set; }
    //    public string CodeName { get; set; }
    //    public int intRowStatus { get; set; }

    //}

}
