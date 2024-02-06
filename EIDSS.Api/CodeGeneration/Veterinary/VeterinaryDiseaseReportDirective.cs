using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Veterinary;


namespace EIDSS.Api.CodeGeneration.Veterinary
{
    public class GetVeterinaryDiseaseReportListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<VeterinaryDiseaseReportViewModel>); }
        public string MethodParameters { get => "VeterinaryDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_DISEASE_REPORT_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "";
    }

    public class GetDiseaseReportDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<DiseaseReportGetDetailViewModel>); }
        public string MethodParameters { get => "DiseaseReportGetDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_DISEASE_REPORT_GETDetailResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a specific veterinary disease report record.";
    }

    public class GetFarmInventoryListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<FarmInventoryGetListViewModel>); }
        public string MethodParameters { get => "FarmInventoryGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_FARM_INVENTORY_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of farm, flock or herds and species records in a hierarchical manner for a specific disease report.";
    }

    public class GetAnimalListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<AnimalGetListViewModel>); }
        public string MethodParameters { get => "AnimalGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_ANIMAL_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of animal records for a specific livestock disease report.";
    }

    public class GetVaccinationListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<VaccinationGetListViewModel>); }
        public string MethodParameters { get => "VaccinationGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_VACCINATION_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of vaccination records for a specific disease report.";
    }

    public class GetSampleListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<SampleGetListViewModel>); }
        public string MethodParameters { get => "SampleGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_SAMPLE_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of sample records for a specific disease report.";
    }

    public class GetImportSampleListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<SampleGetListViewModel>); }
        public string MethodParameters { get => "ImportSampleGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_GBL_SAMPLE_IMPORT_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of sample records for import to a specific disease report.";
    }

    public class GetPensideTestListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<PensideTestGetListViewModel>); }
        public string MethodParameters { get => "PensideTestGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_PENSIDE_TEST_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of penside test records for a specific disease report.";
    }

    public class GetLaboratoryTestListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<LaboratoryTestGetListViewModel>); }
        public string MethodParameters { get => "LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_TEST_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of laboratory test records for a specific disease report.";
    }

    public class GetLaboratoryTestInterpretationListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<LaboratoryTestInterpretationGetListViewModel>); }
        public string MethodParameters { get => "LaboratoryTestInterpretationGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_GBL_TEST_INTERPRETATION_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of laboratory test interpretation records for a specific disease report.";
    }

    public class GetCaseLogListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(List<CaseLogGetListViewModel>); }
        public string MethodParameters { get => "CaseLogGetListRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_VET_CASE_LOG_GETListResult>); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Returns a list of case log records for a specific disease report.";
    }

    public class SaveDiseaseReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(DiseaseReportSaveRequestResponseModel); }
        public string MethodParameters { get => "DiseaseReportSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_VET_DISEASE_REPORT_SETResult); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Save disease report information";
    }

    public class DeleteDiseaseReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long diseaseReportID, bool deduplicationIndicator, long? dataAuditEventTypeID, string auditUserName, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_VET_DISEASE_REPORT_DELResult); }
        public string APIGroupName => "Veterinary Disease Report";
        public string SummaryInfo => "Delete a veterinary disease report";
    }

    public class DedupeVeterinaryDiseaseReportRecords : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryDiseaseReportController; }

        public Type APIReturnType { get => typeof(VeterinaryDiseaseReportDedupeResponseModel); }

        public string MethodParameters { get => "VeterinaryDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_VET_DISEASE_Report_SETResult); }

        public string APIGroupName => "Veterinary Disease Report";

        public string SummaryInfo => "Deduplicate Veterinary Disease Report Records";
    }
}