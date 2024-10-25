using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.ResponseModels.CrossCutting;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.CrossCutting
{
    [Route("api/CrossCutting/AggregateReport")]
    [ApiController]
    public partial class AggregateReportController : EIDSSControllerBase
    {
        public AggregateReportController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
