using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using EIDSS.Domain.ResponseModels;
using Microsoft.AspNetCore.Http;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Configuration
{
    [Route("api/FlexForm")]
    [ApiController]
    public partial class FlexFormController : EIDSSControllerBase
    {
        /// <summary>
        /// Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        public FlexFormController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
