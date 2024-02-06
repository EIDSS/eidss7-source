using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.ActionFilters;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.Repositories;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using Mapster;
using MapsterMapper;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Configuration
{
    [Route("api/Configuration/PersonalIdentificationTypeMatrix")]
    [ApiController]
    public partial class PersonalIdentificationTypeMatrixController : EIDSSControllerBase
    {
        public PersonalIdentificationTypeMatrixController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }
    }
}
