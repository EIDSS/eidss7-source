using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Veterinary;
using Microsoft.AspNetCore.Http;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Veterinary
{
    [Route("api/Veterinary/VeterinaryActiveSurveillanceSession")]
    [ApiController]
    public partial class VeterinaryActiveSurveillanceSessionController : EIDSSControllerBase
    {
        public VeterinaryActiveSurveillanceSessionController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
