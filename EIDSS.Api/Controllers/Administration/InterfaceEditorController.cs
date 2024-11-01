﻿using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

// Below usings are used in Generated Code
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Administration/InterfaceEditor")]
    [ApiController]
    public partial class InterfaceEditorController : EIDSSControllerBase
    {
        private readonly IOptionsSnapshot<XSiteConfigurationOptions> _xsiteOptions;

        public InterfaceEditorController(
            IDataRepository repository,
            IOptionsSnapshot<XSiteConfigurationOptions> options,
            IMemoryCache memoryCache)
            : base(repository, memoryCache)
        {
            _xsiteOptions = options;
        }

        [HttpPost("UploadLanguageTranslation")]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status409Conflict)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APIPostResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Uploads a language file to create a new set of language translations.", Tags = new[] { "Administration - Other Editors" })]
        public async Task<IActionResult> UploadLanguageTranslation([FromForm] InterfaceEditorLangaugeFileSaveRequestModel model, CancellationToken cancellationToken = default)
        {
            APIPostResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                //check to see if the language already exists and return a 409 conflict result if so
                var crossCuttingApi = new CrossCuttingController(_repository, _xsiteOptions, _cache);
                var crossCuttingGetResponse = await crossCuttingApi.GetLanguageListAsync(model.CurrentLangId);
                var crossCuttingGetResult = crossCuttingGetResponse as ObjectResult;
                var crossCuttingValueGetResults = crossCuttingGetResult.Value as List<LanguageModel>;
                if (crossCuttingValueGetResults.Where(l => l.DisplayName == model.LanguageName).FirstOrDefault() != null)
                {
                    return Conflict(new APIPostResponseModel()
                    {
                        ReturnCode = 1,
                        ReturnMessage = "DOES EXIST",
                        StrDuplicateField = crossCuttingValueGetResults.FirstOrDefault().CultureName
                    });
                }
                //add the new language to base references
                else
                {

                    var interfaceEditorLanguageSaveRequest = new InterfaceEditorLanguageSaveRequestModel()
                    {
                        DefaultName = model.LanguageName,
                        NationalName = model.LanguageName,
                        Order = 0,
                        HACode = 0,
                        ReferenceType = 19000049,
                        strReferenceCode = model.LanguageCode,
                        LangId = model.CurrentLangId
                    };
                    var interfaceEditorLanguageSaveResponse = await SaveInterfaceEditorLanguage(interfaceEditorLanguageSaveRequest);
                    var interfaceEditorLanguageSaveResult = interfaceEditorLanguageSaveResponse as ObjectResult;
                    var interfaceEditorLanguageSaveResults = interfaceEditorLanguageSaveResult.Value as APIPostResponseModel;
                    if (interfaceEditorLanguageSaveResults.ReturnMessage != "SUCCESS")
                    {
                        return BadRequest(new APIPostResponseModel()
                        {
                            ReturnCode = 1,
                            ReturnMessage = interfaceEditorLanguageSaveResults.ReturnMessage
                        });
                    }
                }

                // process the language file
                var filePath = Path.GetRandomFileName();

                if (model.LanguageFile.Length > 0)
                {
                    using var stream = System.IO.File.Create(filePath);
                    await model.LanguageFile.CopyToAsync(stream);
                    stream.Position = 0;
                    using var reader = new StreamReader(stream, System.Text.Encoding.UTF8, true);
                    string languageString;
                    // header row
                    languageString = await reader.ReadLineAsync();
                    // first line
                    languageString = await reader.ReadLineAsync();

                    while (languageString != null)
                    {
                        string[] languageRecord = languageString.Split(',');

                        // just call the save method for lines with translations
                        if (!string.IsNullOrEmpty(languageRecord[6]))
                        {
                            var request = new InterfaceEditorResourceSaveRequestModel()
                            {
                                idfsResourceSet = long.Parse(languageRecord[0]),
                                idfsResource = long.Parse(languageRecord[1]),
                                DefaultName = languageRecord[5],
                                NationalName = languageRecord[6],
                                isHidden = false,
                                isRequired = false,
                                User = model.User,
                                LanguageId = model.LanguageCode
                            };
                            var response = await SaveInterfaceEditorResource(request, cancellationToken);
                        }

                        languageString = await reader.ReadLineAsync();
                    }
                }
                else
                {
                    results = new APIPostResponseModel()
                    {
                        ReturnCode = 1,
                        ReturnMessage = "NO FILE PROVIDED"

                    };

                    return BadRequest(results);
                }

                results = new APIPostResponseModel()
                {
                    ReturnCode = 0,
                    ReturnMessage = "SUCCESS"
                };
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

