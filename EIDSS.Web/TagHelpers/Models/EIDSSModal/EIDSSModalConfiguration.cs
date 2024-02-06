using EIDSS.Web.ActionFilters;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.Web.ViewModels.VaildationRuleType;

namespace EIDSS.Web.TagHelpers.Models.EIDSSModal
{

    public class EIDSSModalConfiguration
    {

        List<EIDSSControlNames> _eIDSSControlNames;
        PageNames _pagenames;

        
        /// <summary>
        /// ID FOR Modal
        /// </summary>
        public string ModalId { get; set; }

        /// <summary>
        /// CSS Class for Header
        /// </summary>
        public string ModalHeaderClass { get; set; }

        /// <summary>
        /// Name Of Page
        /// </summary>
        public PageNames PageName { get { return _pagenames; } set { _pagenames = value; } }

        /// <summary>
        /// Endpoint used to Post Data when the save button is clicked
        /// </summary>
        public string PostAjaxDataUrl { get; set; }

      
        public string GetAjaxURL { get; set; }
        public string EditAjaxUrl { get; set; }
        public string DeleteAjaxUrl { get; set; }
        public List<EIDSSControlNames> ControlNames { get { return _eIDSSControlNames; } set { _eIDSSControlNames = value; } }

        /// <summary>
        /// Grid Id to refresh after Modal saves data
        /// </summary>
        public string TargetGridControlID { get; set; }
       
        
        EIDSSControlLabels _controlLabels;
       
        /// <summary>
        /// Labels For buttons and Messages
        /// </summary>
        public EIDSSControlLabels ControlLabels { get { return _controlLabels; } set { _controlLabels = value; } }

        /// <summary>
        /// SAVING DATA FROM CONTROLS THAT ARE OUTSIDE OF THE MODAL
        /// </summary>
        public string SavingControlsCollection { get; set; }
        public EIDSSModalConfiguration()
        {
            _eIDSSControlNames = new List<EIDSSControlNames>();

            _controlLabels = new EIDSSControlLabels();
        }

        /// <summary>
        /// Method executed after Ajax call is completed returns data back from the controller
        /// </summary>
        public string SaveCompleteMethod { get; set; }
        public bool DisplayConfirmCancelModal { get; set; }

        public string CancelConfirmationFunction { get; set; }
        /// <summary>
        /// Message to display when a record is successfuly saved
        /// </summary>
        public string SuccessConfirmationMessage { get; set; }

       

      

        /// <summary>
        /// Text Displayed For Yes Button
        /// </summary>
        public string YesButtonLabel { get; set; }

        /// <summary>
        /// Text Displayed For No Button
        /// </summary>
        public string NoButtonLabel { get; set; }

    }

    public class EIDSSControlNames
    {
        /// <summary>
        /// Type of Control
        /// </summary>
        ControlType _ControlType;

        /// <summary>
        /// Drop Down Type
        /// </summary>
        DropDownType _dropDownType;

        /// <summary>
        /// Validation Settings
        /// </summary>
        ValidatorSettings _validatorSettings;



        /// <summary>
        /// DataField For Control Determines Controls Id or Name Attribute and Binding
        /// </summary>
        /// 


        public string ControlName { get; set; }


        public ValidationRuleType VaildationProperty { get; set; }

        public ValidatorSettings ValidationSetting { get { return _validatorSettings; } set { _validatorSettings = value; } }

        public string ValidationRule { get; set; }

        /// <summary>
        /// The Controls Label
        /// </summary>
        public string LabelNameForControl { get; set; }

        /// <summary>
        /// The Type OF Control to Render
        /// </summary>
        public ControlType ControlType { get { return _ControlType; } set { _ControlType = value; } }
        
        /// <summary>
        /// Method to call on FocusOut
        /// </summary>
        public string FocusOutMethod { get; set; }

        public DropDownType DropDownType { get { return _dropDownType; } set { _dropDownType = value; } }

        /// <summary>
        /// Sets Select 2 functionality to Multiple Selections
        /// </summary>
        public bool AllowMultipleDropDownItemSelection { get; set; }


        /// <summary>
        /// API Endpoint envoked When Dropdown Add Button is CLicked
        /// </summary>
        public string AddButtonAjaxUrl { get; set; }

        /// <summary>
        /// Endpoint where control gets it's data
        /// currently set for drop downs
        /// </summary>
        public string ControlAjaxDataUrl { get; set; }


        /// <summary>
        /// Modal to open when dropdown button is clicked
        /// </summary>
        public string OpenModalName { get; set; }
        /// <summary>
        /// Image URL
        /// </summary>
        public string ImageUrl { get; set; }

        public string ClientMethod { get; set; }
        /// <summary>
        /// Controls visibility of control
        /// </summary>
        public Boolean Visible { get; set; }

        /// <summary>
        /// Sets a CSS Class for the Control
        /// </summary>
        public string ClassName { get; set; }

        public string FilteredControlId { get; set; }
        public string FilteredData { get; set; }
        public string DefaultContent { get; set; }

        public Boolean Orderable { get; set; }

        public string ClientFunction { get; set; }

        public string ErrorMessage { get; set; }
        public string DropDownAddButtonOpenModalCustomFunction { get; set; }

        /// <summary>
        /// Sets Options for Radio Or CheckBox
        /// </summary>
        public List<RadionCheckBoxOptions> RadioCheckBoxOptions {get;set;}

        /// <summary>
        /// Allows the user to create their own items for fields 
        /// that are drop downs
        /// </summary>
        public bool AllowTags { get; set; }

    }
    public enum PageNames
    {

        BaseReferenceEditor,
        HumanDiseaseReportSearch,
        Samples,
        Tests,
        Contacts,
        PersonSearch,
        LabSearch,
        VetSeacrh,
        OutbreakSearch
    }

    public enum ControlType
    {
        Default,
        DropDown,
        Link,
        Button,
        CheckBox,
        RadioButton,
        Delete,
        Numeric,
        NumericCustom,
        Edit,
        Details,
        DropDownAddButtonURL,
        DropDownAddButtonOpenModal,
        Hidden,
        ValidationLabel,
        NumericRangeRequired
    }

    public enum DropDownType
    {
        OrganizationType,
        Organization,
        Diagnosis,
        Person,
        TestType

    }

    public class RadionCheckBoxOptions
    {
        public string Key { get; set; }
        public string Value { get; set; }

        public bool IsChecked { get; set; }
    }


}
