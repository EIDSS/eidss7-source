using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using static EIDSS.Web.ViewModels.VaildationRuleType;

namespace EIDSS.Web.TagHelpers.Models.EIDSSGrid
{
    public class EIDSSGridConfiguration
    {
        List<EIDSSColumnNames> _eIDSSColumnNames;
        GridImplementedPageName _pagenames;
        EIDSSControlLabels _controlLabels;

        /// <summary>
        /// IF Set to true, data from the column controls the edit and delete
        /// </summary>
        public bool RowDataEnablesAndDisblesDelete { get; set; }

        public bool EnableNavigationAwayNotification { get; set; }
        /// <summary>
        /// Labels For buttons and Messages
        /// </summary>
        public EIDSSControlLabels ControlLabels { get { return _controlLabels; } set { _controlLabels = value; } }

        /// <summary>
        /// ID Of GRID
        /// </summary>
        public string GridId { get; set; }
        /// <summary>
        /// CLASS NAME OF GRID
        /// </summary>
        public string GridClass { get; set; }
        public string EditPassThrough { get; set; }
        public string CancelInlineEditCallBack { get; set; }
        /// <summary>
        /// PAGE NAME THAT THIS GRID WILL BE IMPLMENTED
        /// </summary>
        public GridImplementedPageName PageName { get { return _pagenames; } set { _pagenames = value; } }

        
        /// <summary>
        /// ENDPOINT THAT GRID USES TO GET ITS DATA
        /// </summary>
        public string AjaxDataUrl { get; set; }

        /// <summary>
        /// ENDPOINT THAT EDIT MODAL USES TO POST DATA
        /// </summary>
        public string EditModalAjaxUrl { get; set; }

        /// <summary>
        /// ENPOINT THAT DELETE MODAL USES TO DELETE ITS DATA
        /// </summary>
        public string DeleteModalAjaxUrl { get; set; }


        /// <summary>
        /// Custom Method For Deleting
        /// </summary>
        public string DeleteCustomMethod { get; set; }

        /// <summary>
        /// Custom Method for editing --Impemented in Inline Editing
        /// </summary>
        public string EditCustomMethod { get; set; }
        /// <summary>
        /// COLUMN COLUMN COLLECTION OF GRID SHOULD BE EXACT NUMBER OF COLUMNS THAT DATA SOURCE USES TO POPULATE GRID
        /// </summary>
        public List<EIDSSColumnNames> ColumnNames { get { return _eIDSSColumnNames; } set { _eIDSSColumnNames = value; } }

        //Control that filters the Grid results.  Data from this control will be sent to the API Along with the Grid's ENdpoint
        public string ControlFilterID { get; set; }



        /// <summary>
        /// Control Ids that refresh the Grid
        /// </summary>
        public string ControlIdThatRefreshGrid { get; set; }
        /// <summary>
        /// Button That Refreshes The Grid
        /// </summary>
        public string CustomSearchBtnID { get; set; }

        public string Default { get; internal set; }
        public string Name { get; internal set; }
        public string HACodeNames { get; internal set; }
        public int IntOrder { get; internal set; }

        public bool EnableServerSide { get; set; }

        public string RowCallbackFunction { get; set; }

        public bool EnableProcessingMessage { get; set; }
        /// <summary>
        /// Display built in search
        /// </summary>
        public bool EnableSearching { get; set; }
        public string SearchLabelText { get; set; }


     

        /// <summary>
        /// 
        /// </summary>
        public bool EnableCustomSearching { get; set; }

        public string sDom { get; set; }

        /// <summary>
        /// The Type Of Editor to display when the edit button is clicked
        /// </summary>
        public EditType EditType { get; set; } = EditType.Popup;

        //Add Any additional javascript functions
      
        public string EditPageRedirectLink { get; set; }
        public bool ConfigureForPartial { get; set; }

        //Javascript Method Defined in View. Returned values from API are Passed through to this Custom defined method
        //After Save Attempt
        public string SaveCompleteMethod { get; set; }

        //Javascript Method Defined in View. Returned values from API are Passed through to this Custom defined method after 
        //Deletion attempt
        public string DeleteCompleteMethod { get; set; }

