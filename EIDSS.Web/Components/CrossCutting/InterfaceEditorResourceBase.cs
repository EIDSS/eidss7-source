#region Usings

using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;

#endregion

namespace EIDSS.Web.Components.CrossCutting
{
    public class InterfaceEditorResourceBase : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private IServiceProvider ServiceProvider { get; set; }

        #endregion

        #region Parameters

        [Parameter] public string InterfaceEditorKey { get; set; }

        [Parameter] public bool IsRow { get; set; }

        [Parameter] public string CssClass { get; set; }

        [Parameter] public string For { get; set; }

        [Parameter] public bool? IsRequiredByDefaultBusinessRule {get;set;}

        [Parameter] public RenderFragment ChildContent { get; set; }
        
        [Parameter] public bool IsLabelHidden { get; set; }

        #endregion

        #region Member Variables

        private LocalizationMemoryCacheProvider _cacheProvider;

        #endregion

        #endregion

        #region Methods

        public bool IsHidden()
        {
            _cacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

            var dontRender = _cacheProvider.GetHiddenResourceValueByLanguageCultureNameAndResourceKey(GetCurrentLanguage(), InterfaceEditorKey);

            // If hidden resource value is set to true, then do not render the content.
            if (dontRender == null) return false;
            return dontRender.ToLower() == LocalizationGlobalConstants.TrueResourceValue;
        }

        public bool IsRequired()
        {
            if (IsRequiredByDefaultBusinessRule == null)
            {
                _cacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

                var dontRender = _cacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(GetCurrentLanguage(), InterfaceEditorKey);

                // If required resource value is set to true, then do not render the content.
                if (dontRender == null) return false;
                return dontRender.ToLower() == LocalizationGlobalConstants.TrueResourceValue;
            }
            else
                return (bool)IsRequiredByDefaultBusinessRule;
        }

        #endregion
    }
}
