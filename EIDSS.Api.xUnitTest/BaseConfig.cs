using EIDSS.Api.Helpers;
using EIDSS.Repository;
using EIDSS.Repository.Contexts;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Api.xUnitTest
{
    public class BaseConfig
    {
        public BaseConfig()
        {
            TestHost = CreateHostBuilder().Build();
            Task.Run(() => TestHost.RunAsync());
        }

        public IHost TestHost { get; }
        public EIDSSContext DBContext;

        public IHostBuilder CreateHostBuilder(string[] args = null)
        {
            var options = new DbContextOptionsBuilder<EIDSSContext>();
            options.UseInMemoryDatabase("EIDSSContext");
            DBContext = new EIDSSContext(options.Options);

            return Host.CreateDefaultBuilder(args)
                .ConfigureServices((hostContext, services) =>
                {
                    services.AddOptions();
                    services.AddSingleton(MapsterMapping.ModelMappingConfiguration());
                    services.AddSingleton(SecurityMappingProfile.SecurityMappingConfiguration());
                    services.AddScoped<IMapper, ServiceMapper>();

                });
        }
    }
}
