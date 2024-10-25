using EIDSS.Domain.ViewModels.FlexForm;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Outbreak;

namespace EIDSS.Web.ViewModels.Configuration
{
    public class FlexFormDesignerPageViewModel
    {
        public List<FlexFormFormTypesListViewModel> FormTypes { get; set; }
        public List<FlexFormSectionsListViewModel> Sections { get; set; }
        public List<FlexFormParametersListViewModel> Parameters { get; set; }
        public List<FlexFormTemplateListViewModel> Templates { get; set; }
        public FlexFormTemplateDetailViewModel TemplateDetails { get; set; }
        public List<FlexFormTemplateDesignListViewModel> TemplateDesign { get; set; }
        public List<FlexFormTemplateDeterminantValuesListViewModel> TemplateDeterminants { get; set; }
        public string GetFlexFormParametersListPath { get; set; }
        public string GetFlexFormSectionsListPath { get; set; }
        public OutbreakFlexFormDesignerModel Outbreak { get; set; }
    }
}
