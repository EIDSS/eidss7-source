using System;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Api.Providers;
using EIDSS.Repository.Connections;
using EIDSS.Repository.Contexts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace EIDSS.Api.Provider
{
    public class DbContextObject
    {
        public ApplicationDbContext ApplicationDbContext { get; set; }
        public EIDSSContext EidssContext { get; set; }
    }

    public static class DbContextFactory
    {
        public static Dictionary<string, string> ConnectionStrings { get; set; }

        public static bool IsConnectToArchive { get; set; }

        private static IServiceCollection _services;

        public static void SetConnectionString(Dictionary<string, string> connStrings,  IServiceCollection services)
        {
            ConnectionStrings = connStrings;
            _services = services;
        }

        public static void Connect(string connId)
        {
            if (!string.IsNullOrEmpty(connId))
            {
                
                _services.AddDbContext<EIDSSContext>();
                
                DbManager.connectionString = ConnectionStrings[connId];

                _services
                    .AddDbContext<ApplicationDbContext>(options =>
                    {
                        var connection = ConnectionStrings["EIDSS"];
                        options.UseSqlServer(connection);

                    });

                _services
                    .AddDbContext<EidssArchiveContext>(options => 
                    {
                        var connection = ConnectionStrings["EIDSS"];
                        options.UseSqlServer(connection);
                    });

            }
            else
            {
                throw new ArgumentNullException("ConnectionId");
            }
        }

    }
}
