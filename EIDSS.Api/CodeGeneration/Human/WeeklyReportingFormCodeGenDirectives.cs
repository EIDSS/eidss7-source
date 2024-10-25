using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetWeeklyReportingFormList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.WeeklyReportingFormController; 
        public Type APIReturnType  => typeof(List<ReportFormViewModel>); 
        public string MethodParameters => "WeeklyReportingFormGetRequestModel request, CancellationToken cancellationToken = default"; 
        public APIMethodVerbEnumeration MethodVerb  => APIMethodVerbEnumeration.GET_USING_POST_VERB; 
        public Type RepositoryReturnType  => typeof(List<USP_GBL_ReportForm_GetListResult>); 
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class SaveWeeklyReportingForm : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.WeeklyReportingFormController;
        public Type APIReturnType => typeof(WeeklyReportSaveResponseModel);
        public string MethodParameters => "WeeklyReportSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;
        public Type RepositoryReturnType => typeof(USP_GBL_ReportForm_SETResult);
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetWeeklyReportingFormDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.WeeklyReportingFormController;
        public Type APIReturnType => typeof(List<ReportFormDetailViewModel>);
        public string MethodParameters => "WeeklyReportingFormGetDetailRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_GBL_ReportForm_GETDETAILResult>);
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DeleteWeeklyReportingFormDetail : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.WeeklyReportingFormController;
        public Type APIReturnType => typeof(APIPostResponseModel);
        public string MethodParameters => "long idfReportForm, string auditUser, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.DELETE;
        public Type RepositoryReturnType => typeof(USP_GBL_ReportForm_DELETEResult);
        public string APIGroupName => "Human";
        public string SummaryInfo => "Delete Weekly Report";
    }
}
