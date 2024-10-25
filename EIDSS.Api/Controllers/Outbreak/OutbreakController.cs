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
        public OutbreakController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("SetSessionNoteAsync")]
        public async Task<ActionResult<OutbreakSessionNoteSaveResponseModel>> SetSessionNoteAsync(
            [FromForm] OutbreakSessionNoteCreateRequestModel model, CancellationToken cancellationToken = default)
        {
            if (model.FileUpload != null && model.FileUpload.Length > 0)
            {
                using var ms = new MemoryStream();
                await model.FileUpload.CopyToAsync(ms, cancellationToken);
                ms.Position = 0;
                model.UploadFileObject = ms.ToArray();
            }

            var args = new object[]
            {
                model.LangID, model.idfOutbreakNote, model.idfOutbreak,
                model.strNote, model.idfPerson, model.intRowStatus,
                model.strMaintenanceFlag, model.strReservedAttribute,
                model.UpdatePriorityID, model.UpdateRecordTitle, model.UploadFileName,
                model.UploadFileDescription, model.UploadFileObject,
                model.DeleteAttachment, model.User, null, cancellationToken
            };
            return (await ExecuteOnRepository<USP_OMM_SESSION_Note_SetResult, OutbreakSessionNoteSaveResponseModel>(
                args)).FirstOrDefault();
        }
        
        [HttpPost("SetCaseAsync")]
        public async Task<ActionResult<OutbreakCaseSaveResponseModel>> SetCaseAsync([FromBody] OutbreakCaseCreateRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            return (await ExecuteOnRepository<USP_OMM_Case_SetResult, OutbreakCaseSaveResponseModel>(args)).FirstOrDefault();
        }
    }
}