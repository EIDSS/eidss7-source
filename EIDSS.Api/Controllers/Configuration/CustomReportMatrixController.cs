using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.Repositories;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Serilog;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Configuration
{
    [Route("api/Configuration/CustomReportMatrix")]
    [ApiController]
    public partial class CustomReportMatrixController : EIDSSControllerBase
    {
        public CustomReportMatrixController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }

        [HttpPost("SaveCustomReportRowsOrder")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Save custom report row order", Tags = new[] { "Configurations - Matrices" })]
        //[SystemEventActionFilterAttribute(SystemEventEnum.DoesNotParticipate)]
        public async Task<IActionResult> SaveCustomReportRowsOrder([FromBody] CustomReportRowsRowOrderSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Create a DataTable from the request
                System.Data.DataTable rows = new System.Data.DataTable();
                rows.Columns.Add("KeyId");
                rows.Columns.Add("RowOrder");
                foreach (var row in request.Rows)
                {
                    rows.Rows.Add(row.KeyId, row.NewData);
                }

                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { rows, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_CONF_CUSTOMREPORT_ROWORDER_SETResult>)
                };

                // Forwards the call to context method:  
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

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
    }
}
