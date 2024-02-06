using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class LoginResponseViewModel
    {
        public string Token{ get; set; }
        public DateTime? Expiration { get; set; }
        public bool Status { get; set; }
        public string Message { get; set; }
        public IEnumerable<string> Errors { get; set; }
        public long userId { get; set; }
        public string RefreshToken { get; set; }

    }
}
