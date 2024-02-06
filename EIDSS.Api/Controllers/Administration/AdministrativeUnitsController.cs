using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.AspNetCore.Http;
using Swashbuckle.AspNetCore.Annotations;
using System.Threading;
using EIDSS.Repository.ReturnModels;
using Serilog;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.PIN;

namespace EIDSS.Api.Controllers.Administration
{

    [Route("api/Administration/AdministrativeUnits")]
    [ApiController]
    public class AdministrativeUnitsController : EIDSSControllerBase
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="genericRepository"></param>
        /// <param name="memoryCache"></param>
        public AdministrativeUnitsController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }

        #region  Get Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetAdministrativeUnitsList")]
        [ProducesResponseType(typeof(List<AdministrativeUnitsGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AdministrativeUnitsGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<AdministrativeUnitsGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<AdministrativeUnitsGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration" })]
        public async Task<IActionResult> GetAdministrativeUnitsList([FromBody] AdministrativeUnitsSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            List<AdministrativeUnitsGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.idfsAdminLevel, request.idfsCountry, request.idfsRegion, request.idfsRayon, request.idfsSettlement,
                        request.DefaultName, request.NationalName,request.idfsSettlementType,request.LatitudeFrom,request.LatitudeTo, request.LongitudeFrom,request.LongitudeTo,
                        request.ElevationFrom, request.ElevationTo,request.Page, request.PageSize,  request.SortColumn, request.SortOrder, request.StrHASC,request.StrCode, null, cancellationToken },
                    MappedReturnType = typeof(List<AdministrativeUnitsGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ADMINLEVEL_GETLISTResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<AdministrativeUnitsGetListViewModel>;
                
                if (results.Count>0)
                {
                    if (request.AdminstrativeLevelValue != null)
                    {
                        results.ForEach(r => {
                            r.AdministrativeLevelValue = request.AdminstrativeLevelValue;
                            r.AdministrativeLevelId = request.idfsAdminLevel;
                        });
                    }
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


        [HttpPost("SaveAdministrativeUnit")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration" })]
        public async Task<IActionResult> SaveAdministrativeUnit([FromBody] AdministrativeUnitSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.LanguageId,
                        request.IdfsParent,
                        request.StrHASC,
                        request.StrCode,
                        request.IdfsLocation,
                        request.StrDefaultName,
                        request.StrNationalName,
                        request.IdfsType,
                        request.Latitude,
                        request.Longitude,
                        request.Elevation,
                        request.IntOrder,
                        request.User,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_GISDATA_SETResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<APISaveResponseModel>;
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

            return Ok(results.FirstOrDefault());
        }

        [HttpDelete("DeleteAdministrativeUnit")]
        [ProducesResponseType(typeof(List<ApiPostGisDataResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<ApiPostGisDataResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<ApiPostGisDataResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<ApiPostGisDataResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration" })]
        public async Task<IActionResult> DeleteAdministrativeUnit(long IdfsLocationId, string UserName,CancellationToken cancellationToken = default)
        {
            List<ApiPostGisDataResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        IdfsLocationId, UserName, null, cancellationToken },
                    MappedReturnType = typeof(List<ApiPostGisDataResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_GISDATA_DELResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Delete(args) as List<ApiPostGisDataResponseModel>;
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

            return Ok(results.FirstOrDefault());
        }

        #endregion

    }
}
