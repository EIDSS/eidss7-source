using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetTestNameTestResultsMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.TestNameTestResultsMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<TestNameTestResultsMatrixViewModel>);

        public string MethodParameters => "TestNameTestResultsMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_TESTTOTESTRESULTMATRIX_GETLISTResult>);

        public string SummaryInfo => "Gets the Test Name Test Results Matrix";
    }

    public class DeleteTestNameTestResultsMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.TestNameTestResultsMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "TestNameTestResultsMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_TESTTOTESTRESULTMATRIX_DELResult);

        public string SummaryInfo => "Deletes a Test Name Test Results matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class SaveTestNameTestResultsMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.TestNameTestResultsMatrixController; }

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "TestNameTestResultsMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_TESTTOTESTRESULTMATRIX_SETResult); }
        public string SummaryInfo => "Adds a new record for Vector Type Collection Method";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

}
