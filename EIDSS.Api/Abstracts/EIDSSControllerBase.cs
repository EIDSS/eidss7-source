using EIDSS.Api.ActionFilters;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;

namespace EIDSS.Api.Abstracts
{
    /// <summary>
    /// Base controller class
    /// </summary>
    [ApiController]
    [Authorize]
    public abstract class EIDSSControllerBase : ControllerBase
    {
        protected internal readonly IDataRepository _repository;
        protected internal IMemoryCache _cache;
        public EIDSSControllerBase(IDataRepository genericRepository, IMemoryCache memoryCache)
        {
            _repository = genericRepository;
            _cache = memoryCache;
        }

        /// <summary>
        /// Returns item T from the cache given the cachekey.
        /// If item isn't found, null is returned
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="cachekey"></param>
        /// <returns></returns>
        public T GetFromCache<T>(string cachekey)
        {
            T results;

            _cache.TryGetValue<T>(cachekey.ToLower(), out results);
            return results;

        }

        /// <summary>
        /// Addes an item to the cache if it doesn't already exist.
        /// </summary>
        /// <typeparam name="T">The type being added to the cache.</typeparam>
        /// <param name="cachekey">String that uniquely identifies the item being cached.</param>
        /// <param name="cachevalue">A instance of T to cache.</param>
        /// <param name="overrideIfExists"></param>
        /// <param name="neverRemove">This parameter is mutually exclusive to <paramref name="slidingExpirySeconds"/> and 
        /// <paramref name="absoluteExpirySeconds"/> and when set to true, the cached item will never be removed and those 
        /// parameters will be ignored.
        /// <param name="slidingExpirySeconds">Remove item from cache if it hasn't been accessed in n seconds.  Default is 30 seconds</param>
        /// <param name="absoluteExpirySeconds">Absolute</param>
        /// <returns></returns>
        public T SetCache<T>( string cachekey, T cachevalue, bool overrideIfExists, bool neverRemove = false, int? slidingExpirySeconds = 30, int? absoluteExpirySeconds = 60)
        {
            T results;

            if (_cache.TryGetValue<T>(cachekey.ToLower(), out results))
                return results;
            
            var cacheoptions = new MemoryCacheEntryOptions();

            if (neverRemove)
                cacheoptions.SetPriority(CacheItemPriority.NeverRemove);
            else
            {
                cacheoptions.SlidingExpiration = TimeSpan.FromSeconds((int)slidingExpirySeconds);
                cacheoptions.AbsoluteExpiration = 
                    new DateTimeOffset(DateTime.Now, TimeSpan.FromSeconds((int)absoluteExpirySeconds));

                if (absoluteExpirySeconds != null)
                    cacheoptions.SetAbsoluteExpiration(TimeSpan.FromSeconds((int)absoluteExpirySeconds));
            }
            // Set the object...
            results = _cache.Set(cachekey.ToLower(), cachevalue, cacheoptions);

            return results;

        }

    }
}
