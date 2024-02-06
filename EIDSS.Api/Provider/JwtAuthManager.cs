using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Text.Json.Serialization;
using System.Security.Cryptography;
using System.Collections.Concurrent;
using System.Text;
using Microsoft.Extensions.Options;

namespace EIDSS.Api.Provider
{
    public interface IJwtAuthManager
    {
        IImmutableDictionary<string, RefreshToken> UsersRefreshTokensReadOnlyDictionary { get; }
        JwtAuthResult GenerateToken(string username, Claim[] claims, DateTime now);
        JwtAuthResult Refresh(string refreshToken, string accessToken, DateTime now,List<Claim> claims);
        void RemoveExpiredRefreshTokens(DateTime now);
        void RemoveRefreshTokenByUserName(string userName);
        (ClaimsPrincipal, JwtSecurityToken) DecodeJwtToken(string token);
    }
    public class JwtAuthManager : IJwtAuthManager
    {
        public IImmutableDictionary<string, RefreshToken> UsersRefreshTokensReadOnlyDictionary => _usersRefreshTokens.ToImmutableDictionary();
        private readonly ConcurrentDictionary<string, RefreshToken> _usersRefreshTokens;  
        private readonly JwtTokenConfig _jwtTokenConfig; 
        private readonly byte[] _secret;

        public JwtAuthManager(IOptions<JwtTokenConfig> jwtTokenConfig)
        {
            _jwtTokenConfig = jwtTokenConfig.Value;
            _usersRefreshTokens = new ConcurrentDictionary<string, RefreshToken>();
            _secret = Encoding.ASCII.GetBytes(_jwtTokenConfig.Secret);
        }

        public void RemoveExpiredRefreshTokens(DateTime now)
        {
            var expiredTokens = _usersRefreshTokens.Where(x => x.Value.ExpireAt < now).ToList();
            foreach (var expiredToken in expiredTokens)
            {
                _usersRefreshTokens.TryRemove(expiredToken.Key, out _);
            }
        }

        public void RemoveRefreshTokenByUserName(string userName)
        {
            var refreshTokens = _usersRefreshTokens.Where(x => x.Value.UserName == userName).ToList();
            foreach (var refreshToken in refreshTokens)
            {
                _usersRefreshTokens.TryRemove(refreshToken.Key, out _);
            }
        }

        public JwtAuthResult GenerateToken(string username, Claim[] claims, DateTime now)
        {
            DateTime tokenExpiryDate=Convert.ToDateTime(claims.FirstOrDefault(t => t.Type == "ExpireDate")?.Value);

            var jwtToken = new JwtSecurityToken(
                issuer: _jwtTokenConfig.ValidIssuer,
                audience: _jwtTokenConfig.ValidAudience,
                claims: claims,
                notBefore: new DateTimeOffset(DateTime.Now).DateTime,
                expires: tokenExpiryDate,
                signingCredentials: new SigningCredentials(new SymmetricSecurityKey(_secret), SecurityAlgorithms.HmacSha256Signature));

            var refreshToken = new RefreshToken
            {
                UserName = username,
                TokenString = GenerateRefreshTokenString(),
                ExpireAt = jwtToken.ValidTo
            };

            _usersRefreshTokens.AddOrUpdate(refreshToken.TokenString, refreshToken, (_, _) => refreshToken);




            return new JwtAuthResult
            {
                JwtToken = jwtToken,
                RefreshToken = refreshToken
            };
        }

        public JwtAuthResult Refresh(string refreshToken, string accessToken, DateTime now, List<Claim> claims)
        {
            var (principal, jwtToken) = DecodeJwtToken(accessToken);
            if (jwtToken == null || !jwtToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256Signature))
            {
                throw new SecurityTokenException("Invalid token");
            }

            var userName = principal.Identity?.Name;

            return GenerateToken(userName, claims.ToArray(), now); // need to recover the original claims
        }

        public (ClaimsPrincipal, JwtSecurityToken) DecodeJwtToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
            {
                throw new SecurityTokenException("Invalid token");
            }
            var principal = new JwtSecurityTokenHandler()
                .ValidateToken(token,
                    new TokenValidationParameters
                    {
                        
                        ValidateIssuer = false,
                        ValidIssuer = _jwtTokenConfig.ValidIssuer,
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(_secret),
                        ValidAudience = _jwtTokenConfig.ValidAudience,
                        ValidateAudience = false,
                        ValidateLifetime = false,
                        ClockSkew = TimeSpan.Zero
                    },
                    out var validatedToken);
            return (principal, validatedToken as JwtSecurityToken);
        }

        private static string GenerateRefreshTokenString()
        {
            var randomNumber = new byte[32];
            using var randomNumberGenerator = RandomNumberGenerator.Create();
            randomNumberGenerator.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }

    public class JwtAuthResult
    {
        [JsonPropertyName("jwtToken")]
        public JwtSecurityToken JwtToken { get; set; }

        [JsonPropertyName("refreshToken")]
        public RefreshToken RefreshToken { get; set; }
    }

    public class AccessToken
    {
        [JsonPropertyName("username")]
        public string UserName { get; set; }    

        [JsonPropertyName("tokenString")]
        public string TokenString { get; set; }

        [JsonPropertyName("validTo")]
        public DateTime ValidTo { get; set; }
    }


    public class RefreshToken
    {
        [JsonPropertyName("username")]
        public string UserName { get; set; }   

        [JsonPropertyName("tokenString")]
        public string TokenString { get; set; }

        [JsonPropertyName("expireAt")]
        public DateTime ExpireAt { get; set; }
    }
}