#region Usings

using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Api.Controllers.Laboratory
{
    [Route("api/Laboratory/Laboratory")]
    [ApiController]
    public partial class LaboratoryController : EIDSSControllerBase
    {
        #region Constructors

        public LaboratoryController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        #endregion

        #region Laboratory Common Methods

        [HttpPost("GetTabCountsList")]
        [ProducesResponseType(typeof(List<TabCountsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TabCountsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TabCountsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TabCountsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTabCountsList([FromBody] TabCountsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TabCountsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.DaysFromAccessionDate, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<TabCountsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TAB_COUNTS_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TabCountsGetListViewModel>;
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

        [HttpPost("SaveLaboratory")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> SaveLaboratory([FromBody] LaboratorySaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.Samples,
                        request.Batches,
                        request.Tests,
                        request.TestAmendments,
                        request.Transfers,
                        request.FreezerBoxLocationAvailabilities,
                        request.Events,
                        request.UserID,
                        request.Favorites,
                        request.AuditUserName,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SETResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<APISaveResponseModel>;
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

            return results != null ? Ok(results.FirstOrDefault()) : null;
        }

        #endregion

        #region Samples Methods

        [HttpPost("GetSamplesList")]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSamplesList([FromBody] SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SamplesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SampleID, request.ParentSampleID, request.DaysFromAccessionDate, request.SampleList, request.TestUnassignedIndicator, request.TestCompletedIndicator, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, request.SortColumn, null, cancellationToken },
                    MappedReturnType = typeof(List<SamplesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SamplesGetListViewModel>;
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

        [HttpPost("GetSamplesSimpleSearchList")]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSamplesSimpleSearchList([FromBody] SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SamplesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SearchString, request.AccessionedIndicator, request.TestUnassignedIndicator, request.TestCompletedIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, request.DaysFromAccessionDate, null, cancellationToken },
                    MappedReturnType = typeof(List<SamplesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SamplesGetListViewModel>;
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

        [HttpPost("GetSamplesAdvancedSearchList")]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSamplesAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SamplesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.SentToOrganizationSiteID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, request.SampleList, request.TestUnassignedIndicator, request.TestCompletedIndicator, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<SamplesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SamplesGetListViewModel>;
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

        [HttpPost("GetSamplesGroupAccessionInSearchList")]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSamplesGroupAccessionInSearchList([FromBody] GroupAccessionInSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SamplesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.EIDSSLocalOrFieldSampleIDList, request.SentToOrganizationID, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<SamplesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_GROUP_ACCESSION_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SamplesGetListViewModel>;
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

        [HttpGet("GetSampleDetail")]
        [ProducesResponseType(typeof(List<SampleGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SampleGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SampleGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SampleGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSampleDetail(string languageID, long sampleID, long userID, CancellationToken cancellationToken = default)
        {
            List<SampleGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, sampleID, userID, null, cancellationToken },
                    MappedReturnType = typeof(List<SampleGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_GETDetailResult>)
                };
                results = await _repository.Get(args) as List<SampleGetDetailViewModel>;
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

            return Ok(results.FirstOrDefault());
        }

        [HttpPost("GetSampleIDList")]
        [ProducesResponseType(typeof(List<SampleIDsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SampleIDsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SampleIDsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SampleIDsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSampleIDList([FromBody] SampleIDsSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SampleIDsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.Samples, null, cancellationToken },
                    MappedReturnType = typeof(List<SampleIDsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_ID_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SampleIDsGetListViewModel>;
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

        [HttpPost("GetSamplesByBarCodeList")]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SamplesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetSamplesByBarCodeList([FromBody] SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SamplesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.SampleList, null, cancellationToken },
                    MappedReturnType = typeof(List<SamplesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_SAMPLE_GetListByBarCodesResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SamplesGetListViewModel>;
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

        #region Testing Methods

        [HttpPost("GetTestingList")]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTestingList([FromBody] TestingGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TestingGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.TestStatusTypeID, request.SampleID, request.TestID, request.BatchTestID, request.TestList, request.DaysFromAccessionDate, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<TestingGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TEST_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TestingGetListViewModel>;
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

        [HttpPost("GetTestingSimpleSearchList")]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTestingSimpleSearchList([FromBody] TestingGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TestingGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SearchString, request.AccessionedIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, request.DaysFromAccessionDate, null, cancellationToken },
                    MappedReturnType = typeof(List<TestingGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TEST_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TestingGetListViewModel>;
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

        [HttpPost("GetTestingAdvancedSearchList")]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTestingAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TestingGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.SentToOrganizationSiteID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, null, request.BatchTestAssociationIndicator, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<TestingGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TEST_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TestingGetListViewModel>;
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

        [HttpGet("GetTestDetail")]
        [ProducesResponseType(typeof(List<TestGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TestGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TestGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TestGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTestDetail(string languageID, long testID, long userID, CancellationToken cancellationToken = default)
        {
            List<TestGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, testID, userID, null, cancellationToken },
                    MappedReturnType = typeof(List<TestGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TEST_GETDetailResult>)
                };
                results = await _repository.Get(args) as List<TestGetDetailViewModel>;
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

            return Ok(results.FirstOrDefault());
        }

        [HttpPost("GetTestAmendmentList")]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TestingGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTestAmendmentList([FromBody] TestAmendmentGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TestAmendmentsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.TestID, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<TestAmendmentsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TEST_AMENDMENT_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TestAmendmentsGetListViewModel>;
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

        #region Transferred Methods

        [HttpPost("GetTransferredList")]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTransferredList([FromBody] TransferredGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TransferredGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SampleID, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<TransferredGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TRANSFER_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TransferredGetListViewModel>;
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

        [HttpPost("GetTransferredSimpleSearchList")]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTransferredSimpleSearchList([FromBody] TransferredGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TransferredGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SearchString, request.AccessionedIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<TransferredGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TRANSFER_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TransferredGetListViewModel>;
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

        [HttpPost("GetTransferredAdvancedSearchList")]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TransferredGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTransferredAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<TransferredGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.SentToOrganizationSiteID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.TestNameTypeName, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, null, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<TransferredGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TRANSFER_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<TransferredGetListViewModel>;
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

        [HttpGet("GetTransferDetail")]
        [ProducesResponseType(typeof(List<TransferGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<TransferGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<TransferGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<TransferGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetTransferDetail(string languageID, long transferID, long userID, CancellationToken cancellationToken = default)
        {
            List<TransferGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, transferID, userID, null, cancellationToken },
                    MappedReturnType = typeof(List<TransferGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_TRANSFER_GETDetailResult>)
                };
                results = await _repository.Get(args) as List<TransferGetDetailViewModel>;
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

            return Ok(results.FirstOrDefault());
        }

        #endregion

        #region My Favorites Methods

        [HttpPost("GetMyFavoritesList")]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetMyFavoritesList([FromBody] MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<MyFavoritesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SampleID, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<MyFavoritesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_FAVORITE_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<MyFavoritesGetListViewModel>;
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

        [HttpPost("GetMyFavoritesSimpleSearchList")]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetMyFavoritesSimpleSearchList([FromBody] MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<MyFavoritesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SearchString, request.AccessionedIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<MyFavoritesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_FAVORITE_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<MyFavoritesGetListViewModel>;
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

        [HttpPost("GetMyFavoritesAdvancedSearchList")]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<MyFavoritesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetMyFavoritesAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<MyFavoritesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.SentToOrganizationSiteID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, request.SampleList, null, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<MyFavoritesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_FAVORITE_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<MyFavoritesGetListViewModel>;
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

        #region Batches Methods

        [HttpPost("GetBatchesList")]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GeBatchesList([FromBody] BatchesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<BatchesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<BatchesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_BATCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<BatchesGetListViewModel>;
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

        [HttpPost("GetBatchesAdvancedSearchList")]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<BatchesGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetBatchesAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<BatchesGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, null, request.FiltrationIndicator, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<BatchesGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_BATCH_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<BatchesGetListViewModel>;
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

        #region Approvals Methods

        [HttpPost("GetApprovalsList")]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetApprovalsList([FromBody] ApprovalsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ApprovalsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SampleID, request.TestID, request.UserOrganizationID, request.UserEmployeeID, request.UserSiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<ApprovalsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_APPROVAL_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<ApprovalsGetListViewModel>;
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

        [HttpPost("GetApprovalsSimpleSearchList")]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetApprovalsSimpleSearchList([FromBody] MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ApprovalsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SearchString, request.AccessionedIndicator, request.UserID, request.UserEmployeeID, request.UserOrganizationID, request.UserSiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<ApprovalsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_APPROVAL_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<ApprovalsGetListViewModel>;
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

        [HttpPost("GetApprovalsAdvancedSearchList")]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<ApprovalsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Laboratory" })]
        public async Task<IActionResult> GetApprovalsAdvancedSearchList([FromBody] AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ApprovalsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ReportOrSessionTypeID, request.SurveillanceTypeID, request.SampleStatusTypes, request.AccessionIndicatorList, request.EIDSSLocalOrFieldSampleID, request.EIDSSReportSessionOrCampaignID, request.SentToOrganizationID, request.SentToOrganizationSiteID, request.TransferredToOrganizationID, request.EIDSSTransferID, request.ResultsReceivedFromOrganizationID, request.DateFrom, request.DateTo, request.EIDSSLaboratorySampleID, request.SampleTypeID, request.TestNameTypeID, request.DiseaseID, request.TestStatusTypeID, request.TestResultTypeID, request.TestResultDateFrom, request.TestResultDateTo, request.PatientName, request.FarmOwnerName, request.SpeciesTypeID, null, null, request.UserID, request.UserEmployeeID, request.UserSiteID, request.UserOrganizationID, request.UserSiteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<ApprovalsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_LAB_APPROVAL_ADVANCED_SEARCH_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<ApprovalsGetListViewModel>;
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