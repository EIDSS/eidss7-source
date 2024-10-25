using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class Select2Configruation
    {
        /// <summary>
        /// Id of control
        /// </summary>
        public string DropDownId { get; set; }

        public bool SelectMultiple { get; set; }

        /// <summary>
        /// Visibility
        /// </summary>
        public bool isVisible { get; set; }
        public string RequiredErrorMessage { get; set; }

        /// <summary>
        /// Indicates if the field is required and needs the jQuery validator properties attached.
        /// </summary>
        public bool isRequired { get; set; }

        public ModelExpression AspFor { get; set; }

        /// <summary>
        /// Inclue the Add Button
        /// </summary>
        public bool IncludeAddButton { get; set; }
        /// <summary>
        /// Modal to display when Add Button is Clicked
        /// </summary>
        public string AddModalId { get; set; }
        public string AddButtonId { get; set; }

        /// <summary>
        /// Inclue the search button.
        /// </summary>
        public bool IncludeSearchButton { get; set; }

        /// <summary>
        /// Modal to display when the search button is clicked.
        /// </summary>
        public string SearchModalId { get; set; }
        public string SearchButtonId { get; set; }

        /// <summary>
        /// Text to display as label 
        /// </summary>
        public string Label { get; set; }

        /// <summary>
        /// Id of control To refresh
        /// </summary>
        public string ControltargetId { get; set; }

        //The ID of the Control that filters data of the Dropdown
        public string FilteredId { get; set; }

        /// <summary>
        ///Endpoint for Target Data
        /// </summary>
        public string ControlTargetUrl { get; set; }

        /// <summary>
        /// Type of Control To Refresh
        /// </summary>
        public DropDownTargetTypes ControlTargetType { get; set; }

        public string DropDownPartialUrl { get; set; }

        /// <summary>
        /// Endpoint that Dropdown uses to populate data
        /// </summary>
        public string Endpoint { get; set; }

        /// <summary>
        /// Allows users to add validation span
        /// </summary>
        public bool AddValidationTag { get; set; }

        /// <summary>
        /// Default data
        /// </summary>
        public Select2DataItem defaultSelect2Selection { get; set; }

        public List<Select2DataItem> defaultSelect2MultipleSelection { get; set; }

        /// <summary>
        ///Custom JavaScript function triggered on change event of Dropdown
        /// </summary>
        public string CustomJsOnChangeFunction { get; set; }

        /// <summary>
        ///Custom JavaScript function triggered as each item is unselected
        /// </summary>
        public string CustomJsOnUnselectFunction { get; set; }

        /// <summary>
        ///Custom JavaScript function triggered on clear event of Dropdown
        /// </summary>
        public string CustomJsOnClearFunction { get; set; }

        /// <summary>
        ///Custom JavaScript function triggered on load event of Dropdown
        /// </summary>
        public string CustomJsOnLoadFunction { get; set; }

        /// <summary>
        /// Controls that are disabled when dropdown is empty comma dilimeted list of controls
        /// </summary>
        public string DisabledControls { get; set; }

        public bool ConfigureForPartial { get; set; }
    }   
}
