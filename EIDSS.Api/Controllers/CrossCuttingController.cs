using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Api.Provider;
using EIDSS.Repository.Contexts;
using Microsoft.EntityFrameworkCore;
using System.IO;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Configuration;
using EIDSS.Repository;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ViewModels.Common;
using Microsoft.AspNetCore.Authorization;

namespace EIDSS.Api.Controllers
{
    /// <summary>
    /// This service contains common functionality shared amoung all other EIDSS modules
    /// </summary>
    [Route("api/Crosscutting")]
    [ApiController]
    public partial class CrossCuttingController : EIDSSControllerBase
    {
        private readonly XSiteConfigurationOptions _options = null;
        private readonly IxSiteContextHelper _xsitehelper = null;

        /// <summary>
        /// Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        /// <param name="options"></param>
        /// <param name="xsitehelper"></param>
        /// <param name="memoryCache"></param>
        public CrossCuttingController(IDataRepository repository, IOptionsSnapshot<XSiteConfigurationOptions> options, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
            _options = options.Value;
        }

        [HttpPost("GetActiveSurveillanceCampaignGetListAsync")]
        [ProducesResponseType(typeof(List<ActiveSurveillanceCampaignListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ActiveSurveillanceCampaignListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ActiveSurveillanceCampaignListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Returns Human/veterinary active surveillance campaign records", Tags = new[] { "Human and Veterinary active surveillance campaign" })]
        //[SystemEventActionFilterAttribute(SystemEventEnum.DoesNotParticipate)]
        public async Task<IActionResult> GetActiveSurveillanceCampaignGetListAsync([FromBody] ActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ActiveSurveillanceCampaignListViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request, null, cancellationToken },
                    MappedReturnType = typeof(List<ActiveSurveillanceCampaignListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_AS_CAMPAIGN_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<ActiveSurveillanceCampaignListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Gets a list of actors (users, user groups, sites and site groups) for configurable and
        /// disease filtration.
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetActorList")]
        [ProducesResponseType(typeof(List<ActorGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ActorGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ActorGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of Actors", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetActorList([FromBody] ActorGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ActorGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, request.ActorTypeID, request.ActorName, request.OrganizationName, request.UserGroupDescription, request.DiseaseID, request.DiseaseFiltrationSearchIndicator, request.UserSiteID, request.UserOrganizationID, request.UserEmployeeID, request.ApplySiteFiltrationIndicator, null, cancellationToken },
                    MappedReturnType = typeof(List<ActorGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ACTOR_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<ActorGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Gets a list of actors (users, user groups, sites and site groups) for configurable and
        /// disease filtration.
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetObjectAccessList")]
        [ProducesResponseType(typeof(List<ObjectAccessGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ObjectAccessGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ObjectAccessGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of permissions for disease filtration", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetObjectAccessList([FromBody] ObjectAccessGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<ObjectAccessGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ActorID, request.SiteID, request.ObjectID, null, cancellationToken },
                    MappedReturnType = typeof(List<ObjectAccessGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_OBJECT_ACCESS_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<ObjectAccessGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Gets a list of actors (users, user groups, sites and site groups) for configurable and
        /// disease filtration.
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetDiseaseTestList")]
        [ProducesResponseType(typeof(List<DiseaseTestGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<DiseaseTestGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<DiseaseTestGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of tests by disease.", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetDiseaseTestList([FromBody] DiseaseTestGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<DiseaseTestGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageID, request.DiseaseIDList, null, cancellationToken },
                    MappedReturnType = typeof(List<DiseaseTestGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_TEST_DISEASE_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<DiseaseTestGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpPost("SaveObjectAccess")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> SaveObjectAccess([FromBody] ObjectAccessSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.ObjectAccessRecords, request.User, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_OBJECT_ACCESS_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

                if (_ != null)
                    results = _[0];
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
        /// Gets a list of diseases filtered by user for disease filtration.
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetFilteredDiseaseList")]
        [ProducesResponseType(typeof(List<FilteredDiseaseGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<FilteredDiseaseGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<FilteredDiseaseGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of filtered diseases", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetFilteredDiseaseList([FromBody] FilteredDiseaseRequestModel request, CancellationToken cancellationToken = default)
        {
            List<FilteredDiseaseGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.AccessoryCode, request.UsingType, request.AdvancedSearchTerm, request.UserEmployeeID, null, cancellationToken },
                    MappedReturnType = typeof(List<FilteredDiseaseGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_LKUP_DISEASE_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<FilteredDiseaseGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpPost("SaveDepartment")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> SaveDepartment([FromBody] DepartmentSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APISaveResponseModel results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.DepartmentID, request.DefaultName, request.NationalName, request.OrganizationID, request.DepartmentNameTypeID, request.Order, request.UserName, request.RowStatus, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_DEPARTMENT_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

                if (_ != null)
                    results = _[0];
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpPost("SaveStreet")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> SaveStreet([FromBody] StreetSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APISaveResponseModel results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.StrStreetName, request.AdminLevelId, request.StreetId, request.User, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_STREET_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

                if (_ != null)
                    results = _[0];
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpPost("SavePostalCode")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> SavePostalCode([FromBody] PostalCodeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APISaveResponseModel results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.strPostCode, request.idfsLocation, request.idfPostalCode, request.user, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_POSTALCODE_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

                if (_ != null)
                    results = _[0];
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpPost("SaveSystemFunctions")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> SaveSystemFunctions([FromBody] SystemFunctionsSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.rolesandfunctions, request.idfDataAuditEvent, request.user, null, cancellationToken },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<APIPostResponseModel>;

                if (_ != null)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpGet("GetBaseReferenceList")]
        [ProducesResponseType(typeof(List<BaseReferenceViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BaseReferenceViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BaseReferenceViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of base reference types given the type name", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetBaseReferenceList(string languageId, string referenceTypeName, long? intHACode, CancellationToken cancellationToken)
        {
            List<BaseReferenceViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                //results = await _administrationRepository.GetVectorTypeListAsync(langID, strSearchVectorType, cancellationToken);
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, referenceTypeName, intHACode, null, cancellationToken },
                    MappedReturnType = typeof(List<BaseReferenceViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_BASE_REFERENCE_GETListResult>)
                };

                results = await _repository.Get(args) as List<BaseReferenceViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();
        }

        [HttpGet("GetBaseReferenceTypeList")]
        [ProducesResponseType(typeof(List<BaseReferenceTypeListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BaseReferenceTypeListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BaseReferenceTypeListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of personal identification types", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetBaseReferenceTypeListAsync(string languageid, CancellationToken cancellationToken)
        {
            List<BaseReferenceTypeListViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                //results = await _administrationRepository.GetVectorTypeListAsync(langID, strSearchVectorType, cancellationToken);
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageid, null, cancellationToken },
                    MappedReturnType = typeof(List<BaseReferenceTypeListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_LKUP_REFERENCETYPE_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<BaseReferenceTypeListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();
        }

        [HttpGet("GetCountryList")]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets the entire country list", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetCountryList(string languageId, CancellationToken cancellationToken = default)
        {
            List<CountryModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<CountryModel>),
                    RepoMethodReturnType = typeof(List<usp_Country_GetLookupResult>)
                };

                results = await _repository.Get(args) as List<CountryModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetUserGroupList")]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets the User Group list", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetUserGroupList(string languageId, long? idfsSite, CancellationToken cancellationToken = default)
        {
            List<UserGroupGetListViewModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, idfsSite, null, cancellationToken },
                    MappedReturnType = typeof(List<UserGroupGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_EMPLOYEE_GROUP_GETListResult>)
                };

                results = await _repository.Get(args) as List<UserGroupGetListViewModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        /// <summary>
        /// Gets a list of employees for an organization or by an employee ID.
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetEmployeeLookupList")]
        [ProducesResponseType(typeof(List<EmployeeLookupGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<EmployeeLookupGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<EmployeeLookupGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a list of employees for an organization", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetEmployeeLookupList([FromBody] EmployeeLookupGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<EmployeeLookupGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.OrganizationID, null, null, null, request.AdvancedSearch, null, cancellationToken },
                    MappedReturnType = typeof(List<EmployeeLookupGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_LKUP_PERSON_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<EmployeeLookupGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetEmployeeAndEmployeeGroupSystemFunctionsPermissionsList")]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets the System Functions For User Groups and User", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetEmployeeAndEmployeeGroupSystemFunctionsPermissionsList(string UserIds, string languageId, CancellationToken cancellationToken = default)
        {
            List<SystemFunctionPermissionsViewModel> results = null;
            if (UserIds == null)
                UserIds = "";
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { UserIds, languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionPermissionsViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUserGetPermissionByRole_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<SystemFunctionPermissionsViewModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetSystemFunctionsPermissionsList")]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<CountryModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets the System Functions For Language", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetSystemFunctionsPermissionsList(string languageId, long? systemFunctionId, CancellationToken cancellationToken = default)
        {
            List<SystemFunctionsViewModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, systemFunctionId, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionsViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_USERGROUP_SYSTEMFUNCTION_PERMISSION_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<SystemFunctionsViewModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetGisChildLocation")]
        [ProducesResponseType(typeof(List<GisLocationChildLevelModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<GisLocationChildLevelModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<GisLocationChildLevelModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of child locations given the parent", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetGisChildLocation(string languageId, string parentIdfsReferenceId, CancellationToken cancellationToken = default)
        {
            List<GisLocationChildLevelModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, parentIdfsReferenceId, null, cancellationToken },
                    MappedReturnType = typeof(List<GisLocationChildLevelModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_GIS_Location_ChildLevel_GetResult>)
                };

                results = await _repository.Get(args) as List<GisLocationChildLevelModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetGisCurrentLocation")]
        [ProducesResponseType(typeof(List<GisLocationCurrentLevelModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<GisLocationCurrentLevelModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<GisLocationCurrentLevelModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of locations given the location level", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetGisCurrentLocation(string languageId, int level, bool allCountries, CancellationToken cancellationToken = default)
        {
            List<GisLocationCurrentLevelModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, level, allCountries, null, cancellationToken },
                    MappedReturnType = typeof(List<GisLocationCurrentLevelModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_GIS_Location_CurrentLevel_GetResult>)
                };

                results = await _repository.Get(args) as List<GisLocationCurrentLevelModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetGISLocation")]
        [ProducesResponseType(typeof(List<GISLocationModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<GISLocationModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<GISLocationModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of locations, given a location parent.  E.g. States, gets counties, etc.", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetGISLocation(string languageId, int? level, string parentNode = null, CancellationToken cancellationToken = default)
        {
            List<GISLocationModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, parentNode, level, null, cancellationToken },
                    MappedReturnType = typeof(List<GISLocationModel>),
                    RepoMethodReturnType = typeof(List<GISLocationModel>)
                };

                results = await _repository.Get(args) as List<GISLocationModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetGisLoctionLevels")]
        [ProducesResponseType(typeof(List<GisLocationLevelModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<GisLocationLevelModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<GisLocationLevelModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get the list of GIS Location level types", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetGisLoctionLevels(string languageId, CancellationToken cancellationToken = default)
        {
            List<GisLocationLevelModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<GisLocationLevelModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_GIS_Location_Levels_GetResult>)
                };

                results = await _repository.Get(args) as List<GisLocationLevelModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetLanguageList")]
        [ProducesResponseType(typeof(List<LanguageModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<LanguageModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<LanguageModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get the list of EIDSS supported languages", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetLanguageListAsync(string languageID)
        {
            List<LanguageModel> results;

            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, null, null },
                    MappedReturnType = typeof(List<LanguageModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_Languages_GETListResult>)
                };

                results = await _repository.Get(args) as List<LanguageModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();
        }

        [HttpGet("GetMonthNameList")]
        [ProducesResponseType(typeof(List<ReportMonthNameModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ReportMonthNameModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ReportMonthNameModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of months", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetMonthNameList(string languageId, CancellationToken cancellationToken = default)
        {
            List<ReportMonthNameModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<ReportMonthNameModel>),
                    RepoMethodReturnType = typeof(List<USP_REP_MonthNames_GETResult>)
                };

                results = await _repository.Get(args) as List<ReportMonthNameModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetReportLanguageList")]
        [ProducesResponseType(typeof(List<ReportLanguageModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ReportLanguageModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ReportLanguageModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of report languges supported by EIDSS", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetReportLanguageList(string languageId, CancellationToken cancellationToken = default)
        {
            List<ReportLanguageModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<ReportLanguageModel>),
                    RepoMethodReturnType = typeof(List<USP_REP_Languages_GETResult>)
                };

                results = await _repository.Get(args) as List<ReportLanguageModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetResourceList")]
        [ProducesResponseType(typeof(List<ResourceModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ResourceModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ResourceModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of resource records for various cultures supported by EIDSS", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetResourceListAsync(string cultureName, CancellationToken cancellationToken = default)
        {
            List<ResourceModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { cultureName, null, cancellationToken },
                    MappedReturnType = typeof(List<ResourceModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_Resource_GETListResult>)
                };

                results = await _repository.Get(args) as List<ResourceModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetStreetList")]
        [ProducesResponseType(typeof(List<StreetModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<StreetModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<StreetModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of streets given a location", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetStreetList(long? locationId, CancellationToken cancellationToken = default)
        {
            List<StreetModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { locationId, null, cancellationToken },
                    MappedReturnType = typeof(List<StreetModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_STREET_GETListResult>)
                };

                results = await _repository.Get(args) as List<StreetModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetYearList")]
        [ProducesResponseType(typeof(List<ReportYearModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ReportYearModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ReportYearModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of years", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetYearList(CancellationToken cancellationToken = default)
        {
            List<ReportYearModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { null, cancellationToken },
                    MappedReturnType = typeof(List<ReportYearModel>),
                    RepoMethodReturnType = typeof(List<USP_REP_Years_GETResult>)
                };

                results = await _repository.Get(args) as List<ReportYearModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetSettlementList")]
        [ProducesResponseType(typeof(List<SettlementViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SettlementViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SettlementViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of Settlement", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetSettlementList(string languageId, long? parentAdminLevelId, long? id, CancellationToken cancellationToken = default)
        {
            List<SettlementViewModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, parentAdminLevelId, id, null, cancellationToken },
                    MappedReturnType = typeof(List<SettlementViewModel>),
                    RepoMethodReturnType = typeof(List<usp_Settlement_GetLookupResult>)
                };

                results = await _repository.Get(args) as List<SettlementViewModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpGet("GetPostalCodeList")]
        [ProducesResponseType(typeof(List<PostalCodeViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<PostalCodeViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<PostalCodeViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of Postal Code", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetPostalCodeList(long settlementId, CancellationToken cancellationToken = default)
        {
            List<PostalCodeViewModel> results = null;
            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { settlementId, null, cancellationToken },
                    MappedReturnType = typeof(List<PostalCodeViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_POSTAL_CODE_GETLISTResult>)
                };

                results = await _repository.Get(args) as List<PostalCodeViewModel>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpPost("SaveReportAudit")]
        [ProducesResponseType(typeof(ReportAuditSaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ReportAuditSaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ReportAuditSaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Base Reference Editors" })]
        public async Task<IActionResult> SaveReportAudit([FromBody] ReportAuditSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            ReportAuditSaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.idfUserID, request.strFirstName, request.strMiddleName, request.strLastName, request.userRole,
                        request.strOrganization, request.strReportName, request.idfIsSignatureIncluded, request.datGeneratedDate, null, cancellationToken },
                    MappedReturnType = typeof(List<ReportAuditSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_REP_REPORT_AUDIT_SETResult>)
                };

                // Forwards the call to context method:
                var _ = await _repository.Save(args) as List<ReportAuditSaveResponseModel>;

                if (_ != null)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Retrieves a list of matrix versions by type
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetMatrixVersionsByType")]
        [ProducesResponseType(typeof(List<MatrixVersionViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MatrixVersionViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MatrixVersionViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a list of matrix versions by type", Tags = new[] { "Configurations - Matrices" })]
        public async Task<ActionResult> GetMatrixVersionsByType(long? idfsMatrixType, CancellationToken cancellationToken = default)
        {
            List<MatrixVersionViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { idfsMatrixType, 1, 50, null, null, null, cancellationToken },
                    MappedReturnType = typeof(List<MatrixVersionViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_HumanAggregateCaseMatrixVersionByMatrixType_GETResult>)
                };

                results = await _repository.Get(args) as List<MatrixVersionViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Retrieves a species list
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetSpeciesList")]
        [ProducesResponseType(typeof(List<SpeciesViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SpeciesViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SpeciesViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get a species list", Tags = new[] { "Configurations - Matrices" })]
        public async Task<ActionResult> GetSpeciesListAsync(long? idfsBaseReference, long? intHACode, string languageId, CancellationToken cancellationToken = default)
        {
            List<SpeciesViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { idfsBaseReference, intHACode, languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<SpeciesViewModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_GetSpeciesList_GETResult>)
                };

                results = await _repository.Get(args) as List<SpeciesViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Save a matrix version
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveMatrixVersion")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Save a matrix version", Tags = new[] { "Configurations - Matrices" })]
        public async Task<IActionResult> SaveMatrixVersion([FromBody] HumanAggregateCaseMatrixRequestModel request, CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.VersionId,
                        request.MatrixTypeId,
                        request.StartDate,
                        request.MatrixName,
                        request.IsActive,
                        request.IsDefault,
                        request.EventTypeId,
                        request.SiteId,
                        request.UserId,
                        request.LocationId,
                        request.User,
                        null,
                        cancellationToken
                    },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_HumanAggregateCaseMatrixVersion_SETResult>)
                };

                var _ = await _repository.Get(args) as List<APISaveResponseModel>;

                if (_ != null && _.Count > 0)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Retrieves a species list
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetAccessRulesAndPermissions")]
        [ProducesResponseType(typeof(List<AccessRulesAndPermissions>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AccessRulesAndPermissions>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<AccessRulesAndPermissions>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get Access Rules and Permission", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetAccessRulesAndPermissions(long userId, CancellationToken cancellationToken = default)
        {
            List<AccessRulesAndPermissions> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { userId, null, cancellationToken },
                    MappedReturnType = typeof(List<AccessRulesAndPermissions>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUser_GetAccessRulesAndPermissionsResult>)
                };

                results = await _repository.Get(args) as List<AccessRulesAndPermissions>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [AllowAnonymous]
        [ResponseCache(CacheProfileName = "CacheInfini")]
        [HttpGet("GetXSiteDocumentList")]
        [ProducesResponseType(typeof(List<XSiteDocumentListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<XSiteDocumentListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<XSiteDocumentListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets the complete list of xsite help documents for the given language", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetXSiteDocumentList(string languageid, [FromServices] IxSiteContextHelper xsitehelper, CancellationToken cancellationToken = default)
        {
            List<XSiteDocumentListViewModel> results = null;
            IXSiteContext ctx = null;

            try
            {
                cancellationToken.ThrowIfCancellationRequested();

                if (results != null) return Ok(results);

                #region (1)  Get the document map

                results = new List<XSiteDocumentListViewModel>();

                DataRepoArgs args = new()
                {
                    Args = new object[] { null, cancellationToken },
                    MappedReturnType = typeof(List<USP_xSiteDocumentListGetResult>),
                    RepoMethodReturnType = typeof(List<USP_xSiteDocumentListGetResult>)
                };

                var map = await _repository.Get(args) as List<USP_xSiteDocumentListGetResult>;

                #endregion (1)  Get the document map

                #region (2) Get the associated document list from its respective database

                if (string.IsNullOrEmpty(languageid))
                {
                    languageid = "en-US";
                }

                ctx = xsitehelper.GetXSiteInstance(languageid);

                if (languageid == "en-US")
                {
                    languageid = "en";
                }
                else if (languageid == "az-Latn-AZ")
                {
                    languageid = "az-L";
                }
                else if (languageid == "ka-GE")
                {
                    languageid = "ka";
                }
                else
                {
                    languageid = "en";
                }

                    var langdocs =
                    (
                    from d in ctx.TDocuments
                    join m in ctx.TDocumentGroupMappings on d.DocumentId equals m.DocumentId into j1
                    from dmg in j1.DefaultIfEmpty()
                    join g in ctx.TDocumentGroups on dmg.DocumentGroupId equals g.DocumentGroupId into j2
                    from ddmg in j2.DefaultIfEmpty()
                    where d.Guid != null && d.FileName != null
                    select new XSiteDocumentListViewModel
                    {
                        DocumentID = d.DocumentId,
                        DocumentGroupName = "",
                        DocumentName = d.DocumentName,
                        FileName = d.FileName,
                        VideoName = d.ShowMePath,
                        GUID = d.Guid
                    }).Distinct().ToList();

                foreach (var doc in langdocs)
                {
                    // Get the document from the country database for the given guid in the mapping table
                    var isomap = map.Where(w => w.xSiteGUID == doc.GUID);
                    if (isomap != null && isomap.Count() > 0)
                    {
                        doc.EIDSSMenuID = isomap.FirstOrDefault().EIDSSMenuId;
                        doc.CountryISOCode = isomap.FirstOrDefault().LanguageCode;
                        doc.EIDSSMenuPageLink = isomap.FirstOrDefault().PageLink;
                    }
                }
                //Remove records where there's no associated menu map...
                langdocs.RemoveAll(r => r.CountryISOCode == null);

                if (langdocs.Count > 0)
                    results.AddRange(langdocs);

                #endregion (2) Get the associated document list from its respective database

                if (results == null)
                {
                    Log.Information("Unable to find help documents");
                    throw new Exception("Unable to locate help documents for the given language");
                }
                else
                {
                    foreach (var item in _options.LanguageConfigurations)
                    {
                        if (item.CountryISOCode == "en-US")
                        {
                            item.CountryISOCode = "en";
                        }
                        else if (item.CountryISOCode == "az-Latn-AZ")
                        {
                            item.CountryISOCode = "az-L";
                        }
                        else if (item.CountryISOCode == "ka-GE")
                        {
                            item.CountryISOCode = "ka";
                        }
                    }

                    List<XSiteDocumentListViewModel> videolist = new();
                    foreach (var vid in results)
                    {
                        var idx = _options.LanguageConfigurations.FindIndex(f => f.CountryISOCode.ToLower() == vid.CountryISOCode.ToLower());
                        if (idx != -1)
                        {
                            vid.FileName = Path.Combine(_options.LanguageConfigurations[idx].DataDirectory, string.Format("DOC{0}", vid.DocumentID), vid.FileName);

                            //Check if there is an MP4 file as well.
                            if (vid.VideoName != null)
                            {
                                videolist.Add(new XSiteDocumentListViewModel
                                {
                                    DocumentGroupName = vid.DocumentGroupName,
                                    DocumentID = vid.DocumentID,
                                    DocumentName = vid.DocumentName,
                                    FileName = Path.Combine(_options.LanguageConfigurations[idx].DataDirectory, string.Format("DOC{0}", vid.DocumentID), vid.VideoName),
                                    GUID = vid.GUID,
                                    CountryISOCode = vid.CountryISOCode,
                                    EIDSSMenuID = vid.EIDSSMenuID,
                                    EIDSSMenuPageLink = vid.EIDSSMenuPageLink
                                });

                                vid.VideoName = null;
                            }
                        }
                    }

                    results.AddRange(videolist);
                }
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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
        /// Retrieves the given xsite help file as a stream...
        /// </summary>
        /// <param name="filename">A fully qualified path to the location of the file on disk.  This filename will have been returned
        /// via a call to the <see cref="GetXSiteDocumentList"/> method.</param>
        /// <returns>
        /// Returns a JSON OBJECT APIFileResponseModel with Properties: ReturnCode, ReturnMessage and the results payload
        /// </returns>
        [HttpGet("GetXSiteHelpFile")]
        [ProducesResponseType(typeof(APIFileResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIFileResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIFileResponseModel), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Get Access Rules and Permission", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetXSITEHelpFile(string filename)
        {
            APIFileResponseModel results = new APIFileResponseModel();

            try
            {
                // Check if file exists...
                if (!System.IO.File.Exists(filename))
                    throw new FileNotFoundException("File Not Found!"); // replace with call to localizer!!!!
                else
                {
                    FileStream fs = new System.IO.FileStream(filename, System.IO.FileMode.Open, System.IO.FileAccess.Read);
                    int length = Convert.ToInt32(fs.Length);
                    byte[] data = new byte[length];
                    await fs.ReadAsync(data, 0, length);
                    fs.Close();
                    results.Results = data;
                    results.ReturnCode = StatusCodes.Status200OK;
                }
            }
            catch (Exception e)
            {
                Log.Error("GetXSITEHelpFile failed", e);
                throw;
            }
            return Ok(results);
        }

        [HttpPost("GetUserList")]
        [ProducesResponseType(typeof(List<UserModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<UserModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<UserModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Returns  UserList records", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetUserList([FromBody] UserGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<UserModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request, null, cancellationToken },
                    MappedReturnType = typeof(List<UserModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_USER_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<UserModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpPost("GetSiteList")]
        [ProducesResponseType(typeof(List<SiteModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Returns  SiteList records", Tags = new[] { "Cross Cutting" })]
        public async Task<IActionResult> GetSiteList([FromBody] SiteGblGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SiteModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_Site_GETListResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<SiteModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
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

        [HttpPost("GetBaseReferenceTranslationAsync")]
        [ProducesResponseType(typeof(List<BaseReferenceTranslationResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BaseReferenceTranslationResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BaseReferenceTranslationResponseModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Returns an 'On The Fly' translation for a given base reference id.", Tags = new[] { "Cross Cutting" })]
        public async Task<ActionResult> GetBaseReferenceTranslationAsync([FromBody] BaseReferenceTranslationRequestModel request, CancellationToken cancellationToken = default)
        {
            List<BaseReferenceTranslationResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageID, request.idfsBaseReference, null, cancellationToken },
                    MappedReturnType = typeof(List<BaseReferenceTranslationResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_BaseReferenceTranslation_GetResult>)
                };

                // Forwards the call to context method:
                results = await _repository.Get(args) as List<BaseReferenceTranslationResponseModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }
    }
}