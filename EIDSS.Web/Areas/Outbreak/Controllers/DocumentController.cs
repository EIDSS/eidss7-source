using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Validators;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Net.Http.Headers;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Outbreak.Controllers;

[Area("Outbreak")]
[Controller]
public class DocumentController(
    IOutbreakClient outbreakClient,
    ITokenService tokenService,
    ISpreadsheetValidatorFactory spreadsheetValidatorFactory,
    ILogger<OutbreakPageController> logger)
    : BaseController(logger, tokenService)
{
    public async Task<IActionResult> Display(long idfOutbreakNote)
    {
        return await GetNoteFile(idfOutbreakNote, "inline");
    }

    public async Task<IActionResult> Download(long idfOutbreakNote)
    {
        return await GetNoteFile(idfOutbreakNote, "attachment");
    }

    private async Task<IActionResult> GetNoteFile(long idfOutbreakNote, string contentDispositionHeaderValue)
    {
        var request = new OutbreakNoteRequestModel
        {
            idfOutbreakNote = idfOutbreakNote
        };

        List<OutbreakNoteFileResponseModel> response = await outbreakClient.GetNoteFile(request);

        var uploadFileName = response[0].UploadFileName;

        var cd = new System.Net.Http.Headers.ContentDispositionHeaderValue(contentDispositionHeaderValue)
        {
            FileNameStar = uploadFileName
        };

        Response.Headers.Append(HeaderNames.ContentDisposition, cd.ToString());

        var extension = Path.GetExtension(uploadFileName);
        var mimeType = GetMimeType(extension);

        var fileData = response[0].UploadFileObject;
        var validator = spreadsheetValidatorFactory.GetValidator(extension);
        var outputData = validator != null ? await validator.CleanUp(fileData) : fileData;

        return File(outputData, mimeType);
    }

    private static string GetMimeType(string extension)
    {
        return extension switch
        {
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".xls" => "application/vnd.ms-excel",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ".ppt" => "application/vnd.ms-powerpoint",
            ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            ".jpeg" => "image/jpeg",
            ".jpg" => "image/jpeg",
            ".png" => "image/png",
            ".pdf" => "application/pdf",
            ".txt" => "text/plain",
            ".csv" => "text/csv",
            _ => string.Empty,
        };
    }
}
