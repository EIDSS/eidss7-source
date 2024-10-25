using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    /// <summary>
    /// Page view model used to support the DiseaseReportSample Blazor Component
    /// Use this page view model to push data to the component while populating the view
    /// model from your specific domain view model like Human, Vet, etc.
    /// </summary>
    public class DiseaseReportSamplePageViewModel
    {
        public long? SamplesCollectedYN { get; set; }

        public long? idfHumanCase { get; set; }

        public string? Reason { get; set; }

        public long? ReasonID { get; set; }
        public List<DiseaseReportSamplePageSampleDetailViewModel> SamplesDetails { get; set; }

        public List<DiseaseReportSamplePageSampleDetailViewModel> ActiveSamplesDetails { get; set; }
        public List<BaseReferenceViewModel> YesNoChoices { get; set; }
        public List<BaseReferenceEditorsViewModel> SampleTypes { get; set; }
        public List<OrganizationGetListViewModel> CollectedByOrganizations { get; set; }
        public List<OrganizationGetListViewModel> SentToOrganizations { get; set; }
        public UserPermissions Permissions { get; set; }

        public DiseaseReportSamplePageSampleDetailViewModel AddSampleModel { get; set; }

        public long? idfDisease { get; set; }

        public string? strDisease { get; set; }

        [IsValidDate]
        public DateTime? SymptomsOnsetDate { get; set; }

        public string LocalSampleID {get;set;}

        public string strCaseId { get; set; }

        public bool IsReportClosed { get; set; } = false;



    }

    /// <summary>
    /// Detail of samples for the samples grid. 
    /// Map your specifc domain model to this generic Blazor Component to 
    /// populate the samples grid for Human, Vet, etc.
    /// </summary>
    public class DiseaseReportSamplePageSampleDetailViewModel
    {
        public int RowID { get; set; }

        public long? idfMaterial { get; set; }

        public int RowAction { get; set; }

        public long NewRecordId { get; set; }

       // public long? ID { get; set; }
        public long SampleKey { get; set; }
        public string? LabSampleID { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleType { get; set; }
        public string SampleStatus { get; set; }

        public string strNote { get; set; }
        public string FunctionalLab { get; set; }
        public string AdditionalTestNotes { get; set; }
        public bool? FilterSampleByDisease { get; set; } = false;
        public string LocalSampleId { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public string CollectedByOrganization { get; set; }
        public long? CollectedByOfficerID { get; set; }
        public string CollectedByOfficer { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganization { get; set; }
        public DateTime? AccessionDate { get; set; }
        public string SampleConditionRecieved { get; set; }

        public long? idfDisease { get; set; }

        public string? strDisease { get; set; }

        public string sampleGuid { get; set; }

        [IsValidDate]
        public DateTime? SymptomsOnsetDate { get; set; }
        [IsValidDate]
        public DateTime? OutbreakSymptomsOnsetDate { get; set; }

        public string TempLocalSampleID { get; set; }

        public string strBarcode { get; set; }
        public string strFieldBarcode { get; set; }


        public bool? blnAccessioned { get; set; }

        public int intRowStatus { get; set; }

        public int blnNumberingSchema { get; set; } = 0;

        public long? idfsSiteSentToOrg { get; set; }

        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }

        public long idfHumanCase { get; set; }

        public bool Selected { get; set; }

    }

    public class HACodesViewModel : BaseModel
    {
        public int? intHACode { get; set; }
        public string CodeName { get; set; }
        public int intRowStatus { get; set; }

    }

}
