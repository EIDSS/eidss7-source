using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{

    public interface IjwJwtAuthManager
    {
        void ParseToken(string token);
    }

    public class jwJwtAuthManager : IjwJwtAuthManager
    {
        public void ParseToken(string token)
        {
            var handler = new JwtSecurityTokenHandler();
            var jsonToken = handler.ReadToken(token);

            


           
        }


    }
}
