using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using EIDSS.Domain.RequestModels.Administration;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers
{
    [Route("api/Preference")]
    public partial class PreferenceController : EIDSSControllerBase
    {
        /// <summary>
        /// Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        /// <param name="memoryCache"></param>
        public PreferenceController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        /// <summary>
        /// Retrieves System Preferences 
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetSystemPreferences")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(List<SystemPreferenceViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemPreferenceViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemPreferenceViewModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<SystemPreferenceViewModel>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> GetSystemPreferences(CancellationToken cancellationToken)
        {
            List<SystemPreferenceViewModel> result = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { null, cancellationToken },
                    MappedReturnType = typeof(List<SystemPreferenceViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEM_PREFERENCE_GETDetailResult>)
                };

                result = await _repository.Get(args) as List<SystemPreferenceViewModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (result != null)
                return Ok(result.FirstOrDefault());
            else
                return NotFound();

        }


        /// <summary>
        /// Retrieves System Preferences 
        /// </summary>
        /// <returns></returns>
        [HttpPost("SaveSystemPreferences")]
        [ProducesResponseType(typeof(List<SystemPreferenceSaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemPreferenceSaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemPreferenceSaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemPreferenceSaveResponseModel>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> SaveSystemPreferences([FromBody] SystemPreferenceViewModel systemPreferenceViewModel, CancellationToken cancellationToken)
        {
            List<SystemPreferenceSaveResponseModel> result = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { systemPreferenceViewModel.SystemPreferenceID, systemPreferenceViewModel.PreferenceDetail, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemPreferenceSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEM_PREFERENCE_SETResult>)
                };

                result = await _repository.Save(args) as List<SystemPreferenceSaveResponseModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (result != null)
                return Ok(result.FirstOrDefault());
            else
                return NotFound();

        }



        /// <summary>
        /// Retrieves System Preferences 
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetUserPreferences")]
        [ProducesResponseType(typeof(List<UserPreferenceViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<UserPreferenceViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<UserPreferenceViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<UserPreferenceViewModel>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetUserPreferences(long userId,CancellationToken cancellationToken)
        {
            List<UserPreferenceViewModel> result = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { userId, null, cancellationToken },
                    MappedReturnType = typeof(List<UserPreferenceViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_USER_PREFERENCE_GETDetailResult>)
                };

                result = await _repository.Get(args) as List<UserPreferenceViewModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (result != null)
                return Ok(result.FirstOrDefault());
            else
                return NotFound();

        }


        /// <summary>
        /// Retrieves System Preferences 
        /// </summary>
        /// <returns></returns>
        [HttpPost("SaveUserPreferences")]
        [ProducesResponseType(typeof(List<UserPreferenceSaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<UserPreferenceSaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<UserPreferenceSaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<UserPreferenceSaveResponseModel>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> SaveUserPreferences([FromBody] UserPreferenceSetParameters parameters, CancellationToken cancellationToken)
        {
            List<UserPreferenceSaveResponseModel> result = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { parameters.UserPreferenceID, parameters.UserId,parameters.ModuleConstantId,parameters.PreferenceDetail,parameters.AuditUserName, null, cancellationToken },
                    MappedReturnType = typeof(List<UserPreferenceSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_USER_PREFERENCE_SETResult>)
                };

                result = await _repository.Save(args) as List<UserPreferenceSaveResponseModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
            }

            if (result != null)
                return Ok(result.FirstOrDefault());
            else
                return NotFound();

        }
    }
}
