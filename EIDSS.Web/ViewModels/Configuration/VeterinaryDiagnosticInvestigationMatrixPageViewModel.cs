using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Configuration
{
    public class VeterinaryDiagnosticInvestigationMatrixPageViewModel
    {       
        public string MatrixName { get; set; }        
        public string ActivationDate { get; set; }
        public bool IsActive { get; set; }
        public string VersionStatus { get; set; }
        public bool DisableNewMatrix { get; set; }
        public List<MatrixVersionViewModel> MatrixVersionList { get; set; }
        public List<VeterinaryDiagnosticInvestigationMatrixReportModel> MatrixList { get; set; }
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }
        public List<Select2Configruation> Select2Configurations { get; set; }
        public UserPermissions UserPermissions { get; set; }

        public bool DisableCalendar = false;
        public string InformationMessage { get; set; }
    }
}
