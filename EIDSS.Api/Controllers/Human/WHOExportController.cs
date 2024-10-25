using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.ViewModels;
using EIDSS.Repository.Repositories;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels.Human;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;

namespace EIDSS.Api.Controllers.Human
{
    [Microsoft.AspNetCore.Mvc.Route("api/Human/WHOExport")]
    [ApiController]
    public partial class WHOExportController : EIDSSControllerBase
    {
        public WHOExportController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
