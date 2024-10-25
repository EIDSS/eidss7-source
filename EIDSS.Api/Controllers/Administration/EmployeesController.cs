using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using EIDSS.CodeGenerator;
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
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Api.ActionFilters;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.ResponseModels.Administration;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Admin/Employees")]
    [ApiController]
    public partial class EmployeesController : EIDSSControllerBase
    {

        public EmployeesController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
