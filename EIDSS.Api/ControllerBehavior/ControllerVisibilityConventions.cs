using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using Microsoft.AspNetCore.Mvc.Diagnostics;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;

namespace EIDSS.Api.ControllerBehavior
{
    /// <summary>
    /// Hides  various security controller api methods.
    /// </summary>
    public class ControllerVisibilityConventions : IActionModelConvention
    {
        private bool _hideAllControllers { get; set; }

        private ControllerVisibilitySettings _settings;

        private ControllerVisibilityConventions(IConfiguration configuration)
        {
            var controllervisibilitySection = configuration.GetSection("ControllerVisibilityBehaviors");
            _settings = controllervisibilitySection.Get<ControllerVisibilitySettings>();

            _hideAllControllers = _settings.HideAllControllers;
        }
        
        public void Apply(ActionModel action)
        {
            List<string> excludedcontrollers = new();

            if (!_hideAllControllers) return;

            action.ApiExplorer.IsVisible =
                _settings.ControllerVisibilityOverrides.Contains(action.Controller.ControllerName, StringComparer.OrdinalIgnoreCase) ||
                excludedcontrollers.Contains(action.ActionName, StringComparer.OrdinalIgnoreCase);
        }
    }
}
