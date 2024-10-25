using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Administration;

[Route("api/Administration/Organization")]
[ApiController]
[Tags("Administration - Organizations")]
public class OrganizationController : EIDSSControllerBase
{
    public OrganizationController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
    {
    }

    [HttpPost("GetOrganizationList")]
    public async Task<ActionResult<List<OrganizationGetListViewModel>>> GetOrganizationList([FromBody] OrganizationGetRequestModel request, CancellationToken cancellationToken = default)
    {
        var arguments = new object[]
        {
            request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder,
            request.OrganizationKey, request.OrganizationID, request.AbbreviatedName, request.FullName,
            request.AccessoryCode, request.SiteID, request.AdministrativeLevelID, request.OrganizationTypeID,
            request.ShowForeignOrganizationsIndicator, null, cancellationToken
        };
        var results = await ExecuteOnRepository<USP_ADMIN_ORG_GETListResult, OrganizationGetListViewModel>(arguments);
        return Ok(results);
    }
    [HttpPost("GetAdvancedOrganizationList")]
    public async Task<ActionResult<List<OrganizationAdvancedGetListViewModel>>> GetAdvancedOrganizationList([FromBody] OrganizationAdvancedGetRequestModel request, CancellationToken cancellationToken = default)
    {
        var arguments = new object[]
        {
            request.LangID, request.SiteFlag, request.AccessoryCode, request.OrganizationTypeID, request.AdvancedSearch,
            request.RowStatus, request.LocationID, null, cancellationToken
        };
        var results = await ExecuteOnRepository<USP_GBL_LKUP_ORG_GETListResult, OrganizationAdvancedGetListViewModel>(arguments);
        return Ok(results);
    }

    [HttpGet("GetOrganizationDetail")]
    public async Task<ActionResult<OrganizationGetDetailViewModel>> GetOrganizationDetail(string languageID, long organizationID, CancellationToken cancellationToken = default)
    {
        var arguments = new object[] { languageID, organizationID, null, cancellationToken };
        var results = await ExecuteOnRepository<USP_ADMIN_ORG_GETDetailResult, OrganizationGetDetailViewModel>(arguments);
        return Ok(results.FirstOrDefault());
    }

    [HttpPost("SaveOrganization")]
    public async Task<ActionResult<APISaveResponseModel>> SaveOrganization([FromBody] OrganizationSaveRequestModel request, CancellationToken cancellationToken = default)
    {
        var arguments = new object[] { request, null, cancellationToken };
        var results = await ExecuteOnRepository<USP_ADMIN_ORG_SETResult, APISaveResponseModel>(arguments);
        return Ok(results.FirstOrDefault());
    }

    [HttpDelete("DeleteOrganization")]
    public async Task<ActionResult<APIPostResponseModel>> DeleteOrganization(long organizationID, string auditUserName, CancellationToken cancellationToken = default)
    {
        var arguments = new object[] { organizationID, auditUserName, null, cancellationToken };
        var results = await ExecuteOnRepository<USP_ADMIN_ORG_DELResult, APIPostResponseModel>(arguments);
        return Ok(results.FirstOrDefault());
    }

    [HttpPost("GetDepartmentList")]
    public async Task<ActionResult<List<DepartmentGetListViewModel>>> GetDepartmentList([FromBody] DepartmentGetRequestModel request, CancellationToken cancellationToken = default)
    {
        var arguments = new object[]
        {
            request.LanguageId, request.OrganizationID, request.DepartmentID, request.Page, request.PageSize,
            request.SortColumn, request.SortOrder, null, cancellationToken
        };
        var results = await ExecuteOnRepository<USP_GBL_Department_GetListResult, DepartmentGetListViewModel>(arguments);
        return Ok(results);
    }
        
    [HttpGet("Search")]
    public async Task<ActionResult<List<OrganizationGetSearchModelResult>>> SearchOrganizations([FromQuery] OrganizationGetSearchModel request, CancellationToken cancellationToken = default)
    {
        var arguments = new object[]
        {
            request.LanguageId, request.PageNumber, request.PageSize, request.SortColumn, request.SortOrder, request.FilterValue,
            request.AccessoryCode, null, cancellationToken
        };
        var results = await ExecuteOnRepository<USP_GBL_ORG_GETSearchResult, OrganizationGetSearchModelResult>(arguments);
        return Ok(results);
    }
}