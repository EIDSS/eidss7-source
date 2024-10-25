using System.IO;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [Controller]
    public class DownloadController : ReportController
    {

        public DownloadController(IConfiguration configuration, ITokenService tokenService, ICrossCuttingClient crossCuttingClient, ILogger<ReportController> logger) : base(configuration, tokenService, crossCuttingClient, logger)
        {
        }


        [HttpGet]
        public ActionResult Index()
        {
            GetCurrentLanguage();


            string filePath = $"~/paperforms/{GetCurrentLanguage()}/{EIDSSConstants.PaperFormsFileName.HumanDiseaseInvestigationForm}" ;
            Response.Headers.Add("Content-Disposition", "inline; filename=test.pdf");
            return File(filePath, "application/pdf");
        }


        [HttpGet]
        public async Task<IActionResult> DownloadFile(string fileName)
        {
            if (string.IsNullOrEmpty(fileName) || fileName == null)
            {
                return Content("File Name is Empty...");
            }

            var currentLanguage = GetCurrentLanguage();
            var currentLanguageFolderPath = System.IO.Path.Combine(System.IO.Path.GetFullPath("wwwroot"), "paperforms", currentLanguage);
            var filePath = System.IO.Path.GetFullPath(System.IO.Path.Combine(currentLanguageFolderPath, fileName));
            if (!filePath.StartsWith(currentLanguageFolderPath))
            {
                return BadRequest($"Wrong file name path {fileName}");
            }

            // create a memorystream
            var memoryStream = new MemoryStream();

            await using (var stream = new FileStream(filePath, FileMode.Open))
            {
                await stream.CopyToAsync(memoryStream);
            }
            // set the position to return the file from
            memoryStream.Position = 0;


            return File(memoryStream, "application/pdf", System.IO.Path.GetFileName(filePath));
        }
    }
}
