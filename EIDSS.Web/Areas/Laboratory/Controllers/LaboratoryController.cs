#region Usings

using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Laboratory.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

#endregion

namespace EIDSS.Web.Areas.Laboratory.Controllers
{
    [Area("Laboratory")]
    [Controller]
    public class LaboratoryController : BaseController
    {
        #region Globals

        #endregion

        #region Constructors

        public LaboratoryController(ITokenService tokenService, ILogger<LaboratoryController> logger) :
            base(logger, tokenService)
        {
        }

        #endregion

        #region Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult Samples()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.Samples));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult Transferred()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.Transferred));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult Testing()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.Testing));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult Batches()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.Batches));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult Approvals()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.Approvals));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public IActionResult MyFavorites()
        {
            return View("Laboratory", Initialize(LaboratoryTabEnum.MyFavorites));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="tab"></param>
        /// <returns></returns>
        private static LaboratoryViewModel Initialize(LaboratoryTabEnum tab)
        {
            LaboratoryViewModel model = new() { Tab = tab };

            return model;
        }

        #endregion
    }
}