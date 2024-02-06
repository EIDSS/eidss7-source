using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;

namespace EIDSS.Api.Controllers
{
    /// <summary>
    /// </summary>
    [Route("api/Configuration")]
    public partial class ConfigurationController : EIDSSControllerBase
    {
        /// <summary>
        ///     Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        public ConfigurationController(IDataRepository repository, IMemoryCache memoryCache) : base(repository,
            memoryCache)
        {
        }

        /// <summary>
        ///     Retrieves a list of human aggregate disease report matrices
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetHumanDiseaseMatrixList")]
        [ProducesResponseType(typeof(List<HumanDiseaseMatrixListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<HumanDiseaseMatrixListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<HumanDiseaseMatrixListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of human diseases", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetHumanDiseaseMatrixListAsync(long? usingType, long? intHACode,
            string strLanguageID, CancellationToken cancellationToken = default)
        {
            List<HumanDiseaseMatrixListViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {usingType, intHACode, strLanguageID, null, cancellationToken},
                    MappedReturnType = typeof(List<HumanDiseaseMatrixListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_DISEASE_MTX_GETResult>)
                };

                results = await _repository.Get(args) as List<HumanDiseaseMatrixListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Retrieves a list of human disease diagnosis
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetHumanDiseaseDiagnosisMatrixList")]
        [ProducesResponseType(typeof(List<HumanDiseaseDiagnosisListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<HumanDiseaseDiagnosisListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<HumanDiseaseDiagnosisListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of human disease diagnosis",
            Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetHumanDiseaseDiagnosisMatrixListAsync(long? usingType, long? intHACode,
            string strLanguageID, CancellationToken cancellationToken = default)
        {
            List<HumanDiseaseDiagnosisListViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {usingType, intHACode, strLanguageID, null, cancellationToken},
                    MappedReturnType = typeof(List<HumanDiseaseDiagnosisListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult>)
                };

                results = await _repository.Get(args) as List<HumanDiseaseDiagnosisListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #region Veterinary Diagnostic Investigation Matrix

        /// <summary>
        ///     Retrieves a list of matrix versions by type
        /// </summary>
        /// <returns></returns>
        [HttpPost("GetVeterinaryDiagnosticInvestigationMatrixReport")]
        [ProducesResponseType(typeof(List<VeterinaryDiagnosticInvestigationMatrixReportModel>),
            StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<VeterinaryDiagnosticInvestigationMatrixReportModel>),
            StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<VeterinaryDiagnosticInvestigationMatrixReportModel>),
            StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of veterinary diagnostic investigations",
            Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetVeterinaryDiagnosticInvestigationMatrixReport(
            [FromBody] MatrixGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<VeterinaryDiagnosticInvestigationMatrixReportModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.MatrixId,
                        request.LanguageId,
                        request.Page,
                        request.PageSize,
                        request.SortColumn,
                        request.SortOrder,
                        null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<VeterinaryDiagnosticInvestigationMatrixReportModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GETResult>)
                };

                results = await _repository.Get(args) as List<VeterinaryDiagnosticInvestigationMatrixReportModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }


        /// <summary>
        ///     Retrieves a list of veterinary diseases
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetVeterinaryDiseaseMatrixList")]
        [ProducesResponseType(typeof(List<VeterinaryDiseaseMatrixListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<VeterinaryDiseaseMatrixListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<VeterinaryDiseaseMatrixListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a veterinary disease matrix list", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetVeterinaryDiseaseMatrixListAsync(long? idfsBaseReference, long? intHACode,
            string strLanguageID, CancellationToken cancellationToken = default)
        {
            List<VeterinaryDiseaseMatrixListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {idfsBaseReference, intHACode, strLanguageID, null, cancellationToken},
                    MappedReturnType = typeof(List<VeterinaryDiseaseMatrixListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_GetVetDiseaseList_GETResult>)
                };

                results = await _repository.Get(args) as List<VeterinaryDiseaseMatrixListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpPost("SaveVeterinaryDiagnosticInvestigationMatrix")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Saves an aggregate diagnostic action matrix report",
            Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> SaveVeterinaryDiagnosticInvestigationMatrix([FromBody] MatrixViewModel model,
            CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APISaveResponseModel
                results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        model.IdfAggrDiagnosticActionMTX, model.IdfVersion, model.InJsonString, model.EventTypeId,
                        model.SiteId, model.UserId, model.LocationId, model.User, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType =
                        typeof(List<USP_CONF_VeterinaryDiagnosticInvestigationMatrixReport_SETResult>)
                };

                // Forwards the call to context method:  

                if (await _repository.Get(args) is List<APISaveResponseModel> {Count: > 0} @_)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion

        #region Species Animal Age

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetSpeciesAnimalAgeList")]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Get a species animal age list", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetSpeciesAnimalAgeListAsync([FromBody] SpeciesAnimalAgeGetRequestModel request,
            CancellationToken cancellationToken)
        {
            List<ConfigurationMatrixViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.LanguageId, request.idfsSpeciesType, request.Page, request.PageSize, request.SortColumn,
                        request.SortOrder, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<ConfigurationMatrixViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<ConfigurationMatrixViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Save a Species Animal Age
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveSpeciesAnimalAge")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Save a species animal age", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> SaveSpeciesAnimalAge([FromBody] SpeciesAnimalAgeSaveRequestModel request,
            CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfSpeciesTypeToAnimalAge, request.idfsSpeciesType, request.idfsAnimalAge,
                        request.EventTypeId, request.SiteId, request.UserId, request.LocationId, request.User, null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SETResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SETResult[]> USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SETAsync(long? idfSpeciesTypeToAnimalAge, long? idfsSpeciesType, long? idfsAnimalAge, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)

                if (await _repository.Get(args) is List<APISaveResponseModel> {Count: > 0} @_)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Delete a Species Animal Age
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("DeleteSpeciesAnimalAge")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Delete a species animal age", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> DeleteSpeciesAnimalAge([FromBody] SpeciesAnimalAgeSaveRequestModel request,
            CancellationToken cancellationToken = default)
        {
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {request.idfSpeciesTypeToAnimalAge, request.DeleteAnyway,
                        request.EventTypeId, request.SiteId, request.UserId, request.LocationId, request.User, null, cancellationToken},
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DELResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DELResult[]> USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DELAsync(long? idfSpeciesTypeToAnimalAge, bool? deleteAnyway, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)

                if (await _repository.Get(args) is List<APIPostResponseModel> {Count: > 0} @_)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion

        #region Sample Type Derivative Type Matrix

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetSampleTypeDerivativeMatrixList")]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a sample type derivative list", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetSampleTypeDerivativeMatrixListAsync(
            [FromBody] SampleTypeDerivativeMatrixGetRequestModel request, CancellationToken cancellationToken)
        {
            List<ConfigurationMatrixViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.LanguageId, request.idfsSampleType, request.Page, request.PageSize, request.SortColumn,
                        request.SortOrder, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<ConfigurationMatrixViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<ConfigurationMatrixViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Save a Sample Type Derivative Type Matrix
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveSampleTypeDerivativeMatrix")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "Save a sample type derivative", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> SaveSampleTypeDerivativeMatrix(
            [FromBody] SampleTypeDerivativeMatrixSaveRequestModel request,
            CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfDerivativeForSampleType, request.idfsSampleType, request.idfsDerivativeType,
                        request.EventTypeId, request.SiteId, request.UserId, request.LocationId, request.User, null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SETResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SETResult[]> USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SETAsync(long? idfDerivativeForSampleType, long? idfsSampleType, long? idfsDerivativeType, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
                var _ = await _repository.Get(args) as List<APISaveResponseModel>;

                if (_ is {Count: > 0})
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Delete a Sample Type Derivative Type Matrix
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("DeleteSampleTypeDerivativeMatrix")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "Delete a sample type", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> DeleteSampleTypeDerivativeMatrix(
            [FromBody] SampleTypeDerivativeMatrixSaveRequestModel request,
            CancellationToken cancellationToken = default)
        {
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfDerivativeForSampleType, request.deleteAnyway, request.EventTypeId, request.SiteId, request.UserId,
                        request.LocationId, request.User, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DELResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DELResult[]> USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DELAsync(long? idfDerivativeForSampleType, bool? deleteAnyway, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
                var _ = await _repository.Get(args) as List<APIPostResponseModel>;

                if (_ is {Count: > 0})
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion

        #region Custom Report Rows Matrix

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetCustomReportRowsMatrixList")]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get custom report rows", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetCustomReportRowsMatrixListAsync(
            [FromBody] CustomReportRowsMatrixGetRequestModel request, CancellationToken cancellationToken)
        {
            List<ConfigurationMatrixViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.LanguageId, request.idfsCustomReportType, request.Page, request.PageSize,
                        request.SortColumn, request.SortOrder, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<ConfigurationMatrixViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_CUSTOMREPORT_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<ConfigurationMatrixViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Save a Custom Report Rows Matrix
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveCustomReportRowsMatrix")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Save custom report rows", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> SaveCustomReportRowsMatrix(
            [FromBody] CustomReportRowsMatrixSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfReportRows, request.idfsCustomReportType,
                        request.idfsDiagnosisOrReportDiagnosisGroup, request.idfsReportAdditionalText,
                        request.idfsICDReportAdditionalText, request.intRowOrder, request.EventTypeId, request.SiteId,
                        request.UserId, request.LocationId, request.User, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_CUSTOMREPORT_SETResult>)
                };

                // Forwards the call to context method:   Task<USP_CONF_CUSTOMREPORT_SETResult[]> USP_CONF_CUSTOMREPORT_SETAsync(long? idfReportRows, long? idfsCustomReportType, long? idfsDiagnosisOrReportDiagnosisGroup, long? idfsReportAdditionalText, long? idfsICDReportAdditionalText, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
                var _ = await _repository.Get(args) as List<APISaveResponseModel>;

                if (_ is {Count: > 0})
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Delete a Custom Report Rows Matrix
        /// </summary>
        /// <param name="idfReportRows"></param>
        /// <param name="deleteAnyway"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpDelete("DeleteCustomReportRowsMatrix")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Delete custom report rows", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> DeleteCustomReportRowsMatrix(long idfReportRows, bool? deleteAnyway,
            CancellationToken cancellationToken = default)
        {
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {idfReportRows, deleteAnyway, null, cancellationToken},
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_CUSTOMREPORT_DELResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_CUSTOMREPORT_DELResult[]> USP_CONF_CUSTOMREPORT_DELAsync(long? idfReportRows, bool? deleteAnyway, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
                var _ = await _repository.Get(args) as List<APIPostResponseModel>;

                if (_ is {Count: > 0})
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion

        #region Disease Group Disease Matrix

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetDiseaseGroupDiseaseMatrixList")]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ConfigurationMatrixViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a disease group matrix list", Tags = new[] {"Configurations - Matrices"})]
        public async Task<ActionResult> GetDiseaseGroupDiseaseMatrixListAsync(
            [FromBody] DiseaseGroupDiseaseMatrixGetRequestModel request, CancellationToken cancellationToken)
        {
            List<ConfigurationMatrixViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.LanguageId, request.idfsDiagnosisGroup, request.Page, request.PageSize,
                        request.SortColumn, request.SortOrder, null, cancellationToken
                    },
                    MappedReturnType = typeof(List<ConfigurationMatrixViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<ConfigurationMatrixViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        ///     Save a Disease Group Disease Matrix
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveDiseaseGroupDiseaseMatrix")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Save a disease group matrix", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> SaveDiseaseGroupDiseaseMatrix(
            [FromBody] DiseaseGroupDiseaseMatrixSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfDiagnosisToDiagnosisGroup, request.idfsDiagnosisGroup, request.idfsDiagnosis,
                        request.EventTypeId, request.SiteId, request.UserId, request.LocationId, request.User, null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_DISEASEGROUPDISEASEMATRIX_SETResult>)
                };

                // Forwards the call to context method:   Task<USP_CONF_DISEASEGROUPDISEASEMATRIX_SETResult[]> USP_CONF_DISEASEGROUPDISEASEMATRIX_SETAsync(long? idfDiagnosisToDiagnosisGroup, long? idfsDiagnosisGroup, long? idfsDiagnosis, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)

                if (await _repository.Get(args) is List<APISaveResponseModel> {Count: > 0} @_)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Delete a Disease Group Disease Matrix
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("DeleteDiseaseGroupDiseaseMatrix")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Delete a disease group matrix", Tags = new[] {"Configurations - Matrices"})]
        public async Task<IActionResult> DeleteDiseaseGroupDiseaseMatrix(
            [FromBody] DiseaseGroupDiseaseMatrixSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[]
                    {
                        request.idfDiagnosisToDiagnosisGroup, request.DeleteAnyway,
                        request.EventTypeId, request.SiteId, request.UserId, request.LocationId, request.User, null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_DISEASEGROUPDISEASEMATRIX_DELResult>)
                };

                // Forwards the call to context method:  Task<USP_CONF_DISEASEGROUPDISEASEMATRIX_DELResult[]> USP_CONF_DISEASEGROUPDISEASEMATRIX_DELAsync(long? idfDiagnosisToDiagnosisGroup, bool? deleteAnyway, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)

                if (await _repository.Get(args) is List<APIPostResponseModel> {Count: > 0} @_)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion

        #region Grid Configuration

        [HttpPost("GetUserGridConfiguration")]
        [ProducesResponseType(typeof(List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "Returns User Grid", Tags = new[] { "Configurations - User Grids" })]
        public IActionResult GetUserGridConfiguration([FromBody] USP_CONF_USER_GRIDS_GETDETAILRequestModel request, CancellationToken cancellationToken = default)
        {
            List<USP_CONF_USER_GRIDS_GETDETAILResponseModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {request, null, cancellationToken},
                    MappedReturnType = typeof(List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_USER_GRIDS_GETDETAILResult>)
                };
                var testResults =
                    _repository.GetSynchronously(args);
                // Forwards the call to context method:  
                results = _repository.GetSynchronously(args) as List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        #endregion
    }
}