#region Usings

using EIDSS.Localization.Contexts;
using EIDSS.Localization.Interfaces;
using EIDSS.Localization.Models;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.String;

#endregion

namespace EIDSS.Localization.Providers
{
    public class LocalizationMemoryCacheProvider
    {
        #region Globals

        #region Member Variables

        private readonly IMemoryCache _memoryCache;
        private readonly List<string> _cachedItems;
        private readonly LocalizationContext _localizationContext;
        private USP_GBL_Languages_GETListResult _defaultLanguage;
        private IReadOnlyDictionary<long, USP_GBL_Resource_GETListResult> _resourceDictionary;

        #endregion

        #region Properties

        public string InstanceId { get; set; }

        public USP_GBL_Languages_GETListResult DefaultLanguage
        {
            get
            {
                return _defaultLanguage ??=
                    GetAllLanguages().First(k => k.IsDefaultLanguage != null && (bool) k.IsDefaultLanguage);
            }
            set => _defaultLanguage = value;
        }

        public IReadOnlyDictionary<long, USP_GBL_Resource_GETListResult> ResourceDictionary
        {
            get
            {
                return _resourceDictionary ??=
                    GetList<USP_GBL_Resource_GETListResult>()
                        .ToDictionary(x => x.ResourceID, x => x);
            }
            set => _resourceDictionary = value;
        }

        #endregion

        #endregion

        #region Constructors

        public LocalizationMemoryCacheProvider(IMemoryCache memoryCache, LocalizationContext serviceProvider)
        {
            _memoryCache = memoryCache;
            _cachedItems = new List<string>();
            _localizationContext = serviceProvider;
            InstanceId = Guid.NewGuid().ToString("N");
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <param name="key"></param>
        /// <param name="cacheProviderOption"></param>
        /// <returns></returns>
        private async Task SetKey(string key, LocalizationMemoryCacheProviderOptions cacheProviderOption = null)
        {
            var procedures = new LocalizationContextProcedures(_localizationContext);
            var defaultLocalizationCacheProviderOptions = new LocalizationMemoryCacheProviderOptions
            {
                Priority = CacheItemPriority.NeverRemove,
                AbsoluteExpiration = new DateTimeOffset(DateTime.Now.AddMinutes(30))
            };
            object value = null;
            var returnCode = new OutputParameter<int>();

            switch (key)
            {
                case nameof(USP_GBL_Languages_GETListResult):
                    var languages = procedures.USP_GBL_Languages_GETListAsync(Thread.CurrentThread.CurrentCulture.Name,
                        returnCode);
                    value = languages.Result;
                    break;
                case nameof(USP_GBL_Resource_GETListResult):
                    var resources = procedures.USP_GBL_Resource_GETListAsync(null, returnCode);
                    value = resources.Result;
                    break;
            }

            SetObject(key, value, cacheProviderOption ?? defaultLocalizationCacheProviderOptions);

            await Task.CompletedTask; 
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="cacheName"></param>
        /// <returns></returns>
        public object ReSetKey(object value, string cacheName)
        {
            if (value != null) return value;
            if (_cachedItems.Any(k => k == cacheName))
                _cachedItems.Remove(cacheName);

            Task.Run(() => SetKey(cacheName)).GetAwaiter().GetResult();
            value = _memoryCache.Get(cacheName);
            return value;
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="TEntity"></typeparam>
        /// <returns></returns>
        public List<TEntity> GetList<TEntity>()
        {
            var cacheName = typeof(TEntity).Name;
            var value = ReSetKey(_memoryCache.Get(cacheName), cacheName);
            return (List<TEntity>) value;
        }

        /// <summary>
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <param name="options"></param>
        /// <returns></returns>
        /// <exception cref="ArgumentNullException"></exception>
        public object SetObject(string key, object value, LocalizationMemoryCacheProviderOptions options)
        {
            if (IsNullOrEmpty(key)) throw new ArgumentNullException(nameof(key));

            if (value == null) throw new ArgumentNullException("Cache value is null");

            if (options == null) throw new ArgumentNullException(nameof(options));

            var entryOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpiration = options.AbsoluteExpiration,
                Priority = options.Priority,
                SlidingExpiration = options.SlidingExpiration
            };

            _memoryCache.Remove(key);
            _memoryCache.Set(key, value, entryOptions);
            _cachedItems.Add(key);

            return value;
        }

        /// <summary>
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public object GetObject(string key)
        {
            return ReSetKey(_memoryCache.Get(key), key);
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="key"></param>
        /// <returns></returns>
        public T GetObject<T>(string key)
        {
            return (T) GetObject(key);
        }

        /// <summary>
        /// </summary>
        /// <param name="key"></param>
        public void Remove(string key)
        {
            _memoryCache.Remove(key);
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="TEntity"></typeparam>
        /// <param name="id"></param>
        /// <returns></returns>
        public TEntity GetItem<TEntity>(long id) where TEntity : IModelKey<long>
        {
            return GetItem((TEntity e) => e.ID == id);
        }

        /// <summary>
        /// </summary>
        /// <typeparam name="TEntity"></typeparam>
        /// <param name="idSelector"></param>
        /// <returns></returns>
        public TEntity GetItem<TEntity>(Func<TEntity, bool> idSelector) where TEntity : IModelKey<long>
        {
            var list = GetList<TEntity>();
            return list.SingleOrDefault(idSelector);
        }

        #region Entity Cache Helper Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public List<USP_GBL_Languages_GETListResult> GetAllLanguages()
        {
            return GetList<USP_GBL_Languages_GETListResult>();
        }

        /// <summary>
        /// </summary>
        /// <param name="cultureName"></param>
        /// <returns></returns>
        public USP_GBL_Languages_GETListResult GetLanguage(string cultureName)
        {
            return GetAllLanguages().FirstOrDefault(k => k.CultureName == cultureName);
        }

        #endregion

        #endregion
    }
}