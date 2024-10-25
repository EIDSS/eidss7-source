using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Localization.Constants;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.ViewModels.Human;

namespace EIDSS.Web.ViewModels.Laboratory
{
    public class FreezerPageViewModel
    {
        public FreezerPageViewModel()
        {
            FreezerReportPrintViewModel = new FreezerReportPrintViewModel();
        }

        public FreezerReportPrintViewModel FreezerReportPrintViewModel { get; set; }

        public UserPermissions UserPermissions { get; set; }
        public List<FreezerViewModel> FreezerList { get; set; }
        public List<BaseReferenceEditorsViewModel> StorageTyleList { get; set; }
        public List<BaseReferenceEditorsViewModel> SubdivisionTypeList { get; set; }
        public List<BaseReferenceEditorsViewModel> BoxSizeTypeList { get; set; }
        public string SiteID { get; set; }        
        public string ReportName { get; set; } = "PrintFreezerBarcode";
        public string PrintReportName { get; set; } = "SearchForFreezer";
        public string ReportHeader { get; set; }
        public List<KeyValuePair<string, string>> FreezerBarcodeParameters { get; set; }
        public List<KeyValuePair<string, string>> PrintParameters { get; set; }
        public string FreezerBarcodeParametersJSON { get; set; }
        public string PrintParametersJSON { get; set; }

        public string FreezerName { get; set; }
        public string BarcodeLabelCode { get; set; }
        public string SubdivisionBarcodeLabelCode { get; set; }
        public bool ShowBarcodeModal { get; set; }
        public long SelectedFreezerId { get; set; }
        public long SelectedSubdivisionId { get; set; }
        public bool ShowPrintModal { get; set; }



        //public bool ShowWarningMessage { get; set; }
    }
}
