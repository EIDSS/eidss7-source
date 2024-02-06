using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using Microsoft.AspNetCore.Http;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Dashboard;
using EIDSS.Domain.RequestModels.Dashboard;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Api.Controllers.Dashboard
{
    [Route("api/Dashboard")]
    [ApiController]
    public partial class DashboardController : EIDSSControllerBase
    {
        public DashboardController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
