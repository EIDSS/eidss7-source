using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Configuration
{
    public class VeterinarySanitaryActionMatrixPageViewModel
    {
        public string MatrixName { get; set; }
        public string ActivationDate { get; set; }
        public bool IsActive { get; set; }
        public string VersionStatus { get; set; }
        public bool DisableNewMatrix { get; set; }
        public List<MatrixVersionViewModel> MatrixVersionList { get; set; }
        public List<VeterinarySanitaryActionMatrixViewModel> MatrixList { get; set; }
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }
        public UserPermissions UserPermissions { get; set; }
        public string InformationMessage { get; set; }
        public bool DisableCalendar = false;
    }
}
