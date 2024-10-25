using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Administration/Notification")]
    [ApiController]
    public partial class NotificationController : EIDSSControllerBase
    {
        public NotificationController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }
    }
}
