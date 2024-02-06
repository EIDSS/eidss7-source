using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.Services
{
    public class BaseService
    {

        protected internal ILogger _logger;
       
        public BaseService(ILogger logger)
        {
            _logger = logger;
        }

       
    }
}