        //ChildRow Ajax Url to get data
        public string ChildRowAjaxUrl { get; set; }
        public bool ShowChildRow { get; set; }
        public bool EnableShowHideColumns { get; set; } = false;
        public bool EnableRowReorder { get; set; } = false;
        public int RowReorderColumnIndex { get; set; } = 0;
        public bool EnablePrintButton { get; set; }
        public bool IsSSRSReportEnabled { get; set; } = false;
        public int Order { get; set; } = 1;
        private string _defaultSortDirection;
        /// <summary>
        /// Allows the default sort direction of the datatable to be defined. 
        /// If undefinded, then default is "asc"
        /// </summary>
        public string DefaultSortDirection 
        { 
            get 
            {
                if (string.IsNullOrEmpty(_defaultSortDirection)) return SortDirection.Ascending;
                else return _defaultSortDirection;
            }
            set 
            {
                _defaultSortDirection = value;
            }
        }

        public EIDSSGridConfiguration()
        {
            _eIDSSColumnNames = new List<EIDSSColumnNames>();
            _controlLabels = new EIDSSControlLabels();
        }
    }


    public class EIDSSColumnNames 
    {
        public EIDSSColumnNames()
        {
        }
     
        ColumnType _columnType;
        GridColumnDropDownType _dropDownType;

        /// <summary>
        /// ERROR MESSAGE TO DISPALY IF AN ERROR
        /// </summary>
        public string ErrorMessage { get; set; }
        
        /// <summary>
        /// NAME OF THE COLUMN USED TO DEFINE DATA
        /// </summary>
        /// 
        public string ColumnName { get; set; }

        /// <summary>
        /// COLUMN TO DISPLAY AS TEXT TO THE UI
        /// </summary>
        public string ColumnTitleHeader { get; set; }

        /// <summary>
        /// Method to call on FocusOut
        /// </summary>
        public string FocusOutMethod { get; set; }
        /// <summary>
        /// CONTROL TO DISPLAY FOR TH COLUMN
        /// </summary>
        public ColumnType ColumnType { get { return _columnType; } set { _columnType = value; } }

        /// <summary>
        /// DROP DOWN TYPE USED TO FETCH DATA
        /// </summary>
        public GridColumnDropDownType DropDownType { get { return _dropDownType; } set { _dropDownType = value; } }

        public bool DisplayDropDownInModalOnly { get; set; }
        /// <summary>
        /// Default Data for Drop Down
        /// </summary>
        public KeyValuePair<string,string> DropDownDefaultData { get; set; }

        /// <summary>
        /// Enter URL here when COlumn type is set to Hyperlink
        /// </summary>
        public string ColumnHyperlinkURL { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string ColumnHyperlinkJSFunction { get; set; }

        /// <summary>
        /// URL TO GET COLUMN DATA
        /// </summary>
        public string ColumnAjaxDataUrl { get; set; }

        /// <summary>
        /// URL ACTION FOR BUTTON
        /// </summary>
        public string ButtonActionUrl { get; set; }

        /// <summary>
        /// IMAGE URL
        /// </summary>
        public string ImageUrl { get; set; }

        /// <summary>
        /// CUSTOM CLIENT METHOD
        /// </summary>
        public string ClientMethod { get; set; }

        /// <summary>
        /// Sets Visibility in Grid
        /// </summary>
        public Boolean Visible { get; set; }

        /// <summary>
        /// Sets Visibility in Modal
        /// </summary>
        public Boolean VisibleInModal { get; set; }

        /// <summary>
        /// COLUMN CLASS NAME
        /// </summary>
        public string ClassName { get; set; }
        /// <summary>
        /// ALLOWS MULTIPLE ITEMS TO BE SELECTED IN A DROPDOWN
        /// </summary>
        public bool   AllowMultipleDropDownItemSelection { get; set; }

        /// <summary>
        /// DEFAULT CONTENT FOR DATA TABLE
        /// </summary>
        public string DefaultContent { get; set; }

        /// <summary>
        /// Is the Column Orderable
        /// </summary>
        public Boolean Orderable { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public bool Searchable { get; set; }

        /// <summary>
        /// Custom Javascript Method
        /// </summary>
        public string  ClientFunction { get; set; }

        /// <summary>
        /// Id Of Modal To Launch For Custom Modals
        /// </summary>
        public string CustomModalID { get; set; }

        /// <summary>
        /// Text To Display For Custom Links
        /// </summary>
        public string CustomLinkText { get; set; }

         /// <summary>
         /// Allows the user to create their own items
         /// for controls that have drop downs
         /// </summary>
        public bool AllowTags { get; set; }

        public string CustomIconClass { get; set; }
        public string CustomToolTip { get; set; }

        /// <summary>
        /// When populating a select 2 drop down, to get the id of the item point to the Associated Field ID
        /// This will help assign Appropirate Key, Value Pairs of Drop Down items. The AssociatedField Should Be a hidden field in the Grid
        /// </summary>
        public string AssociatedFieldId { get; set; }
        /// <summary>
        /// Used  for multiple options in a select 2 dropdown  Set this to true
        /// </summary>
        public bool  SplitCsvValues { get; set; }
        public List<RadionCheckBoxOptions> RadioCheckBoxOptions { get; set; }


        ValidatorSettings _validatorSettings;

        public string ControlName { get; set; }

        public ValidationRuleType VaildationProperty { get; set; }

        public ValidatorSettings ValidationSetting { get { return _validatorSettings; } set { _validatorSettings = value; } }

        public string ValidationRule { get; set; }
        public string Tooltip { get; set; }
        public string HyperLinkDataField { get; set; }
        public string HyperLinkDataFieldText { get; set; }
        public string HyperLinkDataFieldCSSImage { get; set; }

        public string EditRedirect { get; set; }

        public string ChildRowDataField { get; set; }
        public int? MaxLength { get; set; }  //Only for Default

        public long? Min { get; set; }  //Only for Numeric
        public long? Max { get; set; }  //Only for Numeric

        public int ReviewPageNo { get; set; }

        public bool EnabledEditingControledByReferenceTypes { get; set; }
        /// <summary>
        /// Values that control editing of a field in inline editing. This is currently set on  the default column type
        /// </summary>
        public List<string> ReverenceTypesToControlEnabledEditing { get; set; }

        public bool CallAppendedJSFunctions { get; set; }

        public bool DisableIfNumericFieldHasChar { get; set; }

    }
    public enum GridImplementedPageName
    {

        BaseReferenceEditor,
        HumanDiseaseReportSearch,
        Samples,
        Tests,
        Contacts,
        PersonSearch,
        LabSearch,
        VetSeacrh,
        OutbreakSearch,
        VectorType
    }

    public struct SortDirection
    {
        public const string Ascending = "asc";
        public const string Descending = "desc";        
    }

    /// <summary>
    /// SET COLUMN CONTROLS
    /// </summary>
    public enum ColumnType
    {
        /// <summary>
        /// Default Text Box
        /// </summary>
        Default,
        /// <summary>
        /// Select 2 Drop Down
        /// </summary>
        DropDown,
        Numeric,
        Link,
        Button,
        CheckBox,
        RadioButton,
        Delete,
        Edit,
        EditModal,
        Details,
        CustomModal,
        ReadOnly,
        /// <summary>
        /// Enabled checkbox for row selection
        /// </summary>
        Selection,
        /// <summary>
        /// Use when not saving to the database on the user clicking yes; just setting a "flag" for deletion when
        /// a parent record save is performed.
        /// </summary>
        Remove,
        HyperLink,
        HyperLinkToReview,
        ChildRow,
        DeleteUsingCustomMethod,
        EditRedirect,
        DefaultLocked
        
    }

    /// <summary>
    /// SET THE DROP DOWN TYPE TO DETERMINE DATA TO FETCH
    /// </summary>
    public enum GridColumnDropDownType
    {
        OrganizationType,
        Organization,
        Diagnosis,
        Person,
        TestType
    }


    /// <summary>
    /// Simple Data Format
    /// </summary>
    public class TableData
    {
        public int draw { get; set; }
        public int recordsTotal { get; set; }
        public int recordsFiltered { get; set; }
        public List<List<string>> data { get; set; }
        public int iTotalRecords { get; set; }
        public int iTotalDisplayRecords { get; set; }
    }
}