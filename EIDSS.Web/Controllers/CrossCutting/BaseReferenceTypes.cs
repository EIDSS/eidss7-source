using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.ViewModels;
using Microsoft.Extensions.Logging;
using EIDSS.Web.Abstracts;

namespace EIDSS.Web.Controllers.CrossCutting
{
    
    public class BaseReferenceTypes : BaseController
    {
        ICrossCuttingClient _crossCuttingClient;
        

        public BaseReferenceTypes(ICrossCuttingClient crossCuttingClient, ILogger logger) : base(logger)
        {
            _crossCuttingClient = crossCuttingClient;
        }
        public IActionResult Index()
        {
            return View();
        }

 
       
    }
}
