using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Configuration
{

    public class GetVeterinaryProphylacticMeasureMatrixReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryProphylacticMeasureMatrixController; }
        public Type APIReturnType { get => typeof(List<VeterinaryProphylacticMeasureMatrixViewModel>); }
        public string MethodParameters { get => "VeterinaryProphylacticMeasureMatrixGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_ADMIN_ProphylacticMatrixReportGet_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Veterinary Prophylactic Measure Report Matrix";
    }

    public class GetVeterinaryProphylacticMeasureTypes : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryProphylacticMeasureMatrixController; }
        public Type APIReturnType { get => typeof(List<InvestigationTypeViewModel>); }
        public string MethodParameters { get => "long idfsBaseReference, long intHACode, string strLanguageID, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_GetProphylacticMeasures_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Veterinary Prophylactic Measure Types";
    }

    public class SaveVeterinaryProphylacticMeasureMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryProphylacticMeasureMatrixController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_VeterinaryProphylacticMatrixReport_SETResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Save Veterinary Prophylactic Measure Report Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteVeterinaryProphylacticMeasureMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryProphylacticMeasureMatrixController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_ProphylacticMatrixReportRecord_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Delete Veterinary Prophylactic Measure Report Matrix Record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}
