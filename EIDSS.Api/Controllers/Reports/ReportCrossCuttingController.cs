using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Domain.RequestModels.Reports;
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

namespace EIDSS.Api.Controllers.Reports
{
    [Route("api/Reports/ReportCrossCutting")]
    [ApiController]
    public partial class ReportCrossCuttingController : EIDSSControllerBase
    {
        public ReportCrossCuttingController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}