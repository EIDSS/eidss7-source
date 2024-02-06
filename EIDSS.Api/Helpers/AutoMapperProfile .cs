using EIDSS.Api.Models;
using EIDSS.Api.Providers;
using EIDSS.Domain.ViewModels;
using EIDSS.Repository.ReturnModels;
using Mapster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Helpers
{

    /// <summary>
    /// ApplicationUser Mapster model mapping profile.
    /// </summary>
    public class SecurityMappingProfile
    {
        public static TypeAdapterConfig SecurityMappingConfiguration()
        {
            // Set case insensitivity for all mappings...
            TypeAdapterConfig.GlobalSettings.Default.NameMatchingStrategy(NameMatchingStrategy.IgnoreCase);

            var config = TypeAdapterConfig.GlobalSettings;

            config.NewConfig<ApplicationUser, UserViewModel>()
                .TwoWays();

            return config;
        }
    }
}