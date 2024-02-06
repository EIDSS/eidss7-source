using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
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
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Human
{
    [Route("api/Human/HumanActiveSurveillanceCampaign")]
    [ApiController]
    public partial class HumanActiveSurveillanceCampaignController : EIDSSControllerBase
    {
        public HumanActiveSurveillanceCampaignController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
    }
}
