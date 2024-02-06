using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class ILIAggregatePageViewModel : BaseReferenceEditorPagesViewModel
    {
        public string FormID { get; set; }        
        public string LegacyFormID { get; set; }

        [DisplayName("Weeks From")]
        //[LocalizedRequired]
        //[LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(WeeksFrom),nameof(WeeksFrom), nameof(WeeksTo), nameof(WeeksTo), CompareTypeEnum.LessThanOrEqualTo,nameof(FieldLabelResourceKeyConstants.SearchILIAggregateWeeksFromFieldLabel),nameof(FieldLabelResourceKeyConstants.SearchILIAggregateWeeksToFieldLabel))]
        
        //[DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? WeeksFrom { get; set; }

        [DisplayName("Weeks To")]
        //[LocalizedRequired]
        //[LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(WeeksTo), nameof(WeeksTo), nameof(WeeksFrom), nameof(WeeksFrom), CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.SearchILIAggregateWeeksToFieldLabel), nameof(FieldLabelResourceKeyConstants.SearchILIAggregateWeeksFromFieldLabel))]

        //[IntegerComparer(nameof(WeeksTo), nameof(WeeksFrom), CompareTypeEnum.GreaterThanOrEqualTo, nameof(MessageResourceKeyConstants.ReportsYearSelectedInToFilterShallBeGreaterThanYearSelectedInFromFilterYearsMessage))]
        //[DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? WeeksTo { get; set; }
        
        public List<OrganizationGetListViewModel> HospitalList { get; set; }
        public List<OrganizationGetListViewModel> DataEntrySiteList { get; set; }


        public EIDSSGridConfiguration eidssGridConfiguration { get; set; }
        public List<Select2Configruation> Select2Configurations { get; set; }
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        public long IdfAggregateHeader { get; set; }
        public DateTime DateEntered { get; set; }
        public DateTime? DateLastSaved { get; set; }
        public string EnteredBy { get; set; }
        public string Site { get; set; }
        public int Year { get; set; }
        public int Week { get; set; }

        public List<ILIAggregateDetailViewModel> DetailsList { get; set; }

        public  DiseaseReportPrintViewModel ReportPrintViewModel { get; set; }

        public string PrintParameters { get; set; }
        public string ReportName { get; set; }
        public string ReportHeader { get; set; }
        public ILIAggregateFormSearchRequestModel iLIAggregateFormSearchRequestModel { get; set; }
    }
}
