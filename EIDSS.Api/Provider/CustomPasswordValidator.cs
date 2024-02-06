using EIDSS.Api.Providers;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{

    public class BasePasswordValidator
    {
    }

    public class CustomPasswordValidator :  PasswordValidator<ApplicationUser>
    { 
        private static readonly char[] SpecialChars = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~".ToCharArray();
        private EIDSSContextProcedures _context;
        public CustomPasswordValidator(EIDSSContextProcedures context)
        {
            _context = context;
        }

        public override async Task<IdentityResult> ValidateAsync(UserManager<ApplicationUser> manager, ApplicationUser user, string password)
        {
            var IdentityErrorList = new List<IdentityError>();
            var securitypolicyList = await _context.USP_SecurityConfiguration_GetAsync();

            IdentityResult result = await base.ValidateAsync(manager, user, password);

            if (securitypolicyList.Count > 0)
            {
                var securitypolicy = securitypolicyList.FirstOrDefault();


               if (securitypolicy.EnforcePasswordHistoryCount.Value > 0)
                {
                    var passAlreadyExist = false;
                    var userPreviousPasswords = user.PasswordHistory;
                    if (userPreviousPasswords !=null)
                    {
                        userPreviousPasswords = user.PasswordHistory.OrderByDescending(x => x.AuditCreateDTM).Take(securitypolicy.EnforcePasswordHistoryCount.Value).ToList();
                        passAlreadyExist = userPreviousPasswords
                       .Select(h => h.OldPasswordHash)
                       .Distinct()
                       .Any(hash =>
                       {
                           var res = manager.PasswordHasher.VerifyHashedPassword(user, hash, password);
                           return res == PasswordVerificationResult.Success;
                       });
                    }

                    if (passAlreadyExist)
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PreviousPasswords",
                            Description = $"You cannot reuse previous {securitypolicy.EnforcePasswordHistoryCount.Value} password(s)"
                        });
                    }
                }

                if (securitypolicy.PreventUsernameUsageFlag.Value)
                {
                    if (string.Equals(user.UserName, password, StringComparison.OrdinalIgnoreCase))
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "UsernameAsPassword",
                            Description = "You cannot use your username as your password"
                        });
                    }
                }

                if (password.Length<securitypolicy.MinPasswordLength)
                {
                    IdentityErrorList.Add(new IdentityError
                    {
                        Code = "PasswordTooShort",
                        Description = "Passwords must be at least " + securitypolicy.MinPasswordLength.Value.ToString() + " characters"
                    }); ;
                }

                if (securitypolicy.ForceNumberUsageFlag.Value)
                {
                    if (!password.Any(char.IsDigit))
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordRequiresDigit",
                            Description = "Passwords must have at least one digit ('0'-'9')"
                        });
                    }
                }

                if (securitypolicy.ForceLowercaseFlag.Value)
                {

                    if (!password.Any(c => Char.IsLower(c)))
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordRequiresLower",
                            Description = "Passwords must have at least one lowercase ('a'-'z')"
                        });
                    }
                }

                if (securitypolicy.ForceUppercaseFlag.Value)
                {

                    if (!password.Any(c => Char.IsUpper(c)))
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordRequiresUpper",
                            Description = "Passwords must have at least one uppercase ('A'-'Z')"
                        });
                    }
                }

                if (securitypolicy.ForceSpecialCharactersFlag.Value)
                {
                    int indexOf = password.IndexOfAny(SpecialChars);
                    if (indexOf == -1)
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordRequiresSpecialChar",
                            Description = "Passwords must have at least one special char !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
                        });
                    }
                }

                if (securitypolicy.PreventSequentialCharacterFlag.Value)
                {
                    bool found = false;
                    int len = 3;
                    bool success = true;
                    for (int i = 0; i <= password.Length - len; ++i)
                    {
                        success = true;

                        char c = password[i];
                        for (int j = 1; j < len; ++j)
                        {
                            if ((char)((char)c + j) != password[i + j])
                            {
                                success = false;
                                break;
                            }
                        }
                        if (success)
                        {
                            found = true;
                            break;
                        }

                        if (!found)
                        {
                            success = true;

                            for (int j = 1; j < len; ++j)
                            {
                                if ((char)((char)c - j) != password[i + j])
                                {
                                    success = false;
                                    break;
                                }
                            }
                        }

                        if (success)
                        {
                            found = true;
                            break;
                        }
                    }

                    if (success)
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordPreventSequentialChar",
                            Description = "Passwords must not contain 3 sequential characters"
                        });
                    }
                   
                }

                if (!securitypolicy.AllowUseOfSpaceFlag.Value)
                {
                    if (password.Contains(" "))
                    {
                        IdentityErrorList.Add(new IdentityError
                        {
                            Code = "PasswordDontAllowSpace",
                            Description = "Passwords must not space"
                        });
                    }
                }
            }

            if (IdentityErrorList.Count==0)
                return await Task.FromResult(IdentityResult.Success);
             else
                return await Task.FromResult(IdentityResult.Failed(IdentityErrorList.ToArray()));
        }

    }
}