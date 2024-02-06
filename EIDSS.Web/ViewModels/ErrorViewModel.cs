using System;

namespace EIDSS.Web.ViewModels
{
    public class ErrorViewModel
    {

        public string RequestId { get; set; }

        public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);
    }
}
