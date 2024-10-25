using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Serilog;

namespace EIDSS.Api.Abstracts
{
    [ApiController]
    [Authorize]
    [RequireHttps]
    public abstract class EIDSSControllerBase : ControllerBase
    {
        protected readonly IDataRepository _repository;
        protected IMemoryCache _cache;
        
        public EIDSSControllerBase(IDataRepository genericRepository, IMemoryCache memoryCache)
        {
            _repository = genericRepository;
            _cache = memoryCache;
        }

        protected async Task<List<TApiResult>> ExecuteOnRepository<TDbResult, TApiResult>(object[] procedureArguments)
        {
            try
            {
                DataRepoArgs args = new()
                {
                    Args = procedureArguments,
                    MappedReturnType = typeof(List<TApiResult>),
                    RepoMethodReturnType = typeof(List<TDbResult>)
                };

                return await _repository.Get(args) as List<TApiResult>;
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }
        }

    }
}
