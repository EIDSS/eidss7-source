using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.Repositories;
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
using MapsterMapper;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Configuration
{
    [Route("api/Configuration/DiseaseLabTest")]
    [ApiController]
    public partial class DiseaseLabTestMatrixController : EIDSSControllerBase
    {
        public DiseaseLabTestMatrixController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }
    }
}
