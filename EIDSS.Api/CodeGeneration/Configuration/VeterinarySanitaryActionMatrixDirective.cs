using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetVeterinarySanitaryActionMatrixReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinarySanitaryActionMatrixController; }
        public Type APIReturnType { get => typeof(List<VeterinarySanitaryActionMatrixViewModel>); }
        public string MethodParameters { get => "string LangID, long idfVersion, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Veterinary Sanitary Action Report Matrix";        
    }

    public class GetVeterinarySanitaryActionTypes : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinarySanitaryActionMatrixController; }
        public Type APIReturnType { get => typeof(List<InvestigationTypeViewModel>); }
        public string MethodParameters { get => "long idfsBaseReference, long intHACode, string strLanguageID, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_GetSanitaryActions_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Veterinary Sanitary Action Types";
    }

    public class SaveVeterinarySanitaryActionMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinarySanitaryActionMatrixController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_VeterinarySanitaryActionMatrixReport_SETResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Save Veterinary Sanitary Action Report Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteVeterinarySanitaryActionMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinarySanitaryActionMatrixController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_SanitaryMatrixReportRecord_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Delete Veterinary Sanitary Action Report Matrix Record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}
