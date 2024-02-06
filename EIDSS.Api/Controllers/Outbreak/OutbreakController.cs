using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;

using Serilog;
using System.Threading;
using EIDSS.Domain.RequestModels.Outbreak;

using EIDSS.Domain.RequestModels;

using EIDSS.Api.ActionFilters;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Human;
using Swashbuckle.AspNetCore.Annotations;
using EIDSS.Domain.ViewModels;
using System.IO;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Outbreak
{
    [Route("api/Outbreak")]
    [ApiController]
    public partial class OutbreakController : EIDSSControllerBase
    {
        /// <summary>
        /// Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        /// <param name="memoryCache"></param>
        public OutbreakController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("SetSessionNoteAsync")]
        [ProducesResponseType(typeof(OutbreakSessionNoteSaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(OutbreakSessionNoteSaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(OutbreakSessionNoteSaveResponseModel), StatusCodes.Status409Conflict)]
        [SwaggerOperation(Summary = "Uploads a custom file object to the Outbreak Notes/Update area.", Tags = new[] { "Outbreak" })]
        public async Task<IActionResult> SetSessionNoteAsync([FromForm] OutbreakSessionNoteCreateRequestModel model, CancellationToken cancellationToken = default)
        {
            List<OutbreakSessionNoteSaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                if (model.FileUpload != null)
                {
                    if (model.FileUpload.Length > 0)
                    {
                        var filePath = Path.GetRandomFileName();
                        using (var stream = System.IO.File.Create(filePath))
                        {
                            await model.FileUpload.CopyToAsync(stream);
                            stream.Position = 0;
                            var b = new byte[stream.Length];
                            stream.Read(b, 0, b.Length);
                            model.UploadFileObject = b;
                        }
                    }
                }

                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        model.LangID,
                        model.idfOutbreakNote,
                        model.idfOutbreak,
                        model.strNote,
                        model.idfPerson,
                        model.intRowStatus,
                        model.strMaintenanceFlag,
                        model.strReservedAttribute,
                        model.UpdatePriorityID,
                        model.UpdateRecordTitle,
                        model.UploadFileName,
                        model.UploadFileDescription,
                        model.UploadFileObject,
                        model.DeleteAttachment,
                        model.User,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<OutbreakSessionNoteSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_OMM_SESSION_Note_SetResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<OutbreakSessionNoteSaveResponseModel>;
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
    }
}