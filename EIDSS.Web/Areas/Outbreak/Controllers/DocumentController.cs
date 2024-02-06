using System;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using System.IO;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using System.Net.Http.Headers;
using Microsoft.Net.Http.Headers;

namespace EIDSS.Web.Areas.Outbreak.Controllers
{
    [Area("Outbreak")]
    [Controller]
    public class DocumentController : BaseController
    {
        public DocumentViewModel _documentViewModel;

        private readonly IOutbreakClient _OutbreakClient;

        public DocumentController(IOutbreakClient OutbreakClient, ITokenService tokenService, ILogger<OutbreakPageController> logger) : base(logger, tokenService)
        {
            _OutbreakClient = OutbreakClient;
            _documentViewModel = new DocumentViewModel();
        }

        public async Task<IActionResult> Display(long idfOutbreakNote)
        {
            OutbreakNoteRequestModel request = new OutbreakNoteRequestModel();
            request.idfOutbreakNote = idfOutbreakNote;

            List<OutbreakNoteFileResponseModel> response = await _OutbreakClient.GetNoteFile(request);
            //byte[] byteArray = response[0].UploadFileObject;

            var cd = new System.Net.Http.Headers.ContentDispositionHeaderValue("inline")
            {
                FileNameStar = response[0].UploadFileName
            };

            Response.Headers.Add(HeaderNames.ContentDisposition, cd.ToString());

            string strMimeType = string.Empty;
            string strExtension = response[0].UploadFileName.ToString();
            int iExtensionIndex = strExtension.LastIndexOf('.');
            
            strExtension = strExtension.Substring(iExtensionIndex);

            switch (strExtension)
            {
                case ".doc":
                    strMimeType = "application/msword";
                    break;
                case ".docx":
                    strMimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                    break;
                case ".xls":
                    strMimeType = "application/vnd.ms-excel";
                    break;
                case ".xlsx":
                    strMimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    break;
                case ".ppt":
                    strMimeType = "application/vnd.ms-powerpoint";
                    break;
                case ".pptx":
                    strMimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
                    break;
                case ".jpeg":
                    strMimeType = "image/jpeg";
                    break;
                case ".jpg":
                    strMimeType = "image/jpeg";
                    break;
                case ".png":
                    strMimeType = "image/png";
                    break;
                case ".pdf":
                    strMimeType = "application/pdf";
                    break;
                case ".txt":
                    strMimeType = "text/plain";
                    break;

            }
            return File(response[0].UploadFileObject, strMimeType);
        }

        public async Task<IActionResult> Download(long idfOutbreakNote)
        {
            OutbreakNoteRequestModel request = new OutbreakNoteRequestModel();
            request.idfOutbreakNote = idfOutbreakNote;

            List<OutbreakNoteFileResponseModel> response = await _OutbreakClient.GetNoteFile(request);
            //byte[] byteArray = response[0].UploadFileObject;

            var cd = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment")
            {
                FileNameStar = response[0].UploadFileName
            };

            Response.Headers.Add(HeaderNames.ContentDisposition, cd.ToString());

            return File(response[0].UploadFileObject, "application/pdf");
        }
    }
}
