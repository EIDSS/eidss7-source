using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Outbreak.ViewModels
{
    public class OutbreakPageViewModel
    {
        public OutbreakPageViewModel()
        {
            OutbreakReportPrintViewModel = new OutbreakReportPrintViewModel();
        }

        public OutbreakReportPrintViewModel OutbreakReportPrintViewModel { get; set; }

        public string CurrentLanguage { get; set; }
        public EIDSSGridConfiguration EidssGridConfiguration { get; set; }

        public FlexFormQuestionnaireGetRequestModel HumanAggregateCase { get; set; }
        public Select2Configruation SessionType { get; set; }
        public string DefaultOutbreakStatusTypeName { get; set; }
        public OutbreakSessionSearchRequestModel SearchCriteria { get; set; }
        public LocationViewModel SessionLocationViewModel { get; set; }
        public long SearchAdministrativeUnitTypeID { get; set; }
        public UserPermissions OutbreakPermissions { get; set; }
    }

    public class OutbreakReportPrintViewModel
    {
        public List<KeyValuePair<string, string>> Parameters { get; set; }
        public string PrintParameters { get; set; }

        public string ReportName { get; set; }
        public string ReportHeader { get; set; }
    }

    public class OutbreakSearchForOutbreaksPrint
    {
        public string LangID { get; set; }
        public string ReportTitle { get; set; }
        public string SiteID { get; set; }
        public string SortColumn { get; set; }
        public string PageNumber { get; set; }
        public string SortOrder { get; set; }
        public string PageSize { get; set; }
        public string OutbreakID { get; set; }
        public string OutbreakTypeID { get; set; }
        public string SearchDiagnosisGroup { get; set; }
        public string StartDateFrom { get; set; }
        public string StartDateTo { get; set; }
        public string OutbreakStatusTypeID { get; set; }
        public string AdministrativeLevelID { get; set; }
        public string QuickSearch { get; set; }
        public string UserSiteID { get; set; }
        public string UserOrganizationID { get; set; }
        public string UserEmployeeID { get; set; }
        public string ApplySiteFiltrationIndicator { get; set; }
        public string PersonID { get; set; }
    }
}
