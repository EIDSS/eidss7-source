﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class ResponseViewModel
    {
        public string Status { get; set; }
        public string Message { get; set; }
        public IEnumerable<string> Errors { get; set; }
        public AppUserViewModel appUser { get; set; }

    }

    public class ResponsePasswordValidationViewModel
    {
        public string Status { get; set; }
        public string Message { get; set; }
        public Dictionary<string,string> Errors { get; set; }
        public AppUserViewModel appUser { get; set; }

    }
}
