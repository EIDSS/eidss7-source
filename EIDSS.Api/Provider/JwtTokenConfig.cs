using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{
    public class JwtTokenConfig
    {

        public const string JwtToken = "JwtToken";

        [JsonPropertyName("secret")]
        public string Secret { get; set; }

        [JsonPropertyName("validIssuer")]
        public string ValidIssuer { get; set; }

        [JsonPropertyName("validAudience")]
        public string ValidAudience { get; set; }

        [JsonPropertyName("accessTokenExpiration")]
        public int AccessTokenExpiration { get; set; }

        [JsonPropertyName("refreshTokenExpiration")]
        public int RefreshTokenExpiration { get; set; }
    }
}