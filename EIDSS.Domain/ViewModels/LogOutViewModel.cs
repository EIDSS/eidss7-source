using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class LogOutViewModel
    {
        [Required(ErrorMessage = "User Name is required")]
        public string Username { get; set; }

    }
}
