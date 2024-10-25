using EIDSS.Domain.Attributes;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class LoginViewModel 
    {
 
        [Required(ErrorMessage = "User Name is required")]
        [JsonProperty(PropertyName = "Username")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [DataType(DataType.Password)]
        [JsonProperty(PropertyName = "Password")]
        public string Password {    get; set; }

    }

    public class RefreshTokenViewModel
    {

        public string Token { get; set; }
       
        public string RefreshToken { get; set; }

        public string UserName { get; set; }

    }
}
