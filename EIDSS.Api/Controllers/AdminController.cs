using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers
{
    [Route("api/Admin")]
    [ApiController]
    public partial class AdminController : EIDSSControllerBase
    {
        private readonly SignInManager<ApplicationUser> signInManager;
        private readonly UserManager<ApplicationUser> userManager;
        private readonly RoleManager<IdentityRole> roleManager;
        private readonly IConfiguration _configuration;
        private readonly IPermissionService _permissionService;
        private readonly IJwtAuthManager _jwtAuthManager;
        private readonly IPasswordValidator<ApplicationUser> _passwordValidator;
        private readonly IUserValidator<ApplicationUser> _userValidator;
        private IdentityOptions _options;
        private EIDSSContextProcedures _context;

        public AdminController(UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            IDataRepository genericRepository,
            IPermissionService permissionService,
            IJwtAuthManager jwtAuthManager,
            IPasswordValidator<ApplicationUser> passwordValidator,
            IUserValidator<ApplicationUser> userValidator,
            IOptions<IdentityOptions> options,
            EIDSSContextProcedures context,
            IMemoryCache memoryCache
            ) : base(genericRepository, memoryCache)
        {
            this.userManager = userManager;
            this.roleManager = roleManager;
            this.signInManager = signInManager;
            _configuration = configuration;
            _permissionService = permissionService;
            _jwtAuthManager = jwtAuthManager;
            _passwordValidator = passwordValidator;
            _userValidator = userValidator;
            _options = options.Value;
            _context = context;
        }

        ///// <summary>
        ///// Login
        ///// </summary>
        ///// <param name="model"></param>
        ///// <returns></returns>
        [HttpPost]
        [Route("Apilogin")]
        [SwaggerOperation(
            Summary = "Provides log in capabilities",
            Tags = new[] { "Administration - Users" })]
        [AllowAnonymous]
        public async Task<IActionResult> Apilogin([FromBody] LoginViewModel model)
        {
            var user = await userManager.FindByNameAsync(model.Username);
            var userWithPassHistory = await userManager.Users.Include(x => x.PasswordHistory).FirstOrDefaultAsync(x => x.NormalizedUserName == model.Username);

            if (user == null)
            {
                return Ok(new LoginResponseViewModel
                {
                    Status = false,
                    Message = "User does not exist"
                });
            }
            if (user.blnDisabled != null)
            {
                if (user.blnDisabled.Value)
                {
                    var errors = new List<string>();
                    errors.Add("This user account is disabled. Contact your helpdesk for assistance.");
                    return Ok(new LoginResponseViewModel
                    {
                        Status = false,
                        Message = "DISABLED",
                        Errors = errors
                    });
                }
            }

            Microsoft.AspNetCore.Identity.SignInResult signInResult = await signInManager.PasswordSignInAsync(user, model.Password, true, true);
            if (signInResult.IsLockedOut)
            {
                await userManager.SetLockoutEnabledAsync(user, true);
                var errors = new List<string>();
                errors.Add("You have exceeded the allowed number of login attempts. You may contact your Help Desk for assistance.");
                return Ok(new LoginResponseViewModel
                {
                    Status = false,
                    Message = "LOCKEDOUT",
                    Errors = errors
                });
            }

            var result = await userManager.CheckPasswordAsync(user, model.Password);
            if (!result)
            {
                return Ok(new LoginResponseViewModel
                {
                    Status = false,
                    Message = "Invalid password"
                });
            }

            var claims = await _permissionService.GetTokenClaims(user);
            var authResult = _jwtAuthManager.GenerateToken(user.NormalizedUserName, claims.ToArray(), DateTime.Now);

            // Set the login context.  This'll be used for event auditing...
            await SetLoginContext(user.UserName);

            return Ok(new LoginResponseViewModel
            {
                Token = new JwtSecurityTokenHandler().WriteToken(authResult.JwtToken),
                Expiration = Convert.ToDateTime(claims.FirstOrDefault(t => t.Type == "ExpireDate")?.Value),
                Status = true,
                Message = "Login successful",
                userId = user.idfUserID,
                RefreshToken = authResult.RefreshToken.TokenString
            });
        }

        [HttpPost]
        [AllowAnonymous]
        [Route("RefreshToken")]
        [SwaggerOperation(
            Summary = "Refresh Token",
            Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenViewModel model)
        {
            var user = await userManager.FindByNameAsync(model.UserName);

            var claims = await _permissionService.GetTokenClaims(user);

            var authResult = _jwtAuthManager.Refresh(model.RefreshToken, model.Token, DateTime.Now, claims);

            return Ok(new LoginResponseViewModel
            {
                Token = new JwtSecurityTokenHandler().WriteToken(authResult.JwtToken),
                Expiration = Convert.ToDateTime(authResult.JwtToken.ValidTo),
                Status = true,
                Message = "Token Refreshed",
                userId = user.idfUserID,
                RefreshToken = authResult.RefreshToken.TokenString
            });
        }

        private async Task<IActionResult> SetLoginContext(string username)
        {
            List<APIPostResponseModel> results = null;

            try
            {
                DataRepoArgs args = new()
                {
                    Args = new object[] { username, null, null },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUserSetSessionContextResult>)
                };

                results = await _repository.Get(args) as List<APIPostResponseModel>;
            }
            catch (Exception ex)
            {
                // Only log the exception...
                Log.Error(ex.Message);
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();
        }

        /// <summary>
        /// VerifyUserName
        /// </summary>
        /// <param name="userName"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("UserExists")]
        [SwaggerOperation(Summary = "Verifies the username", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> UserExists(string userName)
        {
            var user = await userManager.FindByNameAsync(userName);

            if (user == null)
            {
                return Ok(false);
            }
            else
            {
                return Ok(true);
            }
        }

        [HttpPost]
        [Route("AddEmployee")]
        [SwaggerOperation(Summary = "Add a new employee", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> AddEmployee(RegisterViewModel model)
        {
            var userExists = await userManager.FindByNameAsync(model.Username);
            if (userExists != null)
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel { Status = "Error", Message = "User already exists!" });

            var SecurityStamp = Guid.NewGuid().ToString();
            ApplicationUser user = new ApplicationUser()
            {
                ConcurrencyStamp = SecurityStamp,
                SecurityStamp = SecurityStamp,
                UserName = model.Username,
                PasswordResetRequired = model.IsPasswordResetRequired,
                NormalizedUserName = model.Username,
                idfUserID = model.idfUserID,
                blnDisabled = model.Disabled,
                LockoutEnabled = model.blnLocked,
                strDisabledReason = model.Reason
            };
            var result = await userManager.CreateAsync(user, model.Password);
            if (!result.Succeeded)
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel { Status = "Error", Message = "User creation failed! Please check user details and try again." });
            var userWithPassHistory = await userManager.Users.Include(x => x.PasswordHistory).FirstOrDefaultAsync(x => x.NormalizedUserName == model.Username);
            if (userWithPassHistory != null)
            {
                await AddToPasswordHistoryAsync(userWithPassHistory, model.Password, "system");
            }
            user = await userManager.FindByNameAsync(model.Username);
            AppUserViewModel userViewModel = new AppUserViewModel();
            userViewModel.Id = user.Id;
            userViewModel.idfUserID = user.idfUserID;

            return Ok(new ResponseViewModel { Status = "Success", Message = "User created successfully!", appUser = userViewModel });
        }

        /// <summary>
        /// Gets GetUserClaims
        /// </summary>
        /// <param name="userName">UserName</param>
        /// <param name="cancellationToken">A token that will enable cooperative cancellation of this task</param>
        /// <returns></returns>
        [HttpGet("GetUserClaims")]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a users Details", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> GetUserClaims(string userName, CancellationToken cancellationToken = default)
        {
            List<Claim> claims = null;

            try
            {
                var user = await userManager.FindByNameAsync(userName);

                claims = await _permissionService.GetUserClaims(user);
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(claims);
        }

        /// <summary>
        /// Gets the specified user's roles and permissions
        /// </summary>
        /// <param name="idfuserid">User's unique system identifier</param>
        /// <param name="employeeId">Employee's unique system identifier</param>
        /// <param name="cancellationToken">A token that will enable cooperative cancellation of this task</param>
        /// <returns></returns>
        [HttpGet("GetUserRolesAndPermissions")]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<UserRolesAndPermissionsViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "Gets a users roles a permissions", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> GetUserRolesAndPermissions(long? idfuserid, long? employeeId, CancellationToken cancellationToken = default)
        {
            List<UserRolesAndPermissionsViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { idfuserid, employeeId, null, cancellationToken },
                    MappedReturnType = typeof(List<UserRolesAndPermissionsViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUser_GetRolesAndPermissionsResult>)
                };

                results = await _repository.Get(args) as List<UserRolesAndPermissionsViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            if (results != null)
                return Ok(results);
            else
                return NotFound();
        }

        [HttpPost]
        [Route("ValidatePassword")]
        [SwaggerOperation(
           Summary = "Validate password",
           Description = "Validate password", Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> ValidatePassword([FromBody] RegisterViewModel model)
        {
            var user = await userManager.FindByNameAsync(model.Username);
            var userWithPassHistory = await userManager.Users.Include(x => x.PasswordHistory).FirstOrDefaultAsync(x => x.NormalizedUserName == model.Username);
            if (user == null)
            {
                user = new ApplicationUser()
                {
                    SecurityStamp = Guid.NewGuid().ToString(),
                    UserName = model.Username
                };
            }

            var result = await _passwordValidator.ValidateAsync(userManager, user, model.Password);

            if (!result.Succeeded)
            {
                var errors = new List<string>();
                foreach (var error in result.Errors)
                {
                    errors.Add(error.Description);
                }

                return Ok(new ResponseViewModel
                {
                    Status = "Error",
                    Message = "Not a valid password! Please check and try again.",
                    Errors = errors
                });

            }
            else
            {
                return Ok(new ResponseViewModel { Status = "Success", Message = "Valid Password" });
            }
        }

        [HttpPost]
        [Route("ValidateUser")]
        [SwaggerOperation(
        Summary = "Validate User",
        Description = "Validate User", Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> ValidateUser([FromBody] RegisterViewModel model)
        {
            var userExists = await userManager.FindByNameAsync(model.Username);
            if (userExists != null)
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel { Status = "Error", Message = "User already exists!" });

            var SecurityStamp = Guid.NewGuid().ToString();
            ApplicationUser user = new ApplicationUser()
            {
                ConcurrencyStamp = SecurityStamp,
                SecurityStamp = SecurityStamp,
                UserName = model.Username,
                PasswordResetRequired = model.IsPasswordResetRequired,
                NormalizedUserName = model.Username,
                idfUserID = model.idfUserID,
                blnDisabled = model.Disabled,
                LockoutEnabled = model.blnLocked,
                strDisabledReason = model.Reason
            };

            var result = await _userValidator.ValidateAsync(userManager, user);

            if (!result.Succeeded)
            {
                var errors = new List<string>();
                foreach (var error in result.Errors)
                {
                    errors.Add(error.Description);
                }

                return Ok(new ResponseViewModel
                {
                    Status = "Error",
                    Message = "Not a valid User! Please check and try again.",
                    Errors = errors
                });
            }
            else
            {
                return Ok(new ResponseViewModel { Status = "Success", Message = "Valid User" });
            }
        }

        [HttpPost]
        [Route("register-admin")]
        [SwaggerOperation(
            Summary = "Register's an administrative user",
            Description = "Require's administrative access", Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> RegisterAdmin([FromBody] RegisterViewModel model)
        {
            var userExists = await userManager.FindByNameAsync(model.Username);
            if (userExists != null)
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel { Status = "Error", Message = "User already exists!" });

            ApplicationUser user = new ApplicationUser()
            {
                SecurityStamp = Guid.NewGuid().ToString(),
                UserName = model.Username
            };

            var result = await userManager.CreateAsync(user, model.Password);
            if (!result.Succeeded)
            {
                var errors = new List<string>();
                foreach (var error in result.Errors)
                {
                    errors.Add(error.Description);
                }

                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User creation failed! Please check user details and try again.",
                    Errors = errors
                });
            }

            if (!await roleManager.RoleExistsAsync(UserRoles.Admin))
                await roleManager.CreateAsync(new IdentityRole(UserRoles.Admin));
            if (!await roleManager.RoleExistsAsync(UserRoles.User))
                await roleManager.CreateAsync(new IdentityRole(UserRoles.User));

            if (await roleManager.RoleExistsAsync(UserRoles.Admin))
            {
                await userManager.AddToRoleAsync(user, UserRoles.Admin);
            }

            return Ok(new ResponseViewModel { Status = "Success", Message = "User created successfully!" });
        }

        [HttpGet]
        [Route("GetAppUser")]
        [SwaggerOperation(Summary = "Gets the Application UserId", Tags = new[] { "Administration - Security" })]
        public async Task<AppUserViewModel> GetAppUser(string userName)
        {
            var user = await userManager.FindByNameAsync(userName);
            AppUserViewModel appUser = new AppUserViewModel();

            if (user != null)
            {
                appUser.Id = user.Id;
                appUser.idfUserID = user.idfUserID;
            }
            else
            {
                appUser.Id = "0";
            }

            return appUser;
        }

        [HttpGet]
        [Route("RemovePassword")]
        [SwaggerOperation(Summary = "Remove Password", Tags = new[] { "Administration - Security" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> RemovePassword(string aspnetUserId)
        {
            IdentityResult result;
            var user = await userManager.FindByIdAsync(aspnetUserId);
            result = await userManager.RemovePasswordAsync(user);
            if (!result.Succeeded)
            {
                var errors = new List<string>();
                foreach (var error in result.Errors)
                {
                    errors.Add(error.Description);
                }

                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "Error removing password! Please check",
                    Errors = errors
                });
            }
            else
            {
                return Ok(new ResponseViewModel { Status = "Success", Message = "Removed Password successfully!" });
            }
        }

        /// <summary>
        /// LogOut
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("Apilogout")]
        [SwaggerOperation(
            Summary = "Logout",
            Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> Apilogout()
        {
            await signInManager.SignOutAsync();
            return Ok(new ResponseViewModel { Status = "Success", Message = "Successfully logged out!" });
        }

        [HttpPost]
        [Route("LockAccount")]
        [SwaggerOperation(
           Summary = "LockAccount",
           Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> LockAccount(LockUserAccountParams lockUserAccountParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(lockUserAccountParams.UserName);
            if (user != null)
            {
                result = await userManager.SetLockoutEnabledAsync(user, true);
                if (result.Succeeded)
                {
                    result = await userManager.SetLockoutEndDateAsync(user, lockUserAccountParams.EndDate.ToUniversalTime());
                    if (!result.Succeeded)
                    {
                        var errors = new List<string>();
                        foreach (var error in result.Errors)
                        {
                            errors.Add(error.Description);
                        }

                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                        {
                            Status = "Error",
                            Message = "Error in LockAccount",
                            Errors = errors
                        });
                    }
                    else
                    {
                        return Ok(new ResponseViewModel { Status = "Success", Message = "LockAccount success!" });
                    }
                }
                else
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in LockAccount",
                        Errors = errors
                    });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
        }

        [HttpPost]
        [Route("UnLockAccount")]
        [SwaggerOperation(
         Summary = "UnLockAccount",
         Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseViewModel), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> UnLockAccount(UnLockUserAccountParams unLockUserAccountParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(unLockUserAccountParams.UserName);
            if (user != null)
            {
                result = await userManager.SetLockoutEndDateAsync(user, null);
                if (!result.Succeeded)
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in UnLockAccount",
                        Errors = errors
                    });
                }
                else
                {
                    await userManager.ResetAccessFailedCountAsync(user);
                    return Ok(new ResponseViewModel { Status = "Success", Message = "UnLockAccount success!" });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
        }

        [HttpPost]
        [Route("EnableUserAccount")]
        [SwaggerOperation(
         Summary = "EnableUserAccount",
         Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> EnableUserAccount(EnableUserAccountParams enableUserAccountParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(enableUserAccountParams.UserName);
            if (user != null)
            {
                user.blnDisabled = false;
                user.strDisabledReason = enableUserAccountParams.disableReason;
                result = await userManager.UpdateAsync(user);
                if (!result.Succeeded)
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in EnableUserAccount",
                        Errors = errors
                    });
                }
                else
                {
                    return Ok(new ResponseViewModel { Status = "Success", Message = "EnableUserAccount success!" });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
        }

        [HttpPost]
        [Route("UpdatePasswordResetRequired")]
        [SwaggerOperation(
            Summary = "UpdatePasswordResetRequired",
            Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> UpdatePasswordResetRequired(PasswordResetRequiredParams passwordResetRequiredParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(passwordResetRequiredParams.UserName);
            if (user != null)
            {
                user.PasswordResetRequired = passwordResetRequiredParams.PasswordResetRequired;
                result = await userManager.UpdateAsync(user);
                if (!result.Succeeded)
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in PasswordResetRequired update",
                        Errors = errors
                    });
                }
                else
                {
                    return Ok(new ResponseViewModel { Status = "Success", Message = "Updated PasswordResetRequired!" });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
        }

        [HttpPost]
        [Route("DisableUserAccount")]
        [SwaggerOperation(
        Summary = "DisableUserAccount",
        Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> DisableUserAccount(DisableUserAccountParams disableUserAccountParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(disableUserAccountParams.UserName);
            if (user != null)
            {
                user.blnDisabled = true;
                user.strDisabledReason = disableUserAccountParams.disableReason;
                result = await userManager.UpdateAsync(user);
                if (!result.Succeeded)
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in DisableUserAccount",
                        Errors = errors
                    });
                }
                else
                {
                    return Ok(new ResponseViewModel { Status = "Success", Message = "DisableUserAccount success!" });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
        }

        [AllowAnonymous]
        [HttpPost]
        [Route("ResetPasswordByUser")]
        [SwaggerOperation(
       Summary = "ResetPasswordByUser",
       Description = "ResetPasswordByUser", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> ResetPasswordByUser(ResetPasswordByUserParams resetPasswordByUserParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByNameAsync(resetPasswordByUserParams.UserName);
            user = await userManager.Users.Include(x => x.PasswordHistory).FirstOrDefaultAsync(x => x.Id == user.Id);

            if (user != null)
            {
                var chkPassword = await userManager.CheckPasswordAsync(user, resetPasswordByUserParams.CurrentPassword);
                if (!chkPassword)
                {
                    var errors = new List<string>();
                    errors.Add("Invalid password");
                    return Ok(new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "INVALIDPASSWORD",
                        Errors = errors
                    });
                }

                result = await _passwordValidator.ValidateAsync(userManager, user, resetPasswordByUserParams.NewPassword);
                if (result.Succeeded)
                {
                    var token = await userManager.GeneratePasswordResetTokenAsync(user);
                    result = await userManager.ResetPasswordAsync(user, token, resetPasswordByUserParams.NewPassword);
                    if (result.Succeeded)
                        user.PasswordResetRequired = resetPasswordByUserParams.PasswordResetRequired;

                    await AddToPasswordHistoryAsync(user, userManager.PasswordHasher.HashPassword(user, resetPasswordByUserParams.NewPassword), resetPasswordByUserParams.UpdatingUser);
                }
                else
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return Ok(new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "PASSWORDERROR",
                        Errors = errors
                    });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");

                return Ok(new ResponseViewModel
                {
                    Status = "Error",
                    Message = "NOUSER",
                    Errors = errors
                });
            }

            return Ok(new ResponseViewModel { Status = "Success", Message = "reset password success!" });
        }

        [HttpPost]
        [Route("ResetPassword")]
        [SwaggerOperation(
        Summary = "ResetPassword",
        Description = "ResetPassword", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> ResetPassword(ResetPasswordParams resetPasswordParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByIdAsync(resetPasswordParams.userId);
            user = await userManager.Users.Include(x => x.PasswordHistory).FirstOrDefaultAsync(x => x.Id == user.Id);

            if (user != null)
            {
                result = await _passwordValidator.ValidateAsync(userManager, user, resetPasswordParams.password);
                if (result.Succeeded)
                {
                    var token = await userManager.GeneratePasswordResetTokenAsync(user);
                    result = await userManager.ResetPasswordAsync(user, token, resetPasswordParams.password);
                    if (result.Succeeded)
                        user.PasswordResetRequired = resetPasswordParams.passwordResetRequired;

                    await AddToPasswordHistoryAsync(user, userManager.PasswordHasher.HashPassword(user, resetPasswordParams.password), resetPasswordParams.updatingUser);
                }
                else
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in ResetPassword",
                        Errors = errors
                    });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }

            return Ok(new ResponseViewModel { Status = "Success", Message = "reset password success!" });
        }

        [HttpPost]
        [Route("UpdateUserName")]
        [SwaggerOperation(
        Summary = "UpdateUserName",
        Description = "UpdateUserName", Tags = new[] { "Administration - Users" })]
        public async Task<IActionResult> UpdateUserName(UpdateUserNameParams updateUserNameParams)
        {
            IdentityResult result = null;
            var user = await userManager.FindByIdAsync(updateUserNameParams.UserID);

            if (user != null)
            {
                var existingUser = await userManager.FindByNameAsync(updateUserNameParams.NewUserName);

                if (existingUser != null)
                {
                    var errors = new List<string>();
                    errors.Add("User Name exists already!");
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "User Name exists already!",
                    });
                }

                user.UserName = updateUserNameParams.NewUserName;
                user.NormalizedUserName = updateUserNameParams.NewUserName;
                await userManager.UpdateNormalizedUserNameAsync(user);

                result = await userManager.UpdateAsync(user);
                if (!result.Succeeded)
                {
                    var errors = new List<string>();
                    foreach (var error in result.Errors)
                    {
                        errors.Add(error.Description);
                    }

                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                    {
                        Status = "Error",
                        Message = "Error in UpdateUserName",
                        Errors = errors
                    });
                }
            }
            else
            {
                var errors = new List<string>();
                errors.Add("User does not exist");
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseViewModel
                {
                    Status = "Error",
                    Message = "User does not exist",
                });
            }
            return Ok(new ResponseViewModel { Status = "Success", Message = "Updated User Name!" });
        }

        [HttpPost]
        [Route("AddToPasswordHistoryAsync")]
        [SwaggerOperation(
         Summary = "AddToPasswordHistoryAsync",
         Description = "AddToPasswordHistoryAsync", Tags = new[] { "Administration - Users" })]
        public async Task<IdentityResult> AddToPasswordHistoryAsync(ApplicationUser user, string password, string updatinguser)
        {
            user.PasswordHistory.Add(new ASPNetUserPreviousPasswords()
            { Id = user.Id, OldPasswordHash = user.PasswordHash, AuditCreateUser = updatinguser, AuditUpdateUser = updatinguser });

            return await userManager.UpdateAsync(user);
        }

        /// <summary>
        /// UpdateIdentityOptions
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("UpdateIdentityOptions")]
        [SwaggerOperation(Summary = "Verifies the username", Tags = new[] { "Administration - Security" })]
        public async Task<bool> UpdateIdentityOptions()
        {
            var securitypolicyList = await _context.USP_SecurityConfiguration_GetAsync();

            _options.Lockout.AllowedForNewUsers = true;
            _options.Lockout.MaxFailedAccessAttempts = securitypolicyList.FirstOrDefault().LockoutThld.Value;
            _options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(securitypolicyList.FirstOrDefault().LockoutDurationMinutes.Value);

            return true;
        }

        /// <summary>
        /// ConnectToArchive
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("ConnectToArchive")]
        [SwaggerOperation(Summary = "ConnectToArchive", Tags = new[] { "Administration - Security" })]
        public bool ConnectToArchive(bool isConnectToArchive)
        {
            DbContextFactory.Connect(isConnectToArchive ? "EIDSSARCHIVE" : "EIDSS");

            return true;
        }

        [AllowAnonymous]
        [HttpGet]
        [Route("GetAVRUserGroups")]
        [SwaggerOperation(Summary = "Gets a list of AVR User Groups", Tags = new[] { "Administration - Users" })]
        [ProducesResponseType(typeof(List<AVRGroupResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AVRGroupResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<AVRGroupResponseModel>), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetAVRUserGroups(long idfEmployee)
        {
            List<AVRGroupResponseModel> _groups = new();
            var result = GetAVRUserPermissions(idfEmployee).Result;

            var res = result as OkObjectResult;

            if( res.Value == null ) return null;

            var x =
                (from g in (List<AVRPermissionResponseModel>)res.Value
                group g by g.GroupName into gb
                select gb).Distinct();

            if( x == null ) return null;

            foreach (var g in x)
            {
                var _ = new AVRGroupResponseModel
                {
                    GroupName = g.FirstOrDefault().GroupName,
                    idfEmployee = g.First().idfEmployee
                };
                _groups.Add(_);

            }

            return Ok(_groups);
        }
    }
}