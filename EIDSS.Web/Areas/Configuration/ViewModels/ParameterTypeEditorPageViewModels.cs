using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Configuration.ViewModels
{

    public class ParameterTypeEditorPageViewModel
    {
        public List<Select2Configruation> ParameterSelectConfigurations { get; set; }
        public EIDSSGridConfiguration ParameterTypeGridConfiguration { get; set; }
        public List<EIDSSModalConfiguration> ParameterTypeModalConfigurations { get; set; }
        public string PageLevelAddButtonModalText { get; set; }
        public string PageLevelAddButtonID { get; set; }
        public string PageLevelAddButtonModal { get; set; }
        public UserPermissions UserPermissions { get; set; }
        public KeyValuePair<string, string> DefaultParameterType { get; set; }
        public ParameterTypeEditorDetailsPageViewModel SelectedDetail { get; set; }
    }

    public class ParameterTypeEditorDetailsPageViewModel
    {
        public List<Select2Configruation> SelectConfigurations { get; set; }
        public EIDSSGridConfiguration GridConfiguration { get; set; }
        public List<EIDSSModalConfiguration> ModalConfigurations { get; set; }
        public UserPermissions UserPermissions { get; set; }
        public string PageLevelAddButtonModalText { get; set; }
        public string PageLevelAddButtonID { get; set; }
        public string PageLevelAddButtonModal { get; set; }
        public long KeyId { get; set; }
        public string ParameterTypeName { get; set; }
        public long? IdfsReferenceType { get; set; }
        public string BaseReferenceListName { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string System { get; set; }

    }
}
