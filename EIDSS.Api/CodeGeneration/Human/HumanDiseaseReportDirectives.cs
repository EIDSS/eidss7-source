using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetHumanDiseaseReportListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<HumanDiseaseReportViewModel>); }
        public string MethodParameters { get => "HumanDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_REPORT_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetHumanDiseaseReportDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.Human.HumanDiseaseReportDetailViewModel>); }
        public string MethodParameters { get => "HumanDiseaseReportDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_GETDetailResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }


    public class GetHumanDiseaseReportPersonInfoAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportPersonalInformationViewModel>); }
        public string MethodParameters { get => "HumanPersonDetailsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_HUMAN_MASTER_GETDetailResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }
    public class GetHumanDiseaseReportFromHumanIDAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportPersonalInformationViewModel>); }
        public string MethodParameters { get => "HumanPersonDetailsFromHumanIDRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_HUMAN_MASTER_GETDetail_FROM_HUMAN_IDResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class GetAntiviralTherapisListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportAntiviralTherapiesViewModel>); }
        public string MethodParameters { get => "HumanAntiviralTherapiesAndVaccinationRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_ANTIVIRALTHERAPIES_GetListResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }
    public class GetHumanDiseaseReportVaccinationListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportVaccinationViewModel>); }
        public string MethodParameters { get => "HumanAntiviralTherapiesAndVaccinationRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_VACCINATIONS_GetListResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class GetSamplesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<HumanDiseaseReportSamplesViewModel>); }
        public string MethodParameters { get => "HumanDiseaseReportSamplesRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_SAMPLES_GetList_With_DerivatesResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }
    public class GetSamplesForDiseaseListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportSampleForDiseasesViewModel>); }
        public string MethodParameters { get => "HumanSampleForDiseasesRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_GBL_LKUP_SAMPLESFORDISEASESResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class GetHumanDiseaseReportTestListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportTestDetailForDiseasesViewModel>); }
        public string MethodParameters { get => "HumanTestListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_TESTS_GetListResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class GetHumanDiseaseLabTestMatrixByDiseaseGetListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportTestNameForDiseasesViewModel>); }
        public string MethodParameters { get => "HumanTestNameForDiseasesRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUMAN_DISEASELABTESTMATRIX_BY_DISEASE_GETLISTResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class SetHumanDiseaseReportAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<SetHumanDiseaseReportResponseModel>); }
        public string MethodParameters { get => "HumanSetDiseaseReportRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_HUMAN_DISEASE_SETResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class GetHumanDiseaseReportContactListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportContactDetailsViewModel>); }
        public string MethodParameters { get => "HumanDiseaseContactListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_CONTACTS_GetListResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class DeleteHumanDiseaseReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfHumanCase, long? idfUserID, long? idfSiteId, bool? DeduplicationIndicator, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_HUM_HUMAN_DISEASE_DELResult); }

        public string APIGroupName => "Human Disease Report";

        public string SummaryInfo => "Delete Disease Report";

    }

    public class UpdateHumanDiseaseInvestigatedByAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "HumanSetDiseaseReportRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_HUM_HUMAN_DISEASE_INVESTIGATEDBY_UPDATEResult); } 
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "Updates 'Investigated By' field in Human Disease Report (used by the Notifications Grid in the Dashboard)";

    }

    public class GetHumanDiseaseReportLkupCaseClassificationAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<HumanDiseaseReportLkupCaseClassificationResponseModel>); }
        public string MethodParameters { get => "HumanDiseaseReportLkupCaseClassificationRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_REF_LKUP_CASECLASSIFICATIONResult>); }
        public string APIGroupName => "Human Disease Report";
        public string SummaryInfo => "";
    }

    public class DedupeHumanDiseaseReportRecords : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }

        public Type APIReturnType { get => typeof(HumanDiseaseReportDedupeResponseModel); }

        public string MethodParameters { get => "HumanDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_HUMAN_DISEASE_Report_SETResult); }

        public string APIGroupName => "Human Disease Report";

        public string SummaryInfo => "Deduplicate Human Disease Report Records";
    }

    public class GetHumanDiseaseReportDetailPermissions : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.CrossCutting.RecordPermissionsViewModel>); }
        public string MethodParameters { get => "RecordPermissionsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HUM_DISEASE_REPORT_PERMISSION_GETDetailResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
}
