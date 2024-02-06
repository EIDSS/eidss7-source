#region Usings

using System;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Veterinary.ViewModels.Farm;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

#endregion

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class FarmController : BaseController
    {
        private new readonly ILogger<FarmController> _logger;

        public FarmController(ITokenService tokenService,
            ILogger<FarmController> logger) : base(logger, tokenService)
        {
            _logger = logger;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public IActionResult Index(bool refresh = false)
        {
            return View(refresh);
        }

        #region Farm Details

        /// <summary>
        /// </summary>
        /// <param name="id"></param>
        /// <param name="isEdit"></param>
        /// <param name="isReadOnly"></param>
        /// <returns></returns>
        public IActionResult Details(long? id, bool isEdit = false, bool isReadOnly = false)
        {
            try
            {
                FarmDetailsViewModel model = new()
                {
                    IsReadonly = isReadOnly,
                    FarmMasterID = id
                };

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}