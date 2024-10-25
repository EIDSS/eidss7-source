using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.ViewModels;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Provider;
using EIDSS.Repository.Contexts;
using MapsterMapper;
using Swashbuckle.AspNetCore.Annotations;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers
{
    /// <summary>
    /// 
    /// </summary>
     [Route("api/Menu")]
    [ApiController]
    //[Authorize]
    public partial class MenuController : EIDSSControllerBase
    {
        public EidssArchiveContext _eidssArchiveContext { get; set; }
        private readonly IMapper _mapper;
        /// <summary>
        /// Creates a new instance of the class.
        /// </summary>
        /// <param name="repository"></param>
        /// <param name="memoryCache"></param>
        /// <param name="eidssArchiveContext"></param>
        public MenuController(IDataRepository repository, IMemoryCache memoryCache , EidssArchiveContext eidssArchiveContext,IMapper mapper) : base(repository, memoryCache)
        {
            _eidssArchiveContext = eidssArchiveContext;
            _mapper = mapper;
        }
         
        /// <summary>
        /// Retrieves a list of Personal Identification types 
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetMenuList")]
        [ProducesResponseType(typeof(List<MenuViewModel>),StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MenuViewModel>),StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MenuViewModel>),StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult> GetMenuList(long? userId, string languageID, long? employeeID, bool isConnectToArchive, CancellationToken cancellationToken)
        {
            List<MenuViewModel> results = null;
            try
            {
                //results = await _administrationRepository.GetVectorTypeListAsync(langID, strSearchVectorType, cancellationToken);
                DataRepoArgs args = new()
                {
                    Args = new object[] { userId, languageID, employeeID ,null, cancellationToken },
                    MappedReturnType = typeof(List<MenuViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_MENU_GETListResult>)
                };

                results = await _repository.Get(args) as List<MenuViewModel>;

            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();


        }

        /// <summary>
        /// Retrieves Menu by Logged in User
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetMenuByUserList")]
        [ProducesResponseType(typeof(List<MenuByUserViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<MenuByUserViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<MenuByUserViewModel>), StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult> GetMenuByUserList(long? userId, string languageID, long? employeeID,bool isConnectToArchive, CancellationToken cancellationToken)
        {
            List<MenuByUserViewModel> results = null;
            try
            {
                DbContextFactory.Connect(isConnectToArchive ? "EIDSSARCHIVE": "EIDSS");
                var menuByUserGetListResults = await _eidssArchiveContext.Procedures.USP_GBL_MENU_ByUser_GETListAsync(userId, languageID,
                    employeeID, null, cancellationToken);

                //DataRepoArgs args = new()
                //{
                //    Args = new object[] { userId, languageID, employeeID, null, cancellationToken },
                //    MappedReturnType = typeof(List<MenuByUserViewModel>),
                //    RepoMethodReturnType = typeof(List<USP_GBL_MENU_ByUser_GETListResult>)
                //};

                results = (List<MenuByUserViewModel>)_mapper.Map(menuByUserGetListResults, typeof(List<USP_GBL_MENU_ByUser_GETListResult>), typeof(List<MenuByUserViewModel>));


            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();


        }


    }
}
