using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Areas.Configuration.ViewModels;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion.Internal;

namespace EIDSS.Web.ViewModels
{
    public class BaseReferenceEditorPagesViewModel : BaseReferenceEditorsViewModel
    {

        public BaseReferenceEditorPagesViewModel()
        {

            //InitializeGridSettings();

        }
        /// <summary>
        /// Displays Name of Page in Header
        /// </summary>
        public string PageName { get; set; }
        public BaseReferenceEditorsViewModel[] baseReferenceListViewModel { get; set; }


        /// <summary>
        /// Defines DropDowns For the Model
        /// </summary>
        public List<Select2Configruation> Select2Configurations { get; set; }



        public List<string> basereferenceTypes { get; set; }
        public string Case_AddSystemTypesToDisable { get; set; }
        public string Case_LOINCSystemTypesToHide { get; set; }
        public string Case_HACodeSystemTypesToHide { get; set; }
        public string Case_DefaultReadOnly { get; set; }
        public string Case_OrderByReadOnly { get; set; }

        EIDSSGridConfiguration _gridViewComponentBuilder;

        /// <summary>
        /// Defines The Grid for the Model
        /// </summary>
        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }


        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        /// <summary>
        /// Modal Id to Launch from Page Level Button
        /// </summary>
        public string PageLevelAddButtonModal { get; set; }

        /// <summary>
        /// Page button Text that Launches Modal
        /// </summary>
        public string PageLevelAddButtonModalText { get; set; }

        /// <summary>
        /// ID of Add Button On Page
        /// </summary>
        public string PageLevelAddButtonID { get; set; }

        public SearchActorViewModel SearchActorViewModel { get; set; }
        public bool ReadPermissionIndicator { get; set; }

        public UserPermissions UserPermissions { get; set; }
        /// <summary>
        /// Used for SAUC62 - disease permissions.
        /// </summary>
        public UserPermissions DiseaseAccessRightsUserPermissions { get; set; }

        public List<string> _referenceItemsList { get; set; }
        public string DefaultPersonalIDType { get; set; }

        public UniqueNumberSchemaPrintModel UniqueNumberSchemaPrintModel { get; set; }

        public string InformationMessage { get; set; }
    }

    /// <summary>
    /// Defines the Reference Editor type for the Model
    /// </summary>
    public enum ReferenceEditorType
    {
        
        Species,
        Vector,
        Samples,
     
    }

    public class BasePrintModel
    {
        public DateTime PrintDateTime { get; set; }

    }


    public class UniqueNumberSchemaPrintModel: BasePrintModel
    {
        public string TypeOfBarCodeLabel { get; set; }
        public string TypeOfBarCodeLabelName { get; set; }
        public string LanguageId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Only positive number allowed")]
        public string NoOfLabelsToPrint { get; set; }
        public string Prefix { get; set; }
        public string Site { get; set; }
        public string Year { get; set; }
        public string Date { get; set; }
        public string ReportName { get; set; }
        public string ReportHeader { get; set; }
        public string BarcodeParametersJSON { get; set; }
        public List<KeyValuePair<string, string>> PrintParameters { get; set; }
        public bool ShowBarCodePrintArea { get; set; }
        public bool isPrefixChecked  { get; set; }
        public bool isSiteChecked { get; set; }
        public bool isDateChecked { get; set; }
        public bool isYearChecked { get; set; }


        public List<ReportLanguageModel> ReportLanguageModels { get; set; }




    }

}
