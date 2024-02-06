using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Text;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;
using System.IO;
using System.Collections.Specialized;
using EIDSS.Web.TagHelpers.Models;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-grid")]
    public class EIDSSGridTagHelper : TagHelper
    {
        private EIDSSControlLabels _controlLabels;

        /// <summary>
        /// Labels For buttons and Messages
        /// </summary>
        public EIDSSControlLabels ControlLabels
        { get { return _controlLabels; } set { _controlLabels = value; } }

        /// <summary>
        /// ID Of Control
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// Name Of Control
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Class Name Of Control
        /// </summary>
        public string ClassName { get; set; }

        /// <summary>
        /// Class Name of the Control's Label
        /// </summary>
        public string LabelClassName { get; set; }

        /// <summary>
        ///Endpoint control consumes to fetch data
        /// </summary>
        public string EndPoint { get; set; }

        /// <summary>
        /// Label's Display Name
        /// </summary>
        public string LabelName { get; set; }

        /// <summary>
        /// Control who's data is sent to endpoint
        /// To filter this control's data. Can be comma delimited to add multiple controls
        /// </summary>
        public string FilteredControlIds { get; set; }

        /// <summary>
        /// Control who's events trigger refresh of the grid
        /// Reloads data from the endpoint
        /// </summary>
        public string ControlsThatRefreshTheGrid { get; set; }

        public bool disabled { get; set; }

        /// <summary>
        /// ENDPOINT THAT EDIT MODAL USES TO POST DATA
        /// </summary>
        public string EditModalAjaxUrl { get; set; }

        /// <summary>
        /// ENPOINT THAT DELETE MODAL USES TO DELETE ITS DATA
        /// </summary>
        public string DeleteModalAjaxUrl { get; set; }

        public string DetailsAjaxUrl { get; set; }

        private EIDSSGridConfiguration _eIDSSGridConfiguration;

        /// <summary>
        /// Grid Definition
        /// </summary>
        public EIDSSGridConfiguration gridConfiguration
        { get { return _eIDSSGridConfiguration; } set { _eIDSSGridConfiguration = value; } }

        //List that if values are present will make column read only
        //the column is the key, the value (items are the value that are evaluated againgst should be a comma delimeted string)

        /// <summary>
        /// ENable Debugging to JS Console
        /// </summary>
        public bool enableDebug { get; set; }

        /// <summary>
        /// Displays Search Button Above Grid
        /// </summary>
        public bool EnableTopHeaderSearchButton { get; set; }

        /// <summary>
        /// Enable built in Searching
        /// </summary>
        public bool EnableSearch { get; set; }

        /// <summary>
        /// Display Processing Message
        /// </summary>
        public bool enableProcessing { get; set; }

        /// <summary>
        /// Enable Server Side Processing
        /// </summary>
        public bool enableServerSide { get; set; }

        /// <summary>
        /// Allow the reording of datatable rows
        /// </summary>
        public bool enableRowReorder { get; set; }

        /// <summary>
        /// ID of the button to execute a search on the grid
        /// </summary>
        public string CustomSearchBtnID { get; set; }


        private IStringLocalizer _localizer;
        private bool _forceDelete;

        public EIDSSGridTagHelper(IStringLocalizer localizer)
        {
            _controlLabels = new EIDSSControlLabels();
            _eIDSSGridConfiguration = new EIDSSGridConfiguration();
            _localizer = localizer;
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            output.TagName = "table";

            if (this.EnableTopHeaderSearchButton == true)
            {
                var _ = "<div class=\"input-group flex-nowrap md-form form-sm form-2 pl-0 flex-row flex-row-reverse\">" +
                            "<button id = \"SearchBoxBtn\" class=\"btn btn-sm btn-primary\"><i class=\"fas fa-search\"></i></button>" +
                            "<input class=\"form-control-sm my-0 py-1 w-25\" type=\"search\" id=\"SearchBox\" placeholder=\"" + _localizer.GetString(ButtonResourceKeyConstants.SearchButton) + "\" aria-label=\"Search\"></div>" +
                            "<script type='text/javascript'>$('input[type=search]').on('search', function () {" +
                            "$('#SearchBoxBtn').click();" +
                            "});</script>";

                output.PreElement.SetHtmlContent(_);
            }

            if (gridConfiguration.EnableShowHideColumns)
            {
                var showHideColumns = GenerateShowHideColumnContent();
                output.PreElement.SetHtmlContent(showHideColumns);
            }

            //Create Attributes
            if (!string.IsNullOrEmpty(this.ID))
            {
                output.Attributes.SetAttribute("id", this.ID);
            }

            if (!string.IsNullOrEmpty(this.Name))
            {
                output.Attributes.SetAttribute("name", this.Name);
            }

            if (!string.IsNullOrEmpty(this.ClassName))
            {
                output.Attributes.SetAttribute("class", this.ClassName);
            }

            //Style Override for Bootstrap 4 Compatibility
            output.Attributes.SetAttribute("style", "width:100%");

            //Enable Start and  End Tag
            output.TagMode = TagMode.StartTagAndEndTag;

            var sb = new StringBuilder();
            //Adding Options to Select

            output.Content.AppendHtml("<thead><tr>");
            if (gridConfiguration.ColumnNames.Count > 0)
            {
                for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
                {
                    output.Content.AppendHtml("<th>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + " </th>");
                }
            }

            output.Content.AppendHtml("</tr></thead><tbody></tbody>");
            output.PreElement.AppendHtml("<form id=\"" + this.ID + "GridForm\" action=\"\">");
            output.PostElement.AppendHtml("</form>");

            if (gridConfiguration.EditType == EditType.Inline)
            {
                // sb.Append(GenerateInlineEdit());
            }

            if (gridConfiguration.EditType == EditType.Popup)
            {
                sb.Append(GenerateEditModal());
            }

            string strCSS = string.Empty;

            List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>();
            strCSS = sbFile(".\\TagHelpers\\CustomFiles\\GridTagHelperCustomCSS.txt", kvpReplacements);

            //Render Output And Append Additional HTML
            output.PostElement.AppendHtml(strCSS + " " + sb.ToString() + " " + GenerateAddModal() + " " + GenerateDeleteModal() + " " + GenerateConfirmationModal() + " " + GenerateDELETEConfirmationModal() + " " + GenerateREMOVEConfirmationModal() + " " + GenerateInlineEditCancelModal() + " " + GenerateDeleteExceptionModal());

            //Injecting Javascript For Select2
            output.PostElement.AppendHtml(LoadJavascript(gridConfiguration.EditType, gridConfiguration.ShowChildRow));
        }

        /// <summary>
        /// CREATING AND APPENDING JAVASCRIPT CODE TO ENABLE JQUERY DATATABLES FUNCTIONALITY
        /// </summary>
        /// <returns></returns>
        private string LoadJavascript(EditType editType, bool showChildRow)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<script type='text/javascript'>");
            if (!gridConfiguration.ConfigureForPartial)
            {
                //Variable to store hidden columns
                sb.AppendLine("var hiddenColumns =[];");
                sb.AppendLine("window.addEventListener('load', function() {");

                sb.AppendLine("$(document).ready(function() {");
            }
            sb.AppendLine(SetDefaultFilteringData());
            sb.AppendLine(GenerateGridFilteredPostData());
            //CREATE filtering Method
            sb.AppendLine(CreateFilterChangeFunction());
            //Define Data Table
            sb.Append(DefineDataTable());

            //Javascript Functions
            //TABLE GENERATED COLUMN ACTIONS
            sb.AppendLine(GenerateColumnActions());

            //CREATE JAVASCRIPT METHOD TO INITIALIZE SELECT 2 DROPDOWNS.
            sb.AppendLine(GenerateJSSelect2DropDowns());
            sb.AppendLine(SetSelect2DefaultValue());
            //GENERATE DETAILS DATATABLES MARKUP

            //GENERATE EDIT DATATABLES MARKUP

            //GENERATE DROPDOWN DATATABLES MARKUP

            //Build Search Method
            sb.Append(BuildJSSearch());

            //Build Print Method
            sb.Append(BuildPrintList());

            sb.Append(HandleModalClose());
            if (!gridConfiguration.ConfigureForPartial)
            {
                sb.AppendLine("});");
                sb.AppendLine("});");
            }

            //TAKE ENIIRE GRID OBJECT AND SERIALIZE TO A JSON OBJECT :  WILL BE USED TO REFACTOR ALL METHODS
            sb.AppendLine(DefineDefaultJSDefinitions());

            //CREATE JAVASCRIPT METHOD TO INITIALIZE EDIT FUNCTIONALITY
            sb.AppendLine(GenerateJSEdit());
            //CREATE JAVASCRIPT METHOD TO INITIALIZE DELETE FUNCTIONALITY
            sb.AppendLine(GenerateJSDelete());
            //CREATE JAVASCRIPT METHOD TO INITIALIZE DETAILS FUNCTIONALITY
            sb.AppendLine(GenerateJSDetails());

            sb.AppendLine(ShowAlertMessage(string.Empty, string.Empty));

            if (editType == EditType.Popup)
            {
                sb.AppendLine(SetEditModalContent());
            }

            if (editType == EditType.Inline)
            {
                sb.AppendLine(SetInlineEditContent());
                sb.AppendLine(RemoveInlineEditContent());

                sb.AppendLine(CancelInlineEditBuilder());
            }

            sb.AppendLine(SetDeleteModalConent());

            sb.AppendLine(SetRemoveModalConent());

            sb.AppendLine(SetAddModalConent());

            //Create A AJAX GET METHOD
            sb.AppendLine(CreateAJAXGetMethod());

            //Create A AJAX POST METHOD
            sb.AppendLine(CreateAJAXPostMethod());

            //Create AJAX EDIT METHOD
            sb.AppendLine(CreateAJAXEDITMethod());

            if (editType == EditType.Inline)
            {
                sb.AppendLine(CreateAJAXINLINEEDITMethod());
            }

            //Create AJAX DELETE METHOD
            sb.AppendLine(CreateAJAXDELETEMethod());

            sb.AppendLine(CreateAJAXREMOVEMethod());

            //Generates Method to Launch Modals
            sb.AppendLine(ModalBuilderEntry());

            sb.AppendLine(BuildValidators());

            sb.AppendLine(GenerateDeleteExceptionJsScode());

            if (showChildRow)
            {
                sb.AppendLine(GenerateChildRowJSCode());
                sb.AppendLine(AppendChildRowJSCode());
            }
            //Method to Detect EVENTS
            sb.AppendLine(DetectControlChangeEvents()); ;
            sb.AppendLine("</script>");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log('" + sb.ToString() + "');");
            }
            return sb.ToString();
        }

        /// <summary>
        /// Function registers the controls events inside the grid
        /// </summary>
        private string DetectControlChangeEvents()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function " + this.ID + "TableControlValueChanged(){");
            sb.AppendLine("NotificationThatGridInEdit('" + this.ID + "SetInlineEditRow');");
            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// TAKES ENTIRE Property list and converts to JSON
        /// </summary>
        /// <returns></returns>
        private string DefineDefaultJSDefinitions()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("var " + this.ID + "columnType = { \"Default\":0, \"DropDown\":1, \"Numeric\":2, \"Link\":3,\"Button\":4,\"CheckBox\":5,\"RadioButton\":6,\"Delete\":7,\"Edit\":8,\"EditModal\":9,\"Details\":10,\"CustomModal\":11,\"ReadOnly\":12,\"Selection\":13,\"Remove\":14,\"HyperLink\":15,\"ChildRow\":16,\"HyperLinkToReview\":17, \"DefaultLocked\":20}");

            sb.AppendLine("var " + this.ID + "selected  = []");

            if (gridConfiguration.ColumnNames.Count > 0)
            {
                var jsonObj = Newtonsoft.Json.JsonConvert.SerializeObject(gridConfiguration).Replace("null", "\"\"");
                sb.AppendLine("var " + this.ID + "gridJSObject=" + jsonObj + ";");

                sb.AppendLine("var " + this.ID + "idfFilteredData;");
                if (enableDebug == true)
                {
                    sb.AppendLine("console.log(" + this.ID + "gridJSObject);");
                }
            }

            //Initialze Validator For Form Elements
            sb.AppendLine("var " + this.ID + "numOfInvalids = 0;");
            sb.AppendLine("var " + this.ID + "validator = $(\"#" + this.ID + "GridForm\").validate({");
            sb.AppendLine("errorClass : \"dataTableError\",");
            //sb.AppendLine("highlight: function (element, errorClass, validClass) { ");
            //sb.AppendLine("$(element.form).find(\"label[for= \" + element.id + \"]\")");
            //sb.AppendLine(".addClass(\"errorClass\")");
            //sb.AppendLine("},");
            //sb.AppendLine("unhighlight: function (element, errorClass, validClass) { ");
            //sb.AppendLine("$(element.form).find(\"label[for= \" + element.id + \"]\")");
            //sb.AppendLine(".removeClass(\"errorClass\")");
            //sb.AppendLine("},");
            //sb.AppendLine("errorPlacement: function (error, element) { ");
            //sb.AppendLine("error.insertAfter(element); ");
            //sb.AppendLine("},");
            //sb.AppendLine("success: function(label) {");
            //sb.AppendLine("label.addClass(\"errorClass\")"); ;
            //sb.AppendLine("},");
            //sb.AppendLine("submitHandler: function() { },");

            sb.AppendLine("invalidHandler: function() {");
            sb.AppendLine(this.ID + "numOfInvalids = " + this.ID + "validator.numberOfInvalids();");
            sb.AppendLine("}");
            sb.AppendLine("});");
            sb.AppendLine(BuildValidationFunctions());

            return sb.ToString();
        }

        /// <summary>
        /// INITIALIZING THE JQUERY DATATABLES
        /// </summary>
        /// <returns></returns>
        private string DefineDataTable()
        {
            StringBuilder sb = new();

            //Destroy the datatable - added this to fix exception when more than one datatable initialized.
            sb.AppendLine("if ($.fn.DataTable.isDataTable($('#" + ID + "'))) {");
            sb.AppendLine("$('#" + ID + "').DataTable().destroy();");
            sb.AppendLine("}");

            //Initialize DataTable On The Specified DOM Element
            sb.AppendLine("$('#" + ID + "').DataTable( {");

            //if (gridConfiguration.EnableShowHideColumns)
            //{
            //    sb.AppendLine("  dom: 'Bfrtip',");
            //    sb.AppendLine("buttons: [");
            //    sb.AppendLine("'colvis'");
            //    sb.AppendLine("],");
            //}

            //Display Processing Message
            sb.AppendLine("'processing':" + enableProcessing.ToString().ToLower() + ",");

            //Enable Server Side Processing
            sb.AppendLine("'serverSide':" + enableServerSide.ToString().ToLower() + ",");
            sb.AppendLine("'rowCallback': function(row, data) { " + gridConfiguration.RowCallbackFunction + " }, ");
            sb.AppendLine("'start': 0,");
            sb.AppendLine("'length': 100,");
            //sb.AppendLine("'stateSave': true,");

            if (gridConfiguration.EnableRowReorder)
            {
                sb.AppendLine("'rowReorder': ");
                sb.AppendLine("{ ");
                sb.AppendLine("dataSrc: " + gridConfiguration.RowReorderColumnIndex + ",");
                sb.AppendLine("selector: 'tr',");
                sb.AppendLine("update: false");
                sb.AppendLine("},");
            }

            string layout;
            if (gridConfiguration.EnablePrintButton)
            {
                //Layout of Paging, Filtering Controls
                layout = "<'row'<'col-sm-12 col-md-6'f>>" +
                             "<'row'<'col-sm-12'tr>>" +
                             "<'row'<'col-sm-12 col-md-3'iB><'col-sm-12 col-md-3'l><'col-sm-12 col-md-6'p>>";
            }
            else
            {
                //Layout of Paging, Filtering Controls
                layout = "<'row'<'col-sm-12 col-md-6'f>>" +
                             "<'row'<'col-sm-12'tr>>" +
                             "<'row'<'col-sm-12 col-md-3'i><'col-sm-12 col-md-3'l><'col-sm-12 col-md-6'p>>";
            }

            if (!string.IsNullOrEmpty(gridConfiguration.sDom))
            {
                sb.AppendLine("'sDom': \"" + gridConfiguration.sDom + "\",");
            }
            else
            {
                sb.AppendLine("'dom':\"" + layout + "\",");
            }

            sb.AppendLine("'colReorder': true,");
            //ColumnWidth
            sb.AppendLine("'autoWidth': true,");
            //Paging Type
            sb.AppendLine("'pagingType': 'full_numbers'");

            //Ajax Call
            //If the filter is not null then we append its data

            if (!string.IsNullOrEmpty(EndPoint))
            {
                sb.AppendLine(",'ajax':");
                sb.AppendLine("{");
                sb.AppendLine("'url':'" + this.EndPoint + "',");
                sb.AppendLine("'contentType':'application/json',");
                sb.AppendLine("'type':'POST',");
                sb.AppendLine("'data': function(d){");
                //Will need to iterrate controls for other modules

                sb.AppendLine("d.postArgs =" + this.ID + "GetDataToFilterGrid(); ");
                sb.AppendLine("return JSON.stringify(d);");

                sb.AppendLine("},");
                sb.AppendLine("}");
            }

            // }
            //else
            //{
            // sb.AppendLine("'ajax': '" + this.EndPoint + "'");
            // }

            //Columns
            sb.AppendLine(GenerateColumns());

            //Column Definitions
            sb.AppendLine(GenerateColumnDefinitions());

            //Enable Search
            sb.AppendLine(",'searching':" + EnableSearch.ToString().ToLower() + ",");

            //Language

            sb.AppendLine(GenerateGridLanguageSettings());

            //Column Ordering
            //sb.AppendLine("'order': [[ 1, 'asc' ]]");
            sb.AppendLine("'order': [[ " + gridConfiguration.Order + ", '" + gridConfiguration.DefaultSortDirection + "' ]]");

            sb.AppendLine("});");
            //END DEFINING Datatable

            return sb.ToString();
        }

        private string GenerateGridLanguageSettings()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("'language':");
            sb.AppendLine("{");
            sb.AppendLine("'decimal':   '',");
            //sb.AppendLine("'emptyTable':     'No data available in table',");
            sb.AppendLine("'emptyTable':     '" + _localizer.GetString(MessageResourceKeyConstants.NoRecordsFoundMessage) + "',");
            sb.AppendLine("'info':           'Showing _START_ to _END_ of _TOTAL_ entries',");
            sb.AppendLine("'infoEmpty':      'Showing 0 to 0 of 0 entries',");
            sb.AppendLine("'infoFiltered':   '(filtered from _MAX_ total entries)',");
            sb.AppendLine("'infoPostFix':    '',");
            sb.AppendLine("'thousands':      ',',");
            sb.AppendLine("'lengthMenu':     'Show _MENU_ entries',");
            sb.AppendLine("'loadingRecords': 'Loading...',");
            sb.AppendLine("'processing':     'Processing...',");
            sb.AppendLine("'search':         'Search:',");
            sb.AppendLine("'zeroRecords':    'No matching records found',");
            sb.AppendLine("'paginate': {");
            sb.AppendLine("'first':      '<<',");
            sb.AppendLine("'last':       '>>',");
            sb.AppendLine("'next':       '>',");
            sb.AppendLine("'previous':   '<'");
            sb.AppendLine("},");
            sb.AppendLine("'aria': {");
            sb.AppendLine("'sortAscending':  ': activate to sort column ascending',");
            sb.AppendLine("'sortDescending': ': activate to sort column descending'");
            sb.AppendLine("}");
            sb.AppendLine("},");
            return sb.ToString();
        }

        /// <summary>
        /// JQUERY DATATABLES COLUMNS
        /// </summary>
        /// <returns></returns>
        private string GenerateColumns()
        {
            StringBuilder sb = new StringBuilder();
            if (gridConfiguration.ColumnNames.Count > 0)
            {
                sb.AppendLine(",'columns': [");
                for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
                {
                    sb.AppendLine("{");
                    sb.AppendLine("'class': 'details-control',");

                    sb.AppendLine("'orderable':" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ",");
                    sb.AppendLine("'searchable':" + gridConfiguration.ColumnNames[i].Searchable.ToString().ToLower() + ",");

                    //if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ColumnName))
                    //{
                    //    sb.AppendLine("'data':'" + gridConfiguration.ColumnNames[i].ColumnName + "',");
                    //}
                    if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].DefaultContent))
                    {
                        sb.AppendLine("'defaultContent':'" + gridConfiguration.ColumnNames[i].DefaultContent + "'");
                    }

                    sb.AppendLine("},");
                }

                sb.AppendLine("]");
            }

            return sb.ToString();
        }

        /// <summary>
        /// JQUERY DATATABLES COLUMN DEFINITIONS
        /// </summary>
        /// <returns></returns>
        private string GenerateColumnDefinitions()
        {
            StringBuilder sb = new StringBuilder();
            if (gridConfiguration.ColumnNames.Count > 0)
            {
                sb.AppendLine(",'columnDefs': [");
                for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
                {
                    if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Edit)
                    {
                        if (gridConfiguration.EditType == EditType.Inline)
                        {
                            sb.AppendLine("{");

                            sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                            sb.AppendLine(",render: function(data, type, row, meta) {return GenerateInlineEditAction" + this.ID + "(data, type, row, meta); }");
                            sb.AppendLine("},");
                        }
                        else if (gridConfiguration.EditType == EditType.PageRedirect)   
                        {
                            sb.AppendLine("{");
                            sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                            sb.AppendLine(",render: function(data, type, row, meta) {return GenerateEditPageRedirectAction" + this.ID + "(data, type, row, meta); }");
                            sb.AppendLine("},");
                        }
                        else if (gridConfiguration.EditType == EditType.Popup)
                        {
                            sb.AppendLine("{");
                            sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                            sb.AppendLine(",render: function(data, type, row, meta) {return GenerateEditAction" + this.ID + "(data, type, row, meta); }");
                            sb.AppendLine("},");
                        }
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.EditRedirect)
                    {
                        if (gridConfiguration.EditType == EditType.EditPageRedirect)
                        {
                            string strHyperLinkDataFieldIndex = string.Empty;

                            if (!string.IsNullOrEmpty(gridConfiguration.ColumnNames[i].EditRedirect))
                            {
                                for (int iIndex = 0; iIndex < gridConfiguration.ColumnNames.Count; iIndex++)
                                {
                                    if (gridConfiguration.ColumnNames[iIndex].ColumnName.ToString() == gridConfiguration.ColumnNames[i].EditRedirect)
                                    {
                                        strHyperLinkDataFieldIndex = iIndex.ToString();
                                        // break;
                                    }
                                }
                            }
                            sb.AppendLine("{");
                            sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                            sb.AppendLine(",render: function(data, type, row, meta) {return EditGenerateEditPageRedirectAction_" + this.ID + "(data, type, row, meta, " + strHyperLinkDataFieldIndex + "); }");
                            sb.AppendLine("},");
                        }
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Delete)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");

                        sb.AppendLine(",render: function(data, type, row, meta) {   return GenerateDeleteAction" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Remove)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");

                        sb.AppendLine(",render: function(data, type, row, meta) {   return GenerateRemoveAction" + ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Button)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateButtonAction" + this.ID + "_" + i.ToString() + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Details)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateDetailsAction" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Link)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateCustomLinkAction_" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.HyperLink)
                    {
                        string strHyperLinkDataFieldIndex = string.Empty;

                        if (!string.IsNullOrEmpty(gridConfiguration.ColumnNames[i].HyperLinkDataField))
                        {
                            for (int iIndex = 0; iIndex < gridConfiguration.ColumnNames.Count; iIndex++)
                            {
                                if (gridConfiguration.ColumnNames[iIndex].ColumnName.ToString() == gridConfiguration.ColumnNames[i].HyperLinkDataField)
                                {
                                    strHyperLinkDataFieldIndex = iIndex.ToString();
                                }
                            }
                        }

                        sb.AppendLine("{");
                        sb.AppendLine("name: \"" + gridConfiguration.ColumnNames[i].ColumnName + "\",");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateCustomHyperLinkAction_" + this.ID + "_" + gridConfiguration.ColumnNames[i].ClassName + "(data, type, row, meta, " + strHyperLinkDataFieldIndex + "); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.HyperLinkToReview)
                    {
                        string strHyperLinkToReviewDataFieldIndex = string.Empty;

                        if (!string.IsNullOrEmpty(gridConfiguration.ColumnNames[i].HyperLinkDataField))
                        {
                            for (int iIndex = 0; iIndex < gridConfiguration.ColumnNames.Count; iIndex++)
                            {
                                if (gridConfiguration.ColumnNames[iIndex].ColumnName.ToString() == gridConfiguration.ColumnNames[i].HyperLinkDataField)
                                {
                                    strHyperLinkToReviewDataFieldIndex = iIndex.ToString();
                                }
                            }
                        }

                        sb.AppendLine("{");
                        sb.AppendLine("name: \"" + gridConfiguration.ColumnNames[i].ColumnName + "\",");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateCustomHyperLinkToReviewAction_" + this.ID + "_" + gridConfiguration.ColumnNames[i].ClassName + "(data, type, row, meta, " + strHyperLinkToReviewDataFieldIndex + "); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.DropDown)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("name: \"" + gridConfiguration.ColumnNames[i].ColumnName + "\",");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateDropDownAction_" + i.ToString() + "_" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.CustomModal)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return ShowCustomModal_" + i.ToString() + "_" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.CheckBox)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("name: \"" + gridConfiguration.ColumnNames[i].ColumnName + "\",");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateCheckBoxAction_" + i.ToString() + "_" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.ReadOnly)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ClientFunction))
                        {
                            sb.AppendLine(",render: function(data, type, row, meta) {return " + gridConfiguration.ColumnNames[i].ClientFunction + "(data, type, row, meta); }");
                        }
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.Selection)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateSelectionAction_" + i.ToString() + "_" + this.ID + "(data, type, row, meta); }");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.ChildRow)
                    {
                        string strChildRowDataFieldIndex = string.Empty;

                        if (!string.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ChildRowDataField))
                        {
                            for (int iIndex = 0; iIndex < gridConfiguration.ColumnNames.Count; iIndex++)
                            {
                                if (gridConfiguration.ColumnNames[iIndex].ColumnName.ToString() == gridConfiguration.ColumnNames[i].ChildRowDataField)
                                {
                                    strChildRowDataFieldIndex = iIndex.ToString();
                                }
                            }
                        }
                        sb.AppendLine("{");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        sb.AppendLine(",render: function(data, type, row, meta) {return GenerateChildRowAction_" + this.ID + "(data, type, row, meta, " + strChildRowDataFieldIndex + "); }");
                        sb.AppendLine("},");
                    }
                    else
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("name: \"" + gridConfiguration.ColumnNames[i].ColumnName + "\",");
                        sb.AppendLine("targets:[" + i.ToString() + "], visible: " + gridConfiguration.ColumnNames[i].Visible.ToString().ToLower() + ", orderable:" + gridConfiguration.ColumnNames[i].Orderable.ToString().ToLower() + ", type: 'dom-text'");
                        if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ClientFunction))
                        {
                            sb.AppendLine(",render: function(data, type, row, meta) {return " + gridConfiguration.ColumnNames[i].ClientFunction + "(data, type, row, meta); }");
                        }
                        sb.AppendLine("},");
                    }
                }

                sb.AppendLine("]");

                sb.AppendLine(",'columns': [");
                for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
                {
                    if (gridConfiguration.ColumnNames[i].ColumnType != ColumnType.ChildRow)
                    {
                        sb.AppendLine("{");
                        sb.AppendLine("defaultContent:''");
                        sb.AppendLine("},");
                    }
                    else if (gridConfiguration.ColumnNames[i].ColumnType == ColumnType.ChildRow)
                    {
                        sb.AppendLine("{");
                        //sb.AppendLine("className: 'details-control-item',");
                        sb.AppendLine("data: null,");
                        sb.AppendLine("orderable: false,");
                        sb.AppendLine("defaultContent: '<i class=\"fas fa-caret-down fa-2x\"></i>',");
                        sb.AppendLine("},");
                    }
                }

                sb.AppendLine("]");
            }

            return sb.ToString();
        }

        /// <summary>
        /// JQUERY COLUMN ACTIONS
        /// HERE WE DEFINE WHAT COLUMNS OUTPUT SHOULD DISPLAY
        /// THESE JS FUNCTIONS GENERATE CODE FOR DATATABLES TO CREATE CUSTOM HTML IN EACH SPECIFIED
        /// CELL FOR EACH ROW
        /// </summary>
        /// <returns></returns>
        private string GenerateColumnActions()
        {
            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                var _columnType = gridConfiguration.ColumnNames[i].ColumnType;
                switch (_columnType)
                {
                    case ColumnType.Edit:
                        if (gridConfiguration.EditType == EditType.Popup)
                        {
                            sb.AppendLine(DataTableEditBuilder());
                        }
                        else if ((gridConfiguration.EditType == EditType.Inline))
                        {
                            sb.AppendLine(DataTableInlineEditBuilder());
                        }
                        else if ((gridConfiguration.EditType == EditType.PageRedirect))
                        {
                            sb.AppendLine(DataTableEditPageRedirectBuilder());
                        }
                        break;

                    case ColumnType.Delete:
                        sb.AppendLine(DataTableDeleteBuilder());
                        break;

                    case ColumnType.Remove:
                        sb.AppendLine(DataTableRemoveBuilder());
                        break;

                    case ColumnType.Button:
                        sb.AppendLine(DataTableButtonBuilder(i, gridConfiguration.ColumnNames[i].ButtonActionUrl, gridConfiguration.ColumnNames[i].ClientFunction, gridConfiguration.ColumnNames[i].CustomIconClass, gridConfiguration.ColumnNames[i].CustomLinkText));
                        break;

                    case ColumnType.Details:
                        sb.AppendLine(DataTableDetailsBuilder());
                        break;

                    case ColumnType.CustomModal:
                        sb.AppendLine(DataTableCustomModalLoaderBuilder(i, gridConfiguration.ColumnNames[i].CustomModalID, gridConfiguration.ColumnNames[i].CustomLinkText, gridConfiguration.ColumnNames[i].CustomIconClass, gridConfiguration.ColumnNames[i].CustomToolTip, gridConfiguration.ColumnNames[i].ClientFunction));
                        break;

                    case ColumnType.DropDown:
                        var colClass = "eidssSelect2DropDown" + i.ToString();
                        if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ClassName))
                        {
                            colClass = gridConfiguration.ColumnNames[i].ClassName;
                        }
                        sb.AppendLine(DataTableDropDownBuilder(colClass, i, gridConfiguration.ColumnNames[i].DisplayDropDownInModalOnly));
                        break;

                    case ColumnType.CheckBox:
                        sb.AppendLine(DataTableCheckBoxBuilder(i));
                        break;

                    case ColumnType.Selection:
                        sb.AppendLine(DataTableSelectionBuilder(i));
                        break;

                    case ColumnType.Link:
                        sb.AppendLine(DataTableCustomLinkBuilder(i, gridConfiguration.ColumnNames[i].ColumnHyperlinkURL, gridConfiguration.ColumnNames[i].ColumnHyperlinkJSFunction, gridConfiguration.ColumnNames[i].CustomLinkText, gridConfiguration.ColumnNames[i].ClassName));
                        break;

                    case ColumnType.HyperLink:
                        sb.AppendLine(DataTableCustomHyperLinkBuilder(i, gridConfiguration.ColumnNames[i].ColumnHyperlinkURL, gridConfiguration.ColumnNames[i].CustomLinkText, gridConfiguration.ColumnNames[i].ClassName, gridConfiguration.ColumnNames[i].HyperLinkDataFieldCSSImage, gridConfiguration.ColumnNames[i].HyperLinkDataFieldText));
                        break;

                    case ColumnType.HyperLinkToReview:
                        sb.AppendLine(DataTableCustomHyperLinkToReviewBuilder(i, gridConfiguration.ColumnNames[i].ColumnHyperlinkURL, gridConfiguration.ColumnNames[i].CustomLinkText, gridConfiguration.ColumnNames[i].ClassName, gridConfiguration.ColumnNames[i].HyperLinkDataFieldCSSImage, gridConfiguration.ColumnNames[i].HyperLinkDataFieldText, gridConfiguration.ColumnNames[i].ReviewPageNo));
                        break;

                    case ColumnType.ChildRow:
                        sb.AppendLine(DataTableChildRowBuilder(i));
                        break;

                    case ColumnType.EditRedirect:
                        sb.AppendLine(EditDataTableEditPageRedirectBuilder(i));
                        break;

                    default:
                        break;
                }
            }
            return sb.ToString();
        }

        /// <summary>
        /// GenerateShowHideColumnContent
        /// </summary>
        /// <returns></returns>
        private string GenerateShowHideColumnContent()
        {
            StringBuilder sb = new StringBuilder();

            return sb.ToString();
        }

        /// <summary>
        /// Link To Add A New Record ---Just A Stub Here
        /// </summary>
        /// <returns></returns>
        private string DataTableAddBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateAddAction" + this.ID + "(data, type, row, meta){");
            sb.AppendLine("var val = row[0];");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = \"\";");
            //sb.AppendLine("sel += \"<a href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridAdd) + "' onclick='SetAddModalContent(\"+  JSON.stringify(row) +\");return false;' data-toggle='modal' data-backdrop='static' data-keyboard='false' data-target='#" + this.ID + "addModal'><span class='fa fa-plus'>" + _localizer.GetString(ButtonResourceKeyConstants.AddButton) + "</span>\";");
            sb.AppendLine("sel += \"<button type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridAdd) + "' onclick='SetAddModalContent(\"+  JSON.stringify(row) +\");' data-toggle='modal' data-backdrop='static' data-keyboard='false' data-target='#" + this.ID + "addModal'><span class='fa fa-plus'>" + _localizer.GetString(ButtonResourceKeyConstants.AddButton) + "</span></button>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Link To Edit a Record
        /// </summary>
        /// <returns></returns>
        private string DataTableEditBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateEditAction" + this.ID + "(data, type, row, meta){");
            sb.AppendLine("var val = row[0];");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = \"\";");
            //sb.AppendLine("sel += \"<a href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetEditModalContent" + ID +  "( this,\"+ JSON.stringify(row) + \");return false;' data-toggle='modal' data-target='#" + this.ID + "editModal'><span class='fas fa-edit fa-lg'></span>\";");
            sb.AppendLine("sel += \"<button type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetEditModalContent" + ID + "( this,\"+ JSON.stringify(row) + \");' data-toggle='modal' data-target='#" + this.ID + "editModal'><span class='fas fa-edit fa-lg'></span></button>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Inline Edit
        /// </summary>
        /// <returns></returns>
        private string DataTableInlineEditBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateInlineEditAction" + this.ID + "(data, type, row, meta){");
            sb.AppendLine("var val = row[0];");
            //sb.AppendLine("console.log(row);");
            //sb.AppendLine("console.log( $(this));");
            sb.AppendLine("var $row = $(this).closest(" + "\"tr\"" + ")");
            sb.AppendLine("var $tds = $row.find(" + "\"td\"" + ").not(':first').not(':last');");
            //sb.AppendLine("console.log($tds);");

            sb.AppendLine("var table = $('#" + this.ID + "').DataTable()");
            //sb.AppendLine("console.log(table);");

            sb.AppendLine("var parent_row = $(table).closest(" + "\"tr\"" + ")");
            //sb.AppendLine("console.log(parent_row);");

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = \"\";");
            //sb.AppendLine("sel += \"<a id='Edit_\" + meta.row.toString() +\"' class='editGridRecord' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(row) + \");return false;'><span class='fas fa-edit'></span></a>\";");

            sb.AppendLine("for (var i = 0; i < row.length; i++)");
            sb.AppendLine("{");
            sb.AppendLine("if (row[i] === null || row[i] === '')");
            sb.AppendLine("{");
            sb.AppendLine("}");
            sb.AppendLine("else");
            sb.AppendLine("{");
            sb.AppendLine("row[i] = row[i].replace(\"'\",\"&apos;\");");
            sb.AppendLine("}");
            //&apos;
            sb.AppendLine("}");

            //LM_ Updated to enable and disable edit button if RowDataEnablesAndDisblesDelete = true
            //FOR 4711,4712,4713
            if (gridConfiguration.RowDataEnablesAndDisblesDelete == true)
            {
                sb.AppendLine("if(data == \"True\"){");
                sb.AppendLine("sel += \"<button id='Edit_\" + meta.row.toString() +\"' class='btn btn-link editGridRecord' type='button' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(row) + \");'><span class='fas fa-edit'></span></button>\";");
                sb.AppendLine("}else{");
                sb.AppendLine("sel += \"<button id='Edit_\" + meta.row.toString() +\"' class='btn btn-link editGridRecord' type='button' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "'><span class='fas fa-edit' style='color:grey;'></span></button>\";");
                sb.AppendLine("};");
            }
            else if(gridConfiguration.EnableNavigationAwayNotification == true) {
                sb.AppendLine("sel += \"<button id='Edit_\" + meta.row.toString() +\"' class='btn btn-link editGridRecord' type='button' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(row) + \");SetNavigationAwayNotification();'><span class='fas fa-edit'></span></button>\";");
            }
            else
            {
                sb.AppendLine("sel += \"<button id='Edit_\" + meta.row.toString() +\"' class='btn btn-link editGridRecord' type='button' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(row) + \");'><span class='fas fa-edit'></span></button>\";");
            }
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Link to redirect to the details view to edit a record.
        /// </summary>
        /// <returns></returns>
        private string DataTableEditPageRedirectBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateEditPageRedirectAction" + this.ID + "(data, type, row, meta){");
            sb.AppendLine("var val = row[0];");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = \"\";");
            sb.AppendLine("sel += \"<a href='" + gridConfiguration.EditPageRedirectLink + "/\" + row[0] + \"' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "'><span class='fas fa-edit fa-lg'></span>\";");

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        private string EditDataTableEditPageRedirectBuilder(int rowId)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function EditGenerateEditPageRedirectAction_" + this.ID + "(data, type, row, meta, colIndex){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var sel = \"\";");
            sb.AppendLine("if (colIndex >= 0) {");
            sb.AppendLine("sel += \"<a href='" + gridConfiguration.EditPageRedirectLink + "/\" + row[colIndex] + \"' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "'><span class='fas fa-edit fa-lg'></span>\";");
            //sb.AppendLine("sel += \"<i class='fas fa-caret-down fa-lg' style='cursor: pointer'></i>\";");
            sb.AppendLine("sel += \"<input id='hiddenId' type ='hidden'  value =  '\" + row[colIndex] + \"'>\";");
            sb.AppendLine("}");
            sb.AppendLine("return sel;");
            sb.AppendLine("};");
            return sb.ToString();
        }

        //Link To Delete a Record
        private string
            DataTableDeleteBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateDeleteAction" + this.ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            //sb.AppendLine("console.log(JSON.stringify(data));");
            sb.AppendLine("var sel = '';");

            if (gridConfiguration.RowDataEnablesAndDisblesDelete == true)
            {
                sb.AppendLine("if(data == \"True\"){");
                //sb.AppendLine("sel += \"<a id='Delete_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); " + "SetDeleteModalContent" + ID + "(\"+  JSON.stringify(row) +\");return false;'><span class='fa fa-trash fa-1x'></span>\";");
                sb.AppendLine("sel += \"<button id='Delete_\" + meta.row.toString() +\"' type='button' class='btn btn-link'  title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); " + "SetDeleteModalContent" + ID + "(\"+  JSON.stringify(row) +\");'><span class='fa fa-trash fa-1x'></span></button>\";");
                sb.AppendLine("}else{");
                //sb.AppendLine("sel += \"<a id='Delete_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "'><span class='fa fa-trash fa-1x'></span>\";");
                sb.AppendLine("sel += \"<button id='Delete_\" + meta.row.toString() +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "'><span class='fa fa-trash fa-1x' style='color:grey;'></span></button>\";");
                sb.AppendLine("};");
            }
            else
            {
                if (!String.IsNullOrEmpty(gridConfiguration.DeleteCustomMethod))
                {
                    //sb.AppendLine("sel += \"<a id='Delete_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); " + "SetDeleteModalContent" + ID + "(\"+  JSON.stringify(row) +\");return false;'><span class='fa fa-trash fa-1x'></span>\";");
                    sb.AppendLine("sel += \"<button id='Delete_\" + meta.row.toString() +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + gridConfiguration.DeleteCustomMethod + "(\"+  JSON.stringify(row) +\",\"+  meta.row +\");'><span class='fa fa-trash fa-1x'></span></button>\";");
                }
                else
                {
                    //sb.AppendLine("sel += \"<a id='Delete_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); " + "SetDeleteModalContent" + ID + "(\"+  JSON.stringify(row) +\");return false;'><span class='fa fa-trash fa-1x'></span>\";");
                    sb.AppendLine("sel += \"<button id='Delete_\" + meta.row.toString() +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); " + "SetDeleteModalContent" + ID + "(\"+  JSON.stringify(row) +\");'><span class='fa fa-trash fa-1x'></span></button>\";");
                }
            }

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        //Link To Remove a Record
        private string DataTableRemoveBuilder()
        {
            StringBuilder sb = new();
            sb.AppendLine("function GenerateRemoveAction" + ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var sel = '';");

            if (gridConfiguration.RowDataEnablesAndDisblesDelete == true)
            {
                sb.AppendLine("if(data == \"True\"){");
                //sb.AppendLine("sel += \"<a id='Remove_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + ID + "LaunchModal(5); " + "SetRemoveModalContent(\" + JSON.stringify(row) +\");return false;'><span class='fa fa-trash fa-1x'></span>\";");
                sb.AppendLine("sel += \"<button id='Remove_\" + meta.row.toString() +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + ID + "LaunchModal(5); " + "SetRemoveModalContent(\" + JSON.stringify(row) +\");'><span class='fa fa-trash fa-1x'></span></button>\";");
                sb.AppendLine("} else {");
                //sb.AppendLine("sel += \"<a id='Remove_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "'><span class='fa fa-trash fa-1x'></span>\";");
                sb.AppendLine("sel += \"<button id='Remove_\" + meta.row.toString() +\"'  type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "'><span class='fa fa-trash fa-1x'></span></button>\";");
                sb.AppendLine("};");
            }
            else
            {
                //sb.AppendLine("sel += \"<a id='Remove_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + ID + "LaunchModal(5); " + "SetRemoveModalContent(\" + JSON.stringify(row) +\");return false;'><span class='fa fa-trash fa-1x'></span>\";");
                sb.AppendLine("sel += \"<button id='Remove_\" + meta.row.toString() +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + ID + "LaunchModal(5); " + "SetRemoveModalContent(\" + JSON.stringify(row) +\");'><span class='fa fa-trash fa-1x'></span></button>\";");
            }

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Button for a Record
        /// </summary>
        /// <returns></returns>
        private string DataTableButtonBuilder(int i, string buttonUrl, string clientFunction, string customIconClass, string customLinkText)
        {
            StringBuilder sb = new StringBuilder();

            if (string.IsNullOrEmpty(this.gridConfiguration.ColumnNames[i].ButtonActionUrl))
            {
                buttonUrl = "";
            }
            else
            {
                buttonUrl = "href='" + this.gridConfiguration.ColumnNames[i].ButtonActionUrl + "'";
            }
            if (!string.IsNullOrEmpty(this.gridConfiguration.ColumnNames[i].ClientFunction))
            {
                clientFunction = this.gridConfiguration.ColumnNames[i].ClientFunction;
            }

            if (!string.IsNullOrEmpty(customIconClass))
            {
                customLinkText = "";
            }
            else if (!string.IsNullOrEmpty(this.gridConfiguration.ColumnNames[i].CustomLinkText))
            {
                customLinkText = this.gridConfiguration.ColumnNames[i].CustomLinkText;
            }
            else
            {
                customIconClass = "fa fa-ellipsis-h fa-1x";
            }

            sb.AppendLine("function GenerateButtonAction" + this.ID + "_" + i.ToString() + "(data, type, row, meta){");

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = '';");
            //sb.AppendLine("sel += \"<a id='Edit_\" + meta.row.toString() +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(row) + \");'><span class='fas fa-edit'></span></a>\";");
            //sb.AppendLine("sel += \"<a style='cursor:pointer;' id='Button_" + i.ToString() + "_\" + meta.row.toString() + \"' " + buttonUrl + " title='' onclick='" + clientFunction + "(this,\" + meta.row.toString() + \",\" + JSON.stringify(row) +\" );'><span class='" + customIconClass + "'>" + customLinkText + "</span>\";");
            sb.AppendLine("sel += \"<button type='button' class='btn btn-link' style='cursor:pointer;' id='Button_" + i.ToString() + "_\" + meta.row.toString() + \"' " + buttonUrl + " title='' onclick='" + clientFunction + "(this,\" + meta.row.toString() + \",\" + JSON.stringify(row) +\" );'><span class='" + customIconClass + "'>" + customLinkText + "</span></button>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            Console.WriteLine(sb.ToString());

            return sb.ToString();
        }

        /// <summary>
        /// Link to view Details of a Record
        /// </summary>
        /// <returns></returns>
        private string DataTableDetailsBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateDetailsAction" + this.ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var sel = '';");
            //sb.AppendLine("sel += \"<a href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "' onclick='Details(\"+  JSON.stringify(row) +\");return false;'><span class='fas fa-clipboard-check fa-lg'></span>\";");
            sb.AppendLine("sel += \"<button type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "' onclick='Details(\"+  JSON.stringify(row) +\");'><span class='fas fa-clipboard-check fa-lg'></span></button>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Allows for creating a custom url
        /// </summary>
        /// <returns></returns>
        private string DataTableCustomLinkBuilder(int rowId, string hyperlink, string jsFunction, string linkText, string className)
        {
            StringBuilder sb = new StringBuilder();
            String _linkText = String.IsNullOrEmpty(linkText) ? string.Empty : linkText;

            sb.AppendLine("function GenerateCustomLinkAction_" + this.ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            //sb.AppendLine("console.log(data);");
            sb.AppendLine("var sel = '';");
            if (string.IsNullOrEmpty(jsFunction))
                sb.AppendLine("sel += \"<a href='" + hyperlink + "?id=\" + data + \"' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "'><span class='" + className + "'>" + _linkText + "</span>\";");
            else
                sb.AppendLine("sel += \"<a data-dismiss='modal' href='" + hyperlink + "' onclick='" + jsFunction + "(\" + JSON.stringify(row) + \"); return false;' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "'><span class='" + className + "'>" + _linkText + "</span>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Allows for creating a custom url
        /// </summary>
        /// <returns></returns>
        ///        
        private string DataTableCustomHyperLinkBuilder(int rowId, string hyperlink, string linkText, string className, string CSSImage, string displayText)
        {
            StringBuilder sb = new StringBuilder();
            String _linkText = String.IsNullOrEmpty(linkText) ? string.Empty : linkText;

            sb.AppendLine("function GenerateCustomHyperLinkAction_" + this.ID + "_" + className + "(data, type, row, meta, index){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("console.log(data);");
            sb.AppendLine("var sel = '';");
            sb.AppendLine("var altData = '';");
            sb.AppendLine("if (index >= 0) {");
            sb.AppendLine(" altData = row[index];");
            sb.AppendLine("}");
            sb.AppendLine("else{");
            sb.AppendLine("altData = data;");
            sb.AppendLine("}");
            sb.AppendLine("if (data == undefined){");
            sb.AppendLine(" data = '" + displayText + "'");
            sb.AppendLine("}");

            if (!string.IsNullOrEmpty(CSSImage))
            {
                sb.AppendLine("sel += \"<a href='" + hyperlink + "?queryData=\" + altData + \"' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "'><span class='" + className + " " + CSSImage + "'></span>\";");
            }
            else
            {
                sb.AppendLine("sel += \"<a href='" + hyperlink + "?queryData=\" + altData + \"' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "'><span class='" + className + " " + CSSImage + "'>\" + data + \"</span>\";");
            }            
            
            
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Allows for creating a custom url
        /// </summary>
        /// <returns></returns>
        private string DataTableCustomHyperLinkToReviewBuilder(int rowId, string hyperlink, string linkText, string className, string CSSImage, string displayText, int reviewpageNo)
        {
            StringBuilder sb = new StringBuilder();
            String _linkText = String.IsNullOrEmpty(linkText) ? string.Empty : linkText;

            sb.AppendLine("function GenerateCustomHyperLinkToReviewAction_" + this.ID + "_" + className + "(data, type, row, meta, index){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("console.log(data);");
            sb.AppendLine("var sel = '';");
            sb.AppendLine("var altData = '';");
            sb.AppendLine("if (index >= 0) {");
            sb.AppendLine(" altData = row[index];");
            sb.AppendLine("}");
            sb.AppendLine("else{");
            sb.AppendLine("altData = data;");
            sb.AppendLine("}");
            sb.AppendLine("if (data == undefined){");
            sb.AppendLine(" data = '" + displayText + "'");
            sb.AppendLine("}");
            sb.AppendLine("sel += \"<a href='" + hyperlink + "?id=\"+altData+\"&reviewPageNo=" + reviewpageNo + "' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDetails) + "'><span class='" + className + " " + CSSImage + "'>\" + data + \"</span>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Generates CheckBox
        /// </summary>
        /// <param name="columnClassName"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        private string DataTableCheckBoxBuilder(int i)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateCheckBoxAction_" + i.ToString() + "_" + this.ID + "(data, type, row, meta){");
            if (enableDebug)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var checkedFlag = data.toUpperCase() == 'TRUE' ? 'checked' :'';");
            sb.AppendLine("var ctrl = \"<input type='checkbox'  disabled='disabled'" + "\" + checkedFlag + \" id='" + this.gridConfiguration.ColumnNames[i].ColumnName.ToLower().Replace(" ", string.Empty) + "\" + meta.row + \"' />\";");
            if (enableDebug)
            {
                sb.AppendLine("console.log(ctrl);");
            }
            sb.AppendLine("return ctrl;");
            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// Generates CheckBox
        /// </summary>
        /// <param name="columnClassName"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        private string DataTableSelectionBuilder(int i)
        {
            StringBuilder sb = new();
            sb.AppendLine("function GenerateSelectionAction_" + i.ToString() + "_" + ID + "(data, type, row, meta){");
            if (enableDebug)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var checkedFlag = data.toString().toUpperCase() == 'TRUE' ? 'checked' : '';");
            sb.AppendLine("var ctrl = \"<input type='checkbox' " + "\" + checkedFlag + \" id='" + gridConfiguration.ColumnNames[i].ColumnName.ToLower().Replace(" ", string.Empty) + "\" + meta.row + \"' />\";");
            if (enableDebug)
            {
                sb.AppendLine("console.log(ctrl);");
            }
            sb.AppendLine("return ctrl;");
            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// Generates A DropDown in Row/Column
        /// </summary>
        /// <param name="columnClassName"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        private string DataTableDropDownBuilder(string columnClassName, int i, bool displayDropDownInModalOnly)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateDropDownAction_" + i.ToString() + "_" + this.ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var sel = '';");
            if (displayDropDownInModalOnly == true)
            {
                sb.AppendLine("sel +=  data ;");
            }
            else
            {
                sb.AppendLine("sel += \"<select  style='min-width: 150px; width: 90%;' class='form-control " + columnClassName + "' id='" + this.gridConfiguration.ColumnNames[i].ColumnName.ToLower().Replace(" ", string.Empty) + "\" + meta.row + \"' ><option>\" + data +\"</option></select>\";");
            }

            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        private string DataTableCustomModalLoaderBuilder(int i, string customModalId, string customLinkText, string customIconClass, string customTooltip, string clientFunction)
        {
            if (!string.IsNullOrEmpty(customIconClass))
            {
                customLinkText = "";
            }

            StringBuilder sb = new();
            sb.AppendLine("function ShowCustomModal_" + i.ToString() + "_" + this.ID + "(data, type, row, meta){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }

            sb.AppendLine("var sel = \"\";");
            //sb.AppendLine("sel += \"<button type='button' class='btn btn-link' id='lnkCustomModal' title='" + customTooltip + "' onclick='setRowIdentifier(\" + row[" + i + "] + \");" + clientFunction + "(\"+  JSON.stringify(row) +\");' data-toggle='modal' data-target='#" + customModalId + "'><span class='" + customIconClass + "'></span></button>\";");
            sb.AppendLine("sel += \"<button type='button' class='btn btn-link' id='lnkCustomModal' title='" + customTooltip + "' onclick='" + clientFunction + "(\"+  JSON.stringify(row) +\");' data-toggle='modal' data-target='#" + customModalId + "'><span class='" + customIconClass + "'></span></button>\";");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(sel);");
            }
            sb.AppendLine("return sel;");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// Child row
        /// </summary>
        /// <returns></returns>
        private string DataTableChildRowBuilder(int rowId)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GenerateChildRowAction_" + this.ID + "(data, type, row, meta, colIndex){");
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(row);");
            }
            sb.AppendLine("var sel = \"\";");
            sb.AppendLine("if (colIndex >= 0) {");
            sb.AppendLine("sel += \"<i class='fas fa-caret-down fa-lg' style='cursor: pointer'></i>\";");
            sb.AppendLine("sel += \"<input id='hiddenId' type ='hidden'  value =  '\" + row[colIndex] + \"'>\";");
            sb.AppendLine("}");
            sb.AppendLine("return sel;");
            sb.AppendLine("};");
            return sb.ToString();
        }

        private static string ShowAlertMessage(string pHeader, string pError)
        {
            StringBuilder strScript = new StringBuilder();

            return strScript.ToString();
        }

        /// <summary>
        ///GENERATE JAVASCRIPT FOR EDIT BUTTON
        /// </summary>
        /// <returns></returns>
        private string GenerateJSEdit()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("function Edit(a){");
            sb.AppendLine("var editParms =JSON.stringify(a);");
            sb.AppendLine("console.log(editParms);");
            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATE JAVASCRIPT Method Envoked By DETAILS LINK
        /// </summary>
        /// <returns></returns>
        private string GenerateJSDetails()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function Details(a){");
            sb.AppendLine("var _detailSerialized =JSON.stringify(a);");
            sb.AppendLine("var _detailDeserialized =JSON.parse(_detailSerialized);");
            //sb.AppendLine("console.log(_detailDeserialized);");

            sb.AppendLine("var postObj ={};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = _detailDeserialized[" + i + "];");
            }
            //sb.AppendLine("console.log(postObj);");

            //SEND DATA TO ENPOINT
            sb.AppendLine("$.post(\'" + this.DetailsAjaxUrl + "\', postObj, function(data){");

            sb.AppendLine("});");

            //End JS FUNCTION

            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        /// GENERATE JAVASCRIPT Method ENVOKED BY DELETE LINK
        /// </summary>
        /// <returns></returns>
        private string GenerateJSDelete()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function Delete(a){");
            sb.AppendLine("var editParms =JSON.stringify(a);");

            //sb.AppendLine("console.log(editParms);");
            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        ///GENERATE SELECT 2 DROPDOWN INITIATION
        /// </summary>
        /// <returns></returns>
        private string GenerateJSSelect2DropDowns()
        {
            string idfFilteredData = string.Empty;
            StringBuilder sb = new StringBuilder();
            UriBuilder uriBuilder = new UriBuilder();

            sb.AppendLine("//Instantiate Select 2 Library on DropDown");
            //  sb.AppendLine("function InitiateDropDown(dropdownId){");
            // sb.AppendLine("console.log(dropdownId);");
            sb.AppendLine("$('#" + this.ID + "').on('draw.dt', function() {");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                var _columnType = gridConfiguration.ColumnNames[i].ColumnType;
                switch (_columnType)
                {
                    case ColumnType.DropDown:
                        var colClass = "eidssSelect2DropDown" + i.ToString();
                        if (!String.IsNullOrEmpty(gridConfiguration.ColumnNames[i].ClassName))
                        {
                            colClass = gridConfiguration.ColumnNames[i].ClassName;
                        }

                        sb.AppendLine("$(\'." + colClass + "\').select2({");
                        sb.AppendLine("ajax: {");
                        sb.AppendLine("url: " + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnAjaxDataUrl,");
                        sb.AppendLine("data: function (params) {");
                        sb.AppendLine("var query = {");

                        if (!String.IsNullOrEmpty(this.FilteredControlIds))
                        {
                            sb.AppendLine("data: JSON.stringify(" + this.ID + "idfFilteredData),");
                        }
                        sb.AppendLine(" term: params.term, page: params.page || 1");
                        sb.AppendLine("}");
                        sb.AppendLine("return query");
                        sb.AppendLine("}");
                        sb.AppendLine("},");
                        sb.AppendLine("width: 'resolve',");
                        sb.AppendLine("tags:" + gridConfiguration.ColumnNames[i].AllowTags.ToString().ToLower() + ", ");
                        sb.AppendLine("closeOnSelect: true,");
                        sb.AppendLine("allowClear: true,");
                        sb.AppendLine("multiple:" + gridConfiguration.ColumnNames[i].AllowMultipleDropDownItemSelection.ToString().ToLower() + ", ");
                        sb.AppendLine("placeholder: ' '");
                        sb.AppendLine("});");

                        ////Set Default Selection of DropDown
                        //if (gridConfiguration.ColumnNames[i].DropDownDefaultData.Key != null & gridConfiguration.ColumnNames[i].DropDownDefaultData.Value != null)
                        //{
                        //    sb.AppendLine("var newOption = new Option(" + gridConfiguration.ColumnNames[i].DropDownDefaultData.Value + "," + gridConfiguration.ColumnNames[i].DropDownDefaultData.Key + ", true, true);");
                        //    sb.AppendLine("$('#" + this.ID + "').append(newOption);");

                        //}
                        break;

                    default:

                        break;
                }
            }
            sb.AppendLine("});");

            return sb.ToString();
        }

        /// <summary>
        /// SELECT 2 DROP DOWN DEFAULT VALUE SETTING
        /// </summary>
        /// <returns></returns>
        private string SetSelect2DefaultValue()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function SetSelect2DefaultValue(id,defaultValue){");
            sb.AppendLine("var newOption = new Option(id, defaultValue, true, true);");
            sb.AppendLine("$('#' + id).append(newOption)");
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATE HTML MARK UP FOR MODAL EDITING
        /// </summary>
        /// <returns></returns>
        public string GenerateEditModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div>");
            sb.AppendLine("<form id=\"" + this.ID + "editModalPopupForm\"\">");
            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "editModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-lg\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h4 class=\"modal-title\">" + gridConfiguration.ControlLabels.EditModalTitle + "</h4>");
            sb.AppendLine("<button type =\"button\" class=\"close\" data-dismiss=\"modal\"><span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");

            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                string visibility = gridConfiguration.ColumnNames[i].VisibleInModal == true ? "block" : "none";
                var _columnType = gridConfiguration.ColumnNames[i].ColumnType;
                switch (_columnType)
                {
                    case ColumnType.DropDown:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";\'> " + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label><select id=\'ctrlEdit_" + i + "\' style=\'display:" + visibility + ";min-width: 150px; width: 90%;\'></select>");
                        break;

                    case ColumnType.Default:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label><input id=\'ctrlEdit_" + i + "\' style=\'display:" + visibility + ";\'></input>");
                        break;

                    case ColumnType.Numeric:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label><input type=\"number\" id=\'ctrlEdit_" + i + "\' style=\'display:" + visibility + ";\' onkeydown=\"return event.keyCode !== 69\"></input>");
                        break;

                    case ColumnType.CheckBox:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label></br>");
                        if (gridConfiguration.ColumnNames[i].RadioCheckBoxOptions != null)
                        {
                            for (int c = 0; c < gridConfiguration.ColumnNames[i].RadioCheckBoxOptions.Count; c++)
                            {
                                var options = gridConfiguration.ColumnNames[i].RadioCheckBoxOptions[c];
                                if (options.IsChecked == true)
                                {
                                    sb.AppendLine("<label id=\'lblEdit_" + i + "\'>" + options.Key + "</label></br><input type=\'checkbox\' id=\'ctrlEdit_" + i + "\' value=\'" + options.Value + "\' checked=\'checked\'></input></br>");
                                }
                                else
                                {
                                    sb.AppendLine("<label id=\'lblEdit_" + i + "\'>" + options.Key + "</label></br><input type=\'checkbox\' id=\'ctrlEdit_" + i + "\' value=\'" + options.Value + "\'></input></br>");
                                }
                            }
                        }
                        break;

                    case ColumnType.RadioButton:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label></br>");
                        if (gridConfiguration.ColumnNames[i].RadioCheckBoxOptions != null)
                        {
                            for (int r = 0; r < gridConfiguration.ColumnNames[i].RadioCheckBoxOptions.Count; r++)
                            {
                                var options = gridConfiguration.ColumnNames[i].RadioCheckBoxOptions[r];

                                if (options.IsChecked == true)
                                {
                                    sb.AppendLine("<label id=\'lblEdit_" + i + "\'>" + options.Key + "</label></br><input type=\'radio\' id=\'ctrlEdit_" + i + "\' value=\'" + options.Value + "\' checked=\'checked\'></input></br>");
                                }
                                else
                                {
                                    sb.AppendLine("<label id=\'lblEdit_" + i + "\'>" + options.Key + "</label></br><input type=\'radio\' id=\'ctrlEdit_" + i + "\' value=\'" + options.Value + "\'></input></br>");
                                }
                            }
                        }
                        break;

                    default:
                        break;
                }
            }
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            //sb.AppendLine("<button  id=\"" + this.ID + "EditModalBtn\" type =\"button\" class=\"btn btn-default\" onclick=\"" + this.ID + "LaunchModal(2);\" >" + _localizer.GetString(ButtonResourceKeyConstants.SaveButton) + "</button>");
            //sb.AppendLine("<button type =\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-primary\" onclick=\"" + this.ID + "GRIDAJAXEDIT()\">" + _localizer.GetString(ButtonResourceKeyConstants.SaveButton) + "</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + _localizer.GetString(ButtonResourceKeyConstants.CancelButton) + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</form>");
            sb.AppendLine("</div>");

            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR DELETE MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateDeleteModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "deleteModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-lg\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");
            sb.AppendLine("<button type =\"button\" class=\"close\" data-dismiss=\"modal\">&times;</button>");
            sb.AppendLine("<h4 class=\"modal-title\">Modal Header</h4>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");

            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                string visibility = gridConfiguration.ColumnNames[i].VisibleInModal == true ? "block" : "none";
                var _columnType = gridConfiguration.ColumnNames[i].ColumnType;
                switch (_columnType)
                {
                    case ColumnType.DropDown:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";min-width: 150px; width: 90%;\'> " + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label><select id=\'ctrlDelete_" + i + "\' style=\'display:" + visibility + ";min-width: 150px; width: 90%;\'></select>");
                        break;

                    case ColumnType.Default:
                        sb.AppendLine("<label id=\'lblEdit_" + i + "\'style=\'display:" + visibility + ";\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label><input id=\'ctrlDelete_" + i + "\' style=\'display:" + visibility + ";\'></input>");
                        break;

                    default:
                        break;
                }
            }
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-primary\" >Delete</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + _localizer.GetString(ButtonResourceKeyConstants.CancelButton) + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR CONFIRMATION MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateConfirmationModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "confirmModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-dialog-centered\" role = \"document\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h5 class=\"modal-title\" id=\"" + this.ID + "confirmModalTitle\"></h5>");
            sb.AppendLine("<button type =\"button\" class=\"close\" title='" + _localizer.GetString(TooltipResourceKeyConstants.Close) + "' data-dismiss=\"modal\"> <span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("<p>");
            sb.AppendLine("<div id=\"" + this.ID + "confirmationMessage\">");

            sb.AppendLine("</div>");
            sb.AppendLine("</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button id=\"" + this.ID + "ConfirmModalButton\" type =\"button\" class=\"btn btn-primary\">" + this.ControlLabels.SaveButtonLabel + "</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + _localizer.GetString(ButtonResourceKeyConstants.CancelButton) + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR DELETE EXCEPTION MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateDeleteExceptionModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "deleteExceptionModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-dialog-centered\" role = \"document\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h5 class=\"modal-title\" id=\"" + this.ID + "deleteExceptionModalTitle\"></h5>");
            sb.AppendLine("<button type =\"button\" class=\"close\" title='" + _localizer.GetString(TooltipResourceKeyConstants.Close) + "' data-dismiss=\"modal\"> <span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("<p>");
            sb.AppendLine("<div id=\"" + this.ID + "deleteExceptionModalDeleteMessage\">");

            sb.AppendLine("</div>");
            sb.AppendLine("</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button id=\"" + this.ID + "deleteExceptionModalButtonYes\" onclick=forceDelete(); type =\"button\" class=\"btn btn-primary\">" + this.ControlLabels.YesButtonLabel + "</button>");
            sb.AppendLine("<button id=\"" + this.ID + "deleteExceptionModalButtonNo\" type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + this.ControlLabels.NoButtonLabel + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR DELETE EXCEPTION MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateDeleteExceptionJsScode()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function forceDelete(){");
            sb.AppendLine("$('#" + this.ID + "deleteExceptionModal').modal('hide');");

            //retry the delete with a force after delete exception
            sb.AppendLine(this.ID + "GRIDAJAXDELETE(true)");

            //refresh the data table after delete
            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");

            sb.AppendLine("}");

            return sb.ToString();
        }

        /// <summary>
        /// GenerateChildRowJSCode
        /// </summary>
        /// <returns></returns>
        public string GenerateChildRowJSCode()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("$('#" + this.ID + "').on('click', 'tbody tr td', function () {");
            sb.AppendLine("var id = $(this).find('#hiddenId').val()");
            sb.AppendLine("if ($(this).find('.fa-caret-down, .fa-caret-up').length>0)");
            sb.AppendLine("var detail = false;");
            sb.AppendLine("if ($(this).find($('.fa-caret-down')).length > 0) {");
            sb.AppendLine("var sel = \"<i class='fas fa-caret-up fa-lg' style='cursor: pointer'></i>\";");
            sb.AppendLine("sel += \"<input id='hiddenId' type ='hidden'  value =  '\" + id + \"'>\";");
            sb.AppendLine("$(this).html(sel);");
            sb.AppendLine("detail = false;");
            sb.AppendLine("}");
            sb.AppendLine("else if ($(this).find($('.fa-caret-up')).length > 0) {");
            sb.AppendLine("var sel = \"<i class='fas  fa-caret-down fa-lg' style='cursor: pointer'></i>\";");
            sb.AppendLine("sel += \"<input id='hiddenId' type ='hidden'  value =  '\" + id + \"'>\";");
            sb.AppendLine("$(this).html(sel);");
            sb.AppendLine("detail = true;");
            sb.AppendLine("}");
            sb.AppendLine("if (id != undefined) {");

            sb.AppendLine("var dataTable;");
            sb.AppendLine(" dataTable = $('#" + this.ID + "').DataTable()");

            sb.AppendLine("var tr = $(this).closest('tr');");
            sb.AppendLine("var row = dataTable.row(tr);");
            sb.AppendLine("if (row.child.isShown()) {");
            sb.AppendLine("row.child.hide();");
            sb.AppendLine("tr.removeClass('shown');");
            sb.AppendLine("}");
            sb.AppendLine("else {");
            //sb.AppendLine("closeOpenedRows(dataTable, tr);");
            sb.AppendLine("row.child(getChildRow(row,id)).show();");
            sb.AppendLine("tr.addClass('shown');");
            //sb.AppendLine("openRows.push(tr);");
            sb.AppendLine("}");
            sb.AppendLine("}");

            sb.AppendLine("});");

            sb.AppendLine("$('#" + this.ID + "').on('hover', 'tbody tr td i', function () {");
            sb.AppendLine("$(this).css('cursor', 'pointer');");
            sb.AppendLine("});");
            return sb.ToString();
        }

        /// <summary>
        /// AppendChildRowJSCode
        /// </summary>
        /// <returns></returns>
        public string AppendChildRowJSCode()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function getChildRow(row,id) {");

            sb.AppendLine("var div = $('<div/>')");
            sb.AppendLine(".addClass( 'loading' )");
            sb.AppendLine(".text('Loading...'); ");

            sb.AppendLine("var jsonData = {");
            sb.AppendLine("'id': id");
            sb.AppendLine("};");
            sb.AppendLine("$.ajax({");
            sb.AppendLine(" url: '" + gridConfiguration.ChildRowAjaxUrl + "',");
            sb.AppendLine(" data: JSON.stringify(jsonData),");

            sb.AppendLine("contentType: 'application/json',");
            sb.AppendLine(" type: 'POST',");
            sb.AppendLine(" success: function (result) {");
            sb.AppendLine("div.html(result)");
            sb.AppendLine(".removeClass('loading');");

            sb.AppendLine("},");
            sb.AppendLine(" error: function (reponse) { alert('An error occurred: ' + reponse); }");
            sb.AppendLine("});");
            sb.AppendLine("return div;");
            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR DELETE CONFIRMATION MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateDELETEConfirmationModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "confirmDeleteModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-dialog-centered\" role = \"document\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h5 class=\"modal-title\" id=\"" + this.ID + "confirmDeleteModalTitle\"></h5>");
            sb.AppendLine("<button type =\"button\" class=\"close\" data-dismiss=\"modal\"> <span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("<p>");
            sb.AppendLine("<div id=\"" + this.ID + "confirmationDeleteMessage\">");

            sb.AppendLine("</div>");
            sb.AppendLine("</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button id=\"" + this.ID + "ConfirmDeleteModalButton\" type =\"button\" class=\"btn btn-primary\">" + this.ControlLabels.YesButtonLabel + "</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + this.ControlLabels.NoButtonLabel + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR REMOVE CHILD CONFIRMATION MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateREMOVEConfirmationModal()
        {
            StringBuilder sb = new();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + ID + "confirmRemoveModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-dialog-centered\" role = \"document\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h5 class=\"modal-title\" id=\"" + ID + "confirmRemoveModalTitle\"></h5>");
            sb.AppendLine("<button type =\"button\" class=\"close\" data-dismiss=\"modal\"> <span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("<p>");
            sb.AppendLine("<div id=\"" + ID + "confirmationRemoveMessage\">");

            sb.AppendLine("</div>");
            sb.AppendLine("</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button id=\"" + ID + "ConfirmRemoveModalButton\" type =\"button\" class=\"btn btn-primary\">" + ControlLabels.YesButtonLabel + "</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + ControlLabels.NoButtonLabel + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");

            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR DELETE MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateInlineEditCancelModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "inLineEditCancel\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-dialog-centered\" role = \"document\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");

            sb.AppendLine("<h5 class=\"modal-title\" id=\"" + this.ID + "inLineEditCancelTitle\"></h5>");
            sb.AppendLine("<button type =\"button\" class=\"close\" data-dismiss=\"modal\"> <span aria-hidden=\"true\">&times;</span></button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"modalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("<p>");
            sb.AppendLine("<div id=\"" + this.ID + "inLineEditCancelMessage\">");

            sb.AppendLine("</div>");
            sb.AppendLine("</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button id=\"" + this.ID + "inLineEditCancelModalYesButton\" type =\"button\" class=\"btn btn-primary\">" + this.ControlLabels.YesButtonLabel + "</button>");
            sb.AppendLine("<button id=\"" + this.ID + "inLineEditCancelModalNoButton\" type =\"button\" class=\"btn btn-outline-primary\">" + this.ControlLabels.NoButtonLabel + "</button>");

            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            // sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES HTML FOR ADD MODAL
        /// </summary>
        /// <returns></returns>
        public string GenerateAddModal()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine("<div class=\"modal fade\" id=\"" + this.ID + "addModal\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog modal-lg\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header\">");
            sb.AppendLine("<button type =\"button\" title='" + _localizer.GetString(TooltipResourceKeyConstants.Close) + "' class=\"close\" data-dismiss=\"modal\">&times;</button>");
            sb.AppendLine("<h4 class=\"modal-title\">Modal Header</h4>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"addmodalbodyContent\" class=\"modal-body\">");

            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                var _columnType = gridConfiguration.ColumnNames[i].ColumnType;
                switch (_columnType)
                {
                    case ColumnType.DropDown:
                        sb.AppendLine("<label id=\'lblAdd_" + i + "\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label></br><select style='min-width: 150px; width: 90%;' id=\'ctrlAdd_" + i + "\' name=\'ctrlAdd_" + i + "\'></select></br>");
                        break;

                    case ColumnType.Default:
                        sb.AppendLine("<label id=\'lblAdd_" + i + "\'>" + gridConfiguration.ColumnNames[i].ColumnTitleHeader + "</label></br><input id=\'ctrlAdd_" + i + "\' name=\'ctrlAdd_" + i + "\'></input></br>");
                        break;

                    default:
                        break;
                }
            }
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-primary\" onclick=\"" + this.ID + "GRIDAJAXPOST()\">" + _localizer.GetString(ButtonResourceKeyConstants.SaveButton) + "</button>");
            sb.AppendLine("<button type =\"button\" class=\"btn btn-outline-primary\" data-dismiss=\"modal\">" + _localizer.GetString(ButtonResourceKeyConstants.CloseButton) + "</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            //sb.AppendLine("</div>");
            return sb.ToString();
        }

        /// <summary>
        ///
        /// Adds Data to controls when edit is selected
        /// </summary>
        /// <returns></returns>
        private string SetEditModalContent()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function SetEditModalContent" + ID + "(e, d)");
            sb.AppendLine("{");
            sb.AppendLine("for (i = 0; i < d.length; i++)");
            sb.AppendLine("{");
            sb.AppendLine("if ($('#ctrlEdit_' + i.toString()).get(0) != undefined){");
            sb.AppendLine("if ($('#ctrlEdit_' + i.toString()) != undefined & $('#ctrlEdit_' + i.toString()).prop('type') == \"text\" ||");
            sb.AppendLine("$('#ctrlEdit_' + i.toString()) != undefined & $('#ctrlEdit_' + i.toString()).prop('type') == \"number\"){");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).val('' + (d[i] ?? \"\").toString() + '');");
            sb.AppendLine("}");
            sb.AppendLine("if ($('#ctrlEdit_' + i.toString()).prop('type') == \"select-one\" | $('#ctrlEdit_' + i.toString()).prop('type') == \"select-multiple\" ){");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).select2({");
            sb.AppendLine("ajax:");
            sb.AppendLine("{");
            sb.AppendLine("url: " + this.ID + "gridJSObject.ColumnNames[i].ColumnAjaxDataUrl,");
            sb.AppendLine("dataType: 'json'");
            sb.AppendLine("},");
            sb.AppendLine("width: 'resolve',");
            sb.AppendLine("tags: " + this.ID + "gridJSObject.ColumnNames[i].AllowTags.toString().toLowerCase(),");

            sb.AppendLine("closeOnSelect: true,");

            sb.AppendLine("multiple: " + this.ID + "gridJSObject.ColumnNames[i].AllowMultipleDropDownItemSelection,");

            sb.AppendLine("allowClear: true,");

            sb.AppendLine("placeholder: ' '");

            sb.AppendLine("});");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).empty();");
            sb.AppendLine("if (" + this.ID + "gridJSObject.ColumnNames[i].SplitCsvValues)");
            sb.AppendLine("{");
            sb.AppendLine("var csvValues = [];");
            sb.AppendLine("var csvText = d[i].split(',');");
            sb.AppendLine("var newOption;");

            sb.AppendLine("if (csvText.toString() != \"\")");
            sb.AppendLine("{");
            sb.AppendLine("if (" + this.ID + "gridJSObject.ColumnNames[i].AssociatedFieldId != \"\")");
            sb.AppendLine("{");
            sb.AppendLine("if (" + this.ID + "gridJSObject.ColumnNames[i].SplitCsvValues)");
            sb.AppendLine("{");
            sb.AppendLine("for (iSub = 0; iSub < d.length; iSub++)");
            sb.AppendLine("{");
            sb.AppendLine("if (" + this.ID + "gridJSObject.ColumnNames[iSub].ColumnName ==" + this.ID + "gridJSObject.ColumnNames[i].AssociatedFieldId)");
            sb.AppendLine("{");
            sb.AppendLine("csvValues = d[iSub].split(',');");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("for (iItem = 0; iItem < csvValues.length; iItem++)");
            sb.AppendLine("{");
            sb.AppendLine("newOption = new Option('' + csvText[iItem] + '', '' + csvValues[iItem] + '', true, true);");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).append(newOption);");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("else");
            sb.AppendLine("{");
            sb.AppendLine("for (iSub = 0; iSub < d.length; iSub++)");
            sb.AppendLine("{");
            sb.AppendLine("if (" + this.ID + "gridJSObject.ColumnNames[iSub].ColumnName ==" + this.ID + "gridJSObject.ColumnNames[i].AssociatedFieldId)");
            sb.AppendLine("{");
            sb.AppendLine("csvValues = d[iSub].toString();");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("newOption = new Option('' + csvText[iItem] + '', '' + csvValues + '', true, true);");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).append(newOption);");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("else");
            sb.AppendLine("{");
            sb.AppendLine("for (iSub = 0; iSub < csvText.length; iSub++)");
            sb.AppendLine("{");
            sb.AppendLine("newOption = new Option('' + csvText[iSub] + '', '' + csvValues[iSub] + '', true, true);");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).append(newOption);");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("else");
            sb.AppendLine("{");
            sb.AppendLine("newOption = new Option('' + d[i].toString() + '', '' + d[i].toString() + '', true, true);");

            sb.AppendLine("$('#ctrlEdit_' + i.toString()).append(newOption);");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("};");
            sb.AppendLine("};");
            sb.AppendLine("};");
            return sb.ToString();
            //List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>();
            //return sbFile(".\\TagHelpers\\CustomFiles\\SetEditModalContent.txt", kvpReplacements);
        }

        /// <summary>
        /// Adds data to controls when Delete is selected
        /// </summary>
        /// <returns></returns>
        private string SetDeleteModalConent()
        {
            StringBuilder sb = new();
            sb.AppendLine("function SetDeleteModalContent" + ID + "(d){");

            sb.AppendLine("for (i = 0 ; i < d.length;i++){");
            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()).get(0) != undefined){");

            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()) != undefined & $('#ctrlDelete_\'+ i.toString()).get(0).tagName == \"INPUT\"){");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).val(\''+ (d[i] ?? \"\").toString() + '\' );");
            sb.AppendLine("}");
            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()).get(0).tagName == \"SELECT\"){");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).select2({");

            sb.AppendLine("ajax:");
            sb.AppendLine("{");
            sb.AppendLine("url: " + this.ID + "gridJSObject.ColumnNames[i].ColumnAjaxDataUrl,");
            sb.AppendLine("dataType: 'json'");
            sb.AppendLine("},");

            sb.AppendLine("width: 'resolve',");
            sb.AppendLine("tags: " + this.ID + "gridJSObject.ColumnNames[i].AllowTags.toString().toLowerCase(),");
            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            sb.AppendLine("placeholder: ' '");

            sb.AppendLine("});");

            sb.AppendLine("var newOption = new Option(\''+ d[i].toString() +'\', \''+ d[i].toString() +'\', true, true);");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).append(newOption)");
            sb.AppendLine("}");

            sb.AppendLine("};");
            sb.AppendLine("};");

            sb.AppendLine("};");
            return sb.ToString();
        }

        /// <summary>
        /// Adds data to controls when Remove is selected.
        /// </summary>
        /// <returns></returns>
        private string SetRemoveModalConent()
        {
            StringBuilder sb = new();
            sb.AppendLine("function SetRemoveModalContent(d) {");

            sb.AppendLine("for (i = 0; i < d.length; i++){");
            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()).get(0) != undefined){");

            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()) != undefined & $('#ctrlDelete_\'+ i.toString()).get(0).tagName == \"INPUT\"){");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).val(\''+ (d[i] ?? \"\").toString() + '\' );");
            sb.AppendLine("}");
            sb.AppendLine("if($('#ctrlDelete_\'+ i.toString()).get(0).tagName == \"SELECT\"){");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).select2({");

            sb.AppendLine("ajax:");
            sb.AppendLine("{");
            sb.AppendLine("url: " + ID + "gridJSObject.ColumnNames[i].ColumnAjaxDataUrl,");
            sb.AppendLine("dataType: 'json'");
            sb.AppendLine("},");

            sb.AppendLine("width: 'resolve',");
            sb.AppendLine("tags: " + this.ID + "gridJSObject.ColumnNames[i].AllowTags.toString().toLowerCase(),");
            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            sb.AppendLine("placeholder: ' '");

            sb.AppendLine("});");

            sb.AppendLine("var newOption = new Option(\''+ d[i].toString() +'\', \''+ d[i].toString() +'\', true, true);");
            sb.AppendLine("$('#ctrlDelete_\'+ i.toString()).append(newOption)");
            sb.AppendLine("}");

            sb.AppendLine("};");
            sb.AppendLine("};");

            sb.AppendLine("};");

            return sb.ToString();
        }

        /// <summary>
        ///
        /// Adds Data to controls when inline Edit is selected
        /// </summary>
        /// <returns></returns>
        private string SetInlineEditContent()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function SetInlineEditRow(e,row){");

            sb.AppendLine("$(\"[data-target]\").prop(\"disabled\",true);"); //Disable "Add" Button

            sb.AppendLine("var table = $('#" + this.ID + "').DataTable();");
            ///Store in History so that method can be recalled on same row in case of cancelling and rediting the same row.
            //In case of correcting duplicate records
            sb.AppendLine("StoreInLineRowFunction('" + this.ID + "SetInlineEditRow',e,row,table.page());");

            sb.AppendLine("var selectedRow   =  e.closest(" + "\"tr\"" + ");");
            sb.AppendLine("$(selectedRow).addClass('form-group');");

            sb.AppendLine("RemoveInLineEditContent();");  // Reset the previously selected Edit Row to Readonly
            sb.AppendLine("var id = selectedRow._DT_RowIndex;");
            
            sb.AppendLine("var columnOffset = 0;");
            sb.AppendLine("var defaultDisabled = '';");

            sb.AppendLine("var index = $.inArray(id, " + this.ID + "selected);");
            sb.AppendLine("if (index === -1) {");
            sb.AppendLine(this.ID + "selected.push(id) }");

            sb.AppendLine("var tds = $(selectedRow).find(" + "\"td\"" + ");");
            sb.AppendLine(this.ID + "gridJSObject.ColumnNames.forEach((columnName, colIndex) => { ");
            sb.AppendLine(this.ID + "gridJSObject.ColumnNames[colIndex].data =  row[colIndex];");
            sb.AppendLine("})");

            sb.AppendLine("var filteredColumns = " + this.ID + "gridJSObject.ColumnNames.filter(function(e) {");
            sb.AppendLine("return e.VisibleInModal == true  || e.Visible ==true; }); ");
            sb.AppendLine("filteredColumns.forEach((columnName, colIndex) => { ");
            sb.AppendLine("var rowColumn = tds[colIndex-columnOffset];");

            sb.AppendLine("var bVisible = true;");
            //sb.AppendLine("var bSkip = false;");
            sb.AppendLine("defaultDisabled = '';");
            sb.AppendLine("autoDisabled = 'disabled';");


            //Base Reference Editor specific javascript
            //Architecture for the "Inline Edit" feature didn't accomodate for alterations of Base Reference fields used, so this is the only way to perform this action.
            //These 'Column Names' should only be picked up by, when in the Base Reference Editor. If they happen to get used by any other, these settings should not affect the module
            sb.AppendLine("if ($(\"#ReferenceTypeDD\").val() != undefined) {"); //If this object doesn't exist, the following code will not be used.

            sb.AppendLine(" if (columnName.ColumnName == 'StrHACodeNames') {");
            sb.AppendLine("     bVisible = $(\"#BaseReferenceGrid\").DataTable().column([6]).visible();");
            sb.AppendLine("     if(!bVisible) { columnOffset++ }");
            sb.AppendLine(" }");

            sb.AppendLine(" if (columnName.ColumnName == 'LOINC') {");
            sb.AppendLine("     bVisible = $(\"#BaseReferenceGrid\").DataTable().column([5]).visible();");
            sb.AppendLine("     if(!bVisible) { columnOffset++ }");
            sb.AppendLine(" }");

            sb.AppendLine(" if (columnName.ColumnName == 'IntOrder') {");
            sb.AppendLine("     if($(\"#hOrderByReadOnly\").val() != undefined) {");
            sb.AppendLine("         if($(\"#hOrderByReadOnly\").val().includes($(\"#ReferenceTypeDD\").val())) { ");
            sb.AppendLine("             columnName.ColumnType = BaseReferenceGridcolumnType.ReadOnly;");
            sb.AppendLine("         } else { ");
            sb.AppendLine("             columnName.ColumnType = BaseReferenceGridcolumnType.Numeric;");
            sb.AppendLine("             autoDisabled = ''; ");
            sb.AppendLine("         } ");
            sb.AppendLine("     } ");
            sb.AppendLine(" }");

            sb.AppendLine(" if (columnName.ColumnName == 'StrDefault') {");
            sb.AppendLine("     if($(\"#hOrderByReadOnly\").val() != undefined) {");
            sb.AppendLine("         if($(\"#hDefaultReadOnly\").val().includes($(\"#ReferenceTypeDD\").val())) { ");
            sb.AppendLine("             columnName.ColumnType = BaseReferenceGridcolumnType.DefaultLocked;");
            sb.AppendLine("         } else { ");
            sb.AppendLine("             columnName.ColumnType = BaseReferenceGridcolumnType.Default;");
            sb.AppendLine("             autoDisabled = ''; ");
            sb.AppendLine("         } ");
            sb.AppendLine("     } ");
            sb.AppendLine(" }");

            sb.AppendLine("}");
            //End of Base Reference Editor specific javascript

            sb.AppendLine("if (!bVisible) {");
            sb.AppendLine("}");
            sb.AppendLine("else {");
            sb.AppendLine("switch (columnName.ColumnType ) {");
            sb.AppendLine("case  " + this.ID + "columnType.Edit: {");

            if (gridConfiguration.EnableNavigationAwayNotification == true)
            {
                sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(\"<div class='form-inline'><button id='Save_\" + id +\"' type='button' class='btn btn-link d-inline-block' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridSave) + "' onclick='" + this.ID + "LaunchModal(3);'" + "><span class='fas fa-save'></span></button><button id='Cancel_\"+id +\"' type='button' class='btn btn-link d-inline-block' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridCancel) + "' onclick='CancelInlineEdit();TurnOffNavigationNotification();'><span class='fas fa-ban'></span></button></div>\")");
            }
            else
            {
                sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(\"<div class='form-inline'><button id='Save_\" + id +\"' type='button' class='btn btn-link d-inline-block' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridSave) + "' onclick='" + this.ID + "LaunchModal(3);'" + "><span class='fas fa-save'></span></button><button id='Cancel_\"+id +\"' type='button' class='btn btn-link d-inline-block' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridCancel) + "' onclick='CancelInlineEdit();'><span class='fas fa-ban'></span></button></div>\")");
            }

               
           
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.EditModal: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.Delete: {");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ")");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.Details: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.CheckBox: {");
            sb.AppendLine("var disabled = $(rowColumn).find(':input').prop('disabled') ? 'disabled' :'';");
            sb.AppendLine("var checkedFlag = $(rowColumn).find(':input').prop('checked') ? 'checked' :'';");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\"<input onChange='" + this.ID + "TableControlValueChanged();' type='checkbox' class=\'\"+columnName.ClassName+\" form-check' \"+ checkedFlag +\" id=\'\"+columnName.ColumnName + \"_\" +id +\"' >\")");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.DropDown: {");
            sb.AppendLine("var txt = columnName.data;");
            sb.AppendLine("var arrayTxt = txt.split(',');");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\" <select onChange='" + this.ID + "TableControlValueChanged();'   class=\'\"+columnName.ClassName+\" form-control eidssSelect2DropDown\"+ colIndex+\" form-control ' id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"' style='display: block; width: 90%; min-width: 150px;'     ></select>\")");
            sb.AppendLine("$(rowColumn).children('select').select2({");
            sb.AppendLine("ajax: {");
            sb.AppendLine("url: columnName.ColumnAjaxDataUrl,");
            sb.AppendLine("data: function (params) {");
            sb.AppendLine("var query = {");

            sb.AppendLine("term: params.term, page: params.page || 1");
            sb.AppendLine("}");
            sb.AppendLine("return query");
            sb.AppendLine("},");

            sb.AppendLine("dataType: 'json'");
            sb.AppendLine("},");
            sb.AppendLine("width: 'resolve',");

            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            sb.AppendLine("multiple: columnName.AllowMultipleDropDownItemSelection, ");
            sb.AppendLine("placeholder: ' '");
            sb.AppendLine("});");

            sb.AppendLine("if (columnName.SplitCsvValues){");
            sb.AppendLine("     var csvValues = [];");
            sb.AppendLine("     var csvText = columnName.data.split(',')");
            sb.AppendLine("     var newOption");
            sb.AppendLine("     if (csvText.toString() != ''){");
            sb.AppendLine("         if (columnName.AssociatedFieldId != ''){");
            sb.AppendLine("             if (columnName.SplitCsvValues){");
            sb.AppendLine("                 var strCodeColumn = " + this.ID + "gridJSObject.ColumnNames.find(function(e) {");
            sb.AppendLine("                     return e.ColumnName == columnName.AssociatedFieldId }); ");
            sb.AppendLine("                 if (strCodeColumn != undefined ){");
            sb.AppendLine("                     csvValues = strCodeColumn.data.split(',');");
            sb.AppendLine("                 }");
            sb.AppendLine("                 for(iItem=0;iItem<csvValues.length;iItem++){");
            sb.AppendLine("                     newOption = new Option(''+ csvText[iItem] + '', '' + csvValues[iItem] + '', true, true)");
            sb.AppendLine("                     $(rowColumn).find('select').append(newOption);");
            sb.AppendLine("                 }");
            sb.AppendLine("             }");
            sb.AppendLine("         }");
            sb.AppendLine("     }");
            sb.AppendLine("}");
            sb.AppendLine("else {");
            sb.AppendLine("     newOption = new Option(''+ columnName.data.toString() +'', ''+ columnName.data.toString() +'', true, true);");
            sb.AppendLine("     $(rowColumn).find('select').append(newOption);");
            sb.AppendLine("}");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.CustomModal: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.Numeric: {");
            sb.AppendLine("var txt = $(tds[colIndex-columnOffset]).text();");
            sb.AppendLine("var disableIfNumericFieldHasChar = false;");

            sb.AppendLine("if  (columnName.DisableIfNumericFieldHasChar)");
            sb.AppendLine("{");
            sb.AppendLine("let isNum = /^\\d+$/.test(txt);");
            sb.AppendLine("if (!isNum)");
            sb.AppendLine("{");
            sb.AppendLine(" disableIfNumericFieldHasChar = true;");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("if  (disableIfNumericFieldHasChar)");
            sb.AppendLine("{");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\"<input class=\'\"+columnName.ClassName+\" form-control' type='text'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"' value= '\"+ txt +\"'  \"+ maxlength +\"'  \"+ autoDisabled +\"></input>\")");
            sb.AppendLine("}");
            sb.AppendLine("else");
            sb.AppendLine("{");
            sb.AppendLine("var index = " + this.ID + "selected[0];");

            sb.AppendLine("var min = '';");
            sb.AppendLine("if (columnName.Min !=null && columnName.Min !=''){");
            sb.AppendLine("min =   'min=\'+columnName.Min+''");
            sb.AppendLine("}");
            sb.AppendLine("var max = '';");
            sb.AppendLine("if (columnName.Max !=null && columnName.Max !=''){");
            sb.AppendLine("max =   'max=\'+columnName.Max+''");
            sb.AppendLine("}");

            sb.AppendLine("if(" + this.ID + "gridJSObject.ColumnNames[rowColumn._DT_CellIndex.column].EnabledEditingControledByReferenceTypes == true){");
            sb.AppendLine("var refTypeIdValue = $('#'+" + this.ID + "gridJSObject.ControlIdThatRefreshGrid).select2('data')[0].id;");
            sb.AppendLine("if(" + this.ID + "gridJSObject.ColumnNames[rowColumn._DT_CellIndex.column].ReverenceTypesToControlEnabledEditing.indexOf(refTypeIdValue) > -1){");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\" <input onkeydown='return event.keyCode !== 69' onChange='" + this.ID + "TableControlValueChanged();' data-msg-range=\'\" + columnName.ValidationSetting.RangeValidationMessage +\"' type='number' class=\'\"+columnName.ClassName+\"  form-control' value= '\"+ txt +\"'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"'    \"+ min +\"  \"+ max +\" style='display: block;' onfocusout=\'\"+columnName.FocusOutMethod+\"' \"+ autoDisabled +\"></input>\")");
            sb.AppendLine("}");
            sb.AppendLine("else{");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\" <input onkeydown='return event.keyCode !== 69' onChange='" + this.ID + "TableControlValueChanged();' data-msg-range=\'\" + columnName.ValidationSetting.RangeValidationMessage +\"' type='number' class=\'\"+columnName.ClassName+\"  form-control' value= '\"+ txt +\"'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"'    \"+ min +\"  \"+ max +\" style='display: block;' onfocusout=\'\"+columnName.FocusOutMethod+\"'></input>\")");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("else{");
            sb.AppendLine("$(rowColumn).html(" + "\"\"" + ").append(" + "\" <input onkeydown='return event.keyCode !== 69' onChange='" + this.ID + "TableControlValueChanged();' data-msg-range=\'\" + columnName.ValidationSetting.RangeValidationMessage +\"' type='number' class=\'\"+columnName.ClassName+\"  form-control' value= '\"+ txt +\"'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"'    \"+ min +\"  \"+ max +\" style='display: block;' onfocusout=\'\"+columnName.FocusOutMethod+\"'></input>\")");
            sb.AppendLine("}");
            sb.AppendLine("}");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.Link: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.Button: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.RadioButton: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.ReadOnly: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case  " + this.ID + "columnType.DefaultLocked: ");
            sb.AppendLine(" defaultDisabled = 'readonly';");

            sb.AppendLine("case  " + this.ID + "columnType.Default: {");
            sb.AppendLine(" var txt = $(tds[colIndex-columnOffset]).text().trim();");
            sb.AppendLine(" if (txt === null || txt === '' )");
            sb.AppendLine(" {");
            sb.AppendLine(" }");
            sb.AppendLine(" else");
            sb.AppendLine(" {");
            sb.AppendLine("     txt = txt.replace(\"'\", \"&apos;\");");
            sb.AppendLine(" }");
            sb.AppendLine(" var maxlength = '';");
            sb.AppendLine(" if (columnName.MaxLength !=null && columnName.MaxLength !=''){");
            sb.AppendLine("     maxlength = 'maxlength=\'+columnName.MaxLength+''");
            sb.AppendLine(" }");
            sb.AppendLine(" if(" + this.ID + "gridJSObject.ColumnNames[rowColumn._DT_CellIndex.column].EnabledEditingControledByReferenceTypes == true){");
            sb.AppendLine("     var refTypeIdValue = $('#'+" + this.ID + "gridJSObject.ControlIdThatRefreshGrid).select2('data')[0].id;");
            sb.AppendLine("     if(" + this.ID + "gridJSObject.ColumnNames[rowColumn._DT_CellIndex.column].ReverenceTypesToControlEnabledEditing.indexOf(refTypeIdValue) > -1){");
            sb.AppendLine("         $(rowColumn).html(" + "\"\"" + ").append(" + "\"<input onChange='" + this.ID + "TableControlValueChanged();' class=\'\"+columnName.ClassName+\" form-control' type='text'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"' value= '\"+ txt +\"'  \"+ maxlength +\" \"+ autoDisabled +\">\")");
            sb.AppendLine("     }");
            sb.AppendLine("     else {");
            sb.AppendLine("         $(rowColumn).html(" + "\"\"" + ").append(" + "\"<input onChange='" + this.ID + "TableControlValueChanged();' class=\'\"+columnName.ClassName+\" form-control' type='text'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"' value= '\"+ txt +\"'  \"+ maxlength +\" \"+ defaultDisabled +\">\")");
            sb.AppendLine("     }");
            sb.AppendLine(" }");
            sb.AppendLine(" else {");
            sb.AppendLine("     $(rowColumn).html(" + "\"\"" + ").append(" + "\"<input onChange='" + this.ID + "TableControlValueChanged();' class=\'\"+columnName.ClassName+\" form-control' type='text'  id=\'\"+columnName.ColumnName + \"_\" +id +\"' name=\'\"+columnName.ColumnName+\"' value= '\"+ txt +\"'  \"+ maxlength +\" \"+ defaultDisabled +\">\")");
            sb.AppendLine(" }");
            sb.AppendLine(" break;");
            sb.AppendLine("}");

            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("})");

            sb.AppendLine("$('#" + this.ID + "').trigger('eidssGrid:editInLineInit', [ row, selectedRow ]);");

            sb.AppendLine("if (" + this.ID + "gridJSObject.EditPassThrough !=\"\")");
            sb.AppendLine("{");
            //sb.AppendLine(this.ID + "gridJSObject.EditPassThrough");
            sb.AppendLine("HideColumnsOnEdit();");
            sb.AppendLine(" }");

            sb.AppendLine("};");

            return sb.ToString();
        }

        private string CancelInlineEditBuilder()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function CancelInlineEdit(){");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancel').modal({ backdrop: 'static', keyboard: false })");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancel').modal('show');");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancelTitle').html('" + this.ControlLabels.CancelInlineEditTitle + "');");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancelMessage').html('" + this.ControlLabels.CanclInlineEditMessage + "');");
            ///End Method

            sb.AppendLine("$(\"#" + this.ID + "inLineEditCancelModalYesButton\").click(function() {");
            sb.AppendLine("$(\"[data-target]\").prop(\"disabled\",false);"); //Enable "Add" Button
            sb.AppendLine("RemoveInLineEditContent();");
            sb.AppendLine(gridConfiguration.CancelInlineEditCallBack);

            //Clear Local Storage
            sb.AppendLine("ClearTableDataFromLocalStorage('" + this.ID + "');");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancel').modal('hide');");
            sb.AppendLine("});");
            sb.AppendLine("$(\"#" + this.ID + "inLineEditCancelModalNoButton\").click(function() {");
            sb.AppendLine("$('#" + this.ID + "inLineEditCancel').modal('hide');");
            sb.AppendLine("});");
            sb.AppendLine("};");
            //Add Confirmation Button Events Here
            return sb.ToString();
        }

        //Cancel Edit and change row content to Read only Mode
        private string RemoveInlineEditContent()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function RemoveInLineEditContent(){");
            sb.AppendLine("var table = $('#" + this.ID + "').DataTable()");
            sb.AppendLine("if (" + this.ID + "selected.length !== 0 && " + this.ID + "selected !== undefined) {");
            sb.AppendLine("var prevSelectedRowId= " + this.ID + "selected.splice(0, 1)");
            sb.AppendLine("var prewSelectedRow=$('#" + this.ID + " tbody tr:eq(' + prevSelectedRowId[0] + ')');");
            //sb.AppendLine("console.log(prewSelectedRow);");
            sb.AppendLine("var selectedtds = $(prewSelectedRow).find(" + "\"td\"" + ");");
            sb.AppendLine("var PrevFilteredColumns = " + this.ID + "gridJSObject.ColumnNames.filter(function(e) {");
            sb.AppendLine("return e.VisibleInModal == true  || e.Visible ==true; }); ");
            sb.AppendLine("PrevFilteredColumns.forEach((selectedColumnName, index) => { ");
            sb.AppendLine("var selectedRowColumn = selectedtds[index]");

            sb.AppendLine("switch (selectedColumnName.ColumnType ) {");
            sb.AppendLine("case " + this.ID + "columnType.Edit: {");
            sb.AppendLine("var txt = $(selectedRowColumn).text();");
            //sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<a id='Edit_\"+prevSelectedRowId +\"' class='editGridRecord' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(table.row(prevSelectedRowId).data()) + \");return false;'><span class='fas fa-edit icon'></span></a>\")");
            sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<button id='Edit_\"+prevSelectedRowId +\"' class='btn btn-link editGridRecord' type='button' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridEdit) + "' onclick='SetInlineEditRow( this,\"+ JSON.stringify(table.row(prevSelectedRowId).data()) + \");'><span class='fas fa-edit icon'></span></button>\")");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.EditModal: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Delete: {");
            //sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<a id='Delete_\" + prevSelectedRowId +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); SetDeleteModalContent" + ID + "(\"+  JSON.stringify(table.row(prevSelectedRowId).data()) + \");return false;'><span class='fa fa-trash fa-1x icon'></span></a>\")");
            sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<button id='Delete_\" + prevSelectedRowId +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); SetDeleteModalContent" + ID + "(\"+  JSON.stringify(table.row(prevSelectedRowId).data()) + \");'><span class='fa fa-trash fa-1x icon'></span></button>\")");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.DeleteUsingCustomMethod: {");
            //sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<a id='Delete_\" + prevSelectedRowId +\"' href='#' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); SetDeleteModalContent" + ID + "(\"+  JSON.stringify(table.row(prevSelectedRowId).data()) + \");return false;'><span class='fa fa-trash fa-1x icon'></span></a>\")");
            sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<button id='Delete_\" + prevSelectedRowId +\"' type='button' class='btn btn-link' title='" + _localizer.GetString(TooltipResourceKeyConstants.GridDelete) + "' onclick='" + this.ID + "LaunchModal(0); SetDeleteModalContent" + ID + "(\"+  JSON.stringify(table.row(prevSelectedRowId).data()) + \");'><span class='fa fa-trash fa-1x icon'></span></button>\")");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Details: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.DropDown: {");
            sb.AppendLine("var txt = selectedColumnName.data;");
            sb.AppendLine("$(selectedRowColumn).html(" + "\" \"+ txt +\"  \");");

            //sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\" <select class='form-control eidssSelect2DropDown\"+ index+\"'  id=\'\"+selectedColumnName.ColumnName+\"'  style='display: block;'  value= '\"+ txt +\"' +  ><option>\" + txt +\"</option></select>\")");
            //sb.AppendLine("$(selectedRowColumn).find('select').select2({");
            //sb.AppendLine("ajax: {");
            //sb.AppendLine("url: selectedColumnName.ColumnAjaxDataUrl,");
            //sb.AppendLine("data: function (params) {");
            //sb.AppendLine("var query = {");
            //sb.AppendLine(" term: params.term, page: params.page || 1");
            //sb.AppendLine("}");
            //sb.AppendLine("return query");
            //sb.AppendLine("}");
            //sb.AppendLine("},");
            //sb.AppendLine("width: '400',");
            //sb.AppendLine("tags: true,");
            //sb.AppendLine("closeOnSelect: true,");
            //sb.AppendLine("allowClear: true,");
            //sb.AppendLine("multiple: selectedColumnName.AllowMultipleDropDownItemSelection, ");
            //sb.AppendLine("placeholder: ' '");
            //sb.AppendLine("});");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.CustomModal: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Numeric: {");
            sb.AppendLine("var txt = selectedColumnName.data;");
            sb.AppendLine("$(selectedRowColumn).html(txt);");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Link: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Button: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.RadioButton: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.CheckBox: {");
            sb.AppendLine("var checked = (selectedColumnName.data.toUpperCase()) == 'TRUE' ? 'checked' :'';");
            sb.AppendLine("$(selectedRowColumn).html(" + "\"\"" + ").append(" + "\"<input type='checkbox'  disabled='disabled'   id=\'\"+selectedColumnName.ColumnName+\"'  \"+ checked +\"  >\")");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.ReadOnly: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.DefaultLocked: ");
            sb.AppendLine("case " + this.ID + "columnType.Default: {");
            sb.AppendLine("var txt = selectedColumnName.data;");
            sb.AppendLine("$(selectedRowColumn).html(txt);");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("}");
            sb.AppendLine("})");
            sb.AppendLine("};");
            sb.AppendLine("};");
            return sb.ToString();
        }

        private string SetAddModalConent()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function SetAddModalConent(d){");

            sb.AppendLine("for (i = 0 ; i < d.length;i++){");
            sb.AppendLine("if($('#ctrlAdd_\'+ i.toString()).get(0) != undefined){");

            sb.AppendLine("if($('#ctrlAdd_\'+ i.toString()) != undefined & $('#ctrlAdd_\'+ i.toString()).get(0).tagName == \"INPUT\"){");
            sb.AppendLine("$('#ctrlAdd_\'+ i.toString()).val(\''+ d[i].toString() + '\' );");
            sb.AppendLine("}");
            sb.AppendLine("if($('#ctrlAdd_\'+ i.toString()).get(0).tagName == \"SELECT\"){");
            sb.AppendLine("$('#ctrlAdd_\'+ i.toString()).select2({");

            sb.AppendLine("ajax:");
            sb.AppendLine("{");
            sb.AppendLine("url: " + this.ID + "gridJSObject.ColumnNames[i].ColumnAjaxDataUrl,");
            sb.AppendLine("dataType: 'json'");
            //sb.AppendLine("// Additional AJAX parameters go here; see the end of this chapter for the full code of this example
            sb.AppendLine("},");

            sb.AppendLine("width: 'resolve',");
            sb.AppendLine("tags: " + this.ID + "gridJSObject.ColumnNames[i].AllowTags.toString().toLowerCase(),");
            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            sb.AppendLine("placeholder: ' '");

            sb.AppendLine("});");

            //sb.AppendLine("var newOption = new Option(\''+ d[i].toString() +'\', \''+ d[i].toString() +'\', true, true);");
            //sb.AppendLine("$('#ctrl_\'+ i.toString()).append(newOption)");
            //sb.AppendLine("}");

            sb.AppendLine("};");
            sb.AppendLine("};");

            sb.AppendLine("};");
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// CREATES AJAX POST METHOD FOR MODAL
        /// SENDING DATA TO SERVER
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXPostMethod()
        {
            StringBuilder sb = new StringBuilder();

            //START JS FUNCTION
            sb.AppendLine("function " + this.ID + "GRIDAJAXPOST(){");

            sb.AppendLine("var postObj ={};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("if($('#ctrl_" + i.ToString() + "').get(0) != undefined ){");
                sb.AppendLine("if($('#ctrl_" + i.ToString() + "').get(0).tagName == \"INPUT\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrl_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrl_" + i.ToString() + "').get(0).tagName == \"SELECT\"){");
                sb.AppendLine("var " + this.ID + "select2Data= $('#ctrl_" + i.ToString() + "').select2('data');");
                sb.AppendLine("if (" + this.ID + "select2Data.length > 0)");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + this.ID + "select2Data;");
                sb.AppendLine("};");
                sb.AppendLine("};");
            }
            if (enableDebug == true)
            {
                sb.AppendLine("console.log(\"Saving: \" + postObj);");
            }

            //SEND DATA TO ENPOINT
            sb.AppendLine("$.ajax({url: " + this.ID + "gridJSObject.EditModalAjaxUrl , type: 'POST' , dataType: 'JSON', data:  JSON.stringify(postObj) ,    contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function() { ");
            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");
            sb.AppendLine("});");

            //END JS FUNCTION
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// Creates Method Called to Send Data to defined EDIT AJAX Endpoint when Edit button is clicked
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXEDITMethod()
        {
            StringBuilder sb = new StringBuilder();

            //START JS FUNCTION
            sb.AppendLine("function " + this.ID + "GRIDAJAXEDIT(){");

            sb.AppendLine("var postObj ={};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("if($('#ctrlEdit_" + i.ToString() + "').get(0) != undefined ){");
                sb.AppendLine("if($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"text\" || $('#ctrlEdit_" + i.ToString() + "').prop('type') == \"number\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlEdit_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"checkbox\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlEdit_" + i.ToString() + "').is(':checked');");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"radiobutton\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlEdit_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"number\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlEdit_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if ($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"select-one\"){");
                sb.AppendLine("var " + this.ID + "select2Data= $('#ctrlEdit_" + i.ToString() + "').select2('data');");
                sb.AppendLine("if (" + this.ID + "select2Data.length > 0){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + this.ID + "select2Data;}");
                sb.AppendLine("}");
                sb.AppendLine("else if ($('#ctrlEdit_" + i.ToString() + "').prop('type') == \"select-multiple\"){");
                sb.AppendLine("var " + this.ID + "select2Data= $('#ctrlEdit_" + i.ToString() + "').select2('data');");
                sb.AppendLine("if (" + this.ID + "select2Data.length > 0){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + this.ID + "select2Data;}");
                sb.AppendLine("};");
                sb.AppendLine("};");
            }

            sb.AppendLine("console.log(postObj);");

            //SEND DATA TO ENPOINT
            //SEND DATA TO ENPOINT
            sb.AppendLine("$.ajax({url: " + this.ID + "gridJSObject.EditModalAjaxUrl , type: 'POST' , dataType: 'JSON', data:  JSON.stringify(postObj) ,    contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function(data) { ");
            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");
            sb.AppendLine("$('#" + this.ID + "editModal').modal('hide');");
            if (!String.IsNullOrEmpty(gridConfiguration.SaveCompleteMethod))//Javascript method defined in VIEW
            {
                sb.AppendLine(gridConfiguration.SaveCompleteMethod + "(data);");
            }
            else
            {
                sb.AppendLine("$('#" + this.ID + "SuccessModal').modal({ backdrop: 'static', keyboard: false })");
                sb.AppendLine("$('#" + this.ID + "SuccessModal').modal('show');");
            }

            sb.AppendLine("})");
            //END JS FUNCTION
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// Creates Method Called to Send Data to defined EDIT AJAX Endpoint when Edit button is clicked
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXINLINEEDITMethod()
        {
            StringBuilder sb = new StringBuilder();

            //START JS FUNCTION
            sb.AppendLine("function " + this.ID + "GRIDAJAXINLINEEDIT(){");

            sb.AppendLine("var postObj ={};");
            sb.AppendLine("var table = $('#" + this.ID + "').DataTable()");
            sb.AppendLine("if (" + this.ID + "selected.length !== 0 && " + this.ID + "selected !== undefined) {");
            sb.AppendLine("var prevSelectedRowId= " + this.ID + "selected.splice(0, 1)");
            sb.AppendLine("var prevSelectedRow=$('#" + this.ID + " tbody tr:eq(' + prevSelectedRowId[0] + ')');");
            sb.AppendLine("var selectedtds = $(prevSelectedRow).find(" + "\"td\"" + ");");
            sb.AppendLine("var PrevFilteredColumns = " + this.ID + "gridJSObject.ColumnNames.filter(function(e) {");
            sb.AppendLine("return  e.VisibleInModal== false && e.Visible ==false; }); ");
            sb.AppendLine("PrevFilteredColumns.forEach((selectedColumn, index) => { ");
            sb.AppendLine("postObj[selectedColumn.ColumnName] = selectedColumn.data;");
            sb.AppendLine("})");

            sb.AppendLine(this.ID + "gridJSObject.ColumnNames.forEach((selectedColumn, index) => { ");
            sb.AppendLine("var selectedTdColumn = $(selectedtds).find('#' + selectedColumn.ColumnName +'_' + prevSelectedRowId); ");
            sb.AppendLine("switch (selectedColumn.ColumnType ) {");
            sb.AppendLine("case " + this.ID + "columnType.DropDown: {");
            sb.AppendLine("var txt = selectedColumn.data;");
            sb.AppendLine("if ($(selectedTdColumn).prop('type') == \"select-one\"){");
            sb.AppendLine("var " + this.ID + "select2Data= $(selectedTdColumn).select2('data');");
            sb.AppendLine("if (" + this.ID + "select2Data.length > 0){");
            sb.AppendLine("postObj[selectedColumn.ColumnName] = " + this.ID + "select2Data;");
            sb.AppendLine("}");
            sb.AppendLine("}");
            sb.AppendLine("else if ($(selectedTdColumn).prop('type') == \"select-multiple\"){");
            sb.AppendLine("var " + this.ID + "select2Data=  $(selectedTdColumn).select2('data');");
            sb.AppendLine("if (" + this.ID + "select2Data.length > 0){");
            sb.AppendLine("postObj[selectedColumn.ColumnName] = " + this.ID + "select2Data;");
            sb.AppendLine("};");
            sb.AppendLine("};");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.Numeric: {");
            sb.AppendLine("var txt = $(selectedTdColumn).val();");
            sb.AppendLine("postObj[selectedColumn.ColumnName] = txt;");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.RadioButton: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.CheckBox: {");
            sb.AppendLine("var checkedFlag = $(selectedTdColumn).prop('checked') ? 'True' :'False';");
            sb.AppendLine("postObj[selectedColumn.ColumnName] = checkedFlag;");

            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.ReadOnly: {");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("case " + this.ID + "columnType.DefaultLocked: ");
            sb.AppendLine("case " + this.ID + "columnType.Default: {");
            sb.AppendLine("var txt = $(selectedTdColumn).val();");
            sb.AppendLine("if (selectedColumn.Visible == false) {");
            sb.AppendLine("var txt = selectedColumn.data;");
            sb.AppendLine("}");

            sb.AppendLine("postObj[selectedColumn.ColumnName] = txt;");
            sb.AppendLine("break;");
            sb.AppendLine("}");

            sb.AppendLine("}");
            sb.AppendLine("})");
            sb.AppendLine("};");

            //CUSTOM METHOS
            if (!String.IsNullOrEmpty(gridConfiguration.EditCustomMethod))
            {
                sb.AppendLine(gridConfiguration.EditCustomMethod + "(postObj);");
            }

            //SEND DATA TO ENPOINT
            sb.AppendLine("$.ajax({url: " + this.ID + "gridJSObject.EditModalAjaxUrl , type: 'POST' , dataType: 'JSON', data:  JSON.stringify(postObj) ,    contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function(data) { ");
            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");
            sb.AppendLine("var stringified_data = JSON.stringify(data);");
            sb.AppendLine("var parsed_data = JSON.parse(stringified_data);");
            sb.AppendLine("if (parsed_data.returnMessage == \"SUCCESS\")");
            sb.AppendLine("{");
            sb.AppendLine("ClearTableDataFromLocalStorage('" + this.ID + "SetInlineEditRow');");//Clear LocalStorage;
            sb.AppendLine("}");
            if (!String.IsNullOrEmpty(gridConfiguration.SaveCompleteMethod))//Javascript method defined in VIEW
            {
                sb.AppendLine(gridConfiguration.SaveCompleteMethod + "(data);");
            }
            else
            {
                sb.AppendLine("$('#" + this.ID + "SuccessModal').modal({ backdrop: 'static', keyboard: false })");
                sb.AppendLine("$('#" + this.ID + "SuccessModal').modal('show');");
            }

            sb.AppendLine("})");

            //END JS FUNCTION
            sb.AppendLine("}");

            return sb.ToString();
        }

        /// <summary>
        /// Creates Method Called to Send Data to defined Delete AJAX Endpoint when delete button is clicked
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXDELETEMethod()
        {
            StringBuilder sb = new StringBuilder();

            //START JS FUNCTION
            sb.AppendLine("function " + this.ID + "GRIDAJAXDELETE(forceDelete){");

            sb.AppendLine("var postObj ={};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("if($('#ctrlDelete_" + i.ToString() + "').get(0) != undefined ){");
                sb.AppendLine("if($('#ctrlDelete_" + i.ToString() + "').get(0).tagName == \"INPUT\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlDelete_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrlDelete_" + i.ToString() + "').get(0).tagName == \"SELECT\"){");
                sb.AppendLine("var " + this.ID + "select2Data" + i.ToString() + ";");
                sb.AppendLine("if($('#ctrlDelete_" + i.ToString() + "').attr('class') == 'select2-hidden-accessible'){");
                sb.AppendLine(this.ID + "select2Data" + i.ToString() + "= $('#ctrlDelete_" + i.ToString() + "').select2('data');");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + this.ID + "select2Data" + i.ToString() + "[0].id;");
                sb.AppendLine("}");
                sb.AppendLine("};");
                sb.AppendLine("};");
            }

            //add the ForceDelete parameter for delete retries

            sb.AppendLine("postObj[\"ForceDelete\"] = typeof forceDelete === 'undefined' ? false : forceDelete;");

            sb.AppendLine("console.log(postObj);");

            sb.AppendLine("$.ajax({url: " + this.ID + "gridJSObject.DeleteModalAjaxUrl , type: 'POST' , dataType: 'JSON', data:  JSON.stringify(postObj) ,    contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function(response) { ");

            if (!String.IsNullOrEmpty(gridConfiguration.DeleteCompleteMethod))//Javascript method defined in VIEW
            {
                sb.AppendLine(gridConfiguration.DeleteCompleteMethod + "(response);");
            }

            sb.AppendLine("if(response.returnMessage == 'IN USE') {");
            sb.AppendLine(this.ID + "LaunchModal(4);");
            sb.AppendLine("}");
            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");
            sb.AppendLine("});");

            //END JS FUNCTION
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// Creates Method Called to Send Data to defined Remove AJAX Endpoint when delete button is clicked
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXREMOVEMethod()
        {
            StringBuilder sb = new();

            //START JS FUNCTION
            sb.AppendLine("function " + ID + "GRIDAJAXREMOVE() {");

            sb.AppendLine("var postObj = {};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("if($('#ctrlDelete_" + i.ToString() + "').get(0) != undefined) {");
                sb.AppendLine("if($('#ctrlDelete_" + i.ToString() + "').get(0).tagName == \"INPUT\") {");
                sb.AppendLine("postObj[" + ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrlDelete_" + i.ToString() + "').val();");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrlDelete_" + i.ToString() + "').get(0).tagName == \"SELECT\") {");
                sb.AppendLine("var " + ID + "select2Data= $('#ctrlDelete_" + i.ToString() + "').select2('data');");
                sb.AppendLine("postObj[" + ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + ID + "select2Data[0].id;");
                sb.AppendLine("};");
                sb.AppendLine("};");
            }

            sb.AppendLine("console.log(postObj);");

            sb.AppendLine("$.ajax({url: " + ID + "gridJSObject.DeleteModalAjaxUrl, type: 'POST', dataType: 'JSON', data: JSON.stringify(postObj), contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function(response) { ");

            if (!String.IsNullOrEmpty(gridConfiguration.DeleteCompleteMethod)) //Javascript method defined in VIEW
            {
                sb.AppendLine(gridConfiguration.DeleteCompleteMethod + "(response);");
            }

            //sb.AppendLine("if(response.returnMessage == 'IN USE') {");
            //sb.AppendLine(ID + "LaunchModal(4);");
            //sb.AppendLine("}");
            sb.AppendLine("});");

            //END JS FUNCTION
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// CREATES AJAX GET METHOD
        /// </summary>
        /// <returns></returns>
        public string CreateAJAXGetMethod()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function GRIDAJAXGET(){");
            sb.AppendLine("var postObj ={};");
            for (int i = 0; i < gridConfiguration.ColumnNames.Count; i++)
            {
                sb.AppendLine("if($('#ctrl_" + i.ToString() + "').get(0) != undefined ){");
                sb.AppendLine("if($('#ctrl_" + i.ToString() + "').get(0).tagName == \"INPUT\"){");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] = $('#ctrl_" + i.ToString() + "').val()");
                sb.AppendLine("}");
                sb.AppendLine("else if($('#ctrl_" + i.ToString() + "').get(0).tagName == \"SELECT\"){");
                sb.AppendLine("var " + this.ID + "select2Data= $('#ctrl_" + i.ToString() + "').select2('data');");
                sb.AppendLine("postObj[" + this.ID + "gridJSObject.ColumnNames[" + i + "].ColumnName] =  " + this.ID + "select2Data[0].id");
                sb.AppendLine("};");
                sb.AppendLine("};");
            }

            // sb.AppendLine("console.log(postObj);");

            //SEND DATA TO ENPOINT
            sb.AppendLine("$.post(" + this.ID + "gridJSObject.EditModalAjaxUrl, postObj, function(data){");

            sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
            sb.AppendLine("dt.ajax.reload();");
            sb.AppendLine("});");
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// Events fired when FIltering Control Changes
        /// </summary>
        /// <returns></returns>
        public string CreateFilterChangeFunction()
        {
            StringBuilder sb = new StringBuilder();
            //On Change Event of Filtering Control We Use It's Data
            if (!String.IsNullOrEmpty(this.FilteredControlIds))
            {
                string[] filteredControlIds = this.FilteredControlIds.Split(',');
                for (int i = 0; i < filteredControlIds.Length; i++)
                {
                    if (!String.IsNullOrEmpty(filteredControlIds[i]))
                    {
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0) != undefined ){");
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"INPUT\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("else if($('#" + filteredControlIds[i] + "').get(0).tagName == \"SELECT\"){");
                        sb.AppendLine("$('#" + filteredControlIds[i] + "').on('select2:select', function(e) {");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = e.params.data.id;");
                        //sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                        //sb.AppendLine("dt.ajax.reload();");
                        sb.AppendLine("});");
                        sb.AppendLine("};");
                        sb.AppendLine("};");
                    }
                }
            }
            if (!String.IsNullOrEmpty(this.ControlsThatRefreshTheGrid))
            {
                string[] filteredControlIds = this.ControlsThatRefreshTheGrid.Split(',');
                for (int i = 0; i < filteredControlIds.Length; i++)
                {
                    if (!String.IsNullOrEmpty(filteredControlIds[i]))
                    {
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0) != undefined ){");

                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"INPUT\"){");
                        // Event Should Go Here
                        sb.AppendLine("}");

                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"SELECT\"){");
                        sb.AppendLine("$('#" + filteredControlIds[i] + "').on('select2:select', function(e) {");
                        // Event Should Go Here
                        sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                        sb.AppendLine("dt.ajax.reload();");
                        sb.AppendLine("});");
                        sb.AppendLine("};");

                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"BUTTON\"){");
                        // Event Should Go Here
                        sb.AppendLine("$('#" + filteredControlIds[i] + "').click(function() {");
                        sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                        sb.AppendLine("dt.ajax.reload();");
                        sb.AppendLine("});");

                        sb.AppendLine("}");

                        sb.AppendLine("};");
                    }
                }
            }
            return sb.ToString();
        }

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        public string SetDefaultFilteringData()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("var " + this.ID + "filterControlsData = {};");
            if (!String.IsNullOrEmpty(FilteredControlIds))
            {
                //Iterate through controls
                string[] filteredControlIds = this.FilteredControlIds.Split(',');
                for (int i = 0; i < filteredControlIds.Length; i++)
                {
                    if (!String.IsNullOrEmpty(filteredControlIds[i]))
                    {
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0) != undefined ){");
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"INPUT\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("else if($('#" + filteredControlIds[i] + "').get(0).tagName == \"SELECT\"){");
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').hasClass('select2-hidden-accessible')) {");
                        sb.AppendLine("var " + this.ID + "select2Data = $('#" + filteredControlIds[i] + "').select2('data');");
                        sb.AppendLine("if (" + this.ID + "select2Data.length >0)");
                        sb.AppendLine("{");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] =  " + this.ID + "select2Data[0].id;");
                        sb.AppendLine("}");
                        sb.AppendLine("}");
                        sb.AppendLine("else {");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("};");
                        sb.AppendLine("};");
                    }
                }
            }
            if (this.EnableTopHeaderSearchButton == true)
            {
                sb.AppendLine(this.ID + "filterControlsData['SearchBox'] = $('#SearchBox').val();");
            }

            return sb.ToString();
        }

        /// <summary>
        /// Creates Object for filtering Grid
        ///The Data is sent to the server
        /// </summary>
        /// <returns></returns>
        public string GenerateGridFilteredPostData()
        {
            StringBuilder sb = new StringBuilder();

            //START JS FUNCTION
            sb.AppendLine("function " + this.ID + "GetDataToFilterGrid(){");

            if (!String.IsNullOrEmpty(this.FilteredControlIds))
            {
                sb.AppendLine(this.ID + "filterControlsData = {};");
                string[] filteredControlIds = this.FilteredControlIds.Split(',');
                sb.AppendLine("var controlType =\"\"");
                for (int i = 0; i < filteredControlIds.Length; i++)
                {
                    if (!String.IsNullOrEmpty(filteredControlIds[i]))
                    {
                        sb.AppendLine("controlType = $('#" + filteredControlIds[i] + "').prop('type')");
                        sb.AppendLine("if( controlType != undefined ){");
                        //Start IF
                        // sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0) != undefined ){");
                        sb.AppendLine("if( controlType == \"text\" || controlType == \"number\" || controlType == \"hidden\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("else if(controlType == \"select-one\" || controlType == \"select-multiple\"){");
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').hasClass('select2-hidden-accessible')) {");
                        sb.AppendLine("var " + this.ID + "select2Data= $('#" + filteredControlIds[i] + "').select2('data');");
                        sb.AppendLine("if (" + this.ID + "select2Data.length >0)");
                        sb.AppendLine("{");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] =  " + this.ID + "select2Data[0].id;");
                        sb.AppendLine("}");
                        sb.AppendLine("}");
                        sb.AppendLine("else {");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("}");
                        sb.AppendLine("else if(controlType == \"checkbox\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').is(':checked');");
                        sb.AppendLine("}");
                        sb.AppendLine("else if(controlType == \"date\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('#" + filteredControlIds[i] + "').val();");
                        sb.AppendLine("}");
                        sb.AppendLine("else if( controlType == \"radio\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] = $('input[name=\"" + filteredControlIds[i] + "\"]:checked').val();");
                        sb.AppendLine("};");
                        sb.AppendLine("if($('#" + filteredControlIds[i] + "').get(0).tagName == \"RADIO\"){");
                        sb.AppendLine(this.ID + "filterControlsData['" + filteredControlIds[i] + "'] =  $('input[name=\"" + this.ID + "\"]:checked').val();");
                        sb.AppendLine("};");

                        //END IF
                        sb.AppendLine("};");
                    }
                }
            }

            if (this.EnableTopHeaderSearchButton == true)
            {
                sb.AppendLine(this.ID + "filterControlsData['SearchBox'] = $('#SearchBox').val();");
            }
            if (this.enableDebug == true)
            {
                sb.AppendLine("console.log('Data for Grid Filtering sent to server:');");
                sb.AppendLine("console.log(" + this.ID + "filterControlsData);");
            }

            //sb.AppendLine("alert(JSON.stringify(filterControlsData));");

            //SEND DATA TO ENPOINT
            sb.AppendLine("return JSON.stringify(" + this.ID + "filterControlsData);");

            //END JS FUNCTION
            sb.AppendLine("}");
            return sb.ToString();
        }

        /// <summary>
        /// GENERATES BUTTON EVENT FOR  SEARCH AND GETS DATA FROM SEARCH BOX
        /// </summary>
        /// <returns></returns>
        public string BuildJSSearch()
        {
            StringBuilder sb = new StringBuilder();
            if (this.EnableTopHeaderSearchButton == true)
            {
                sb.AppendLine("$(\"#SearchBoxBtn\").click(function() {");
                sb.AppendLine(this.ID + "filterControlsData['SearchBox'] = $('#SearchBox').val();");
                sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                sb.AppendLine("dt.ajax.reload();");
                sb.AppendLine("});");
                //END Javascript Method
            }
            if (!String.IsNullOrEmpty(this.CustomSearchBtnID))
            {
                sb.AppendLine("$(\"#" + this.CustomSearchBtnID + "\").click(function() {");
                sb.AppendLine(this.ID + "GetDataToFilterGrid();");
                sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                sb.AppendLine("dt.ajax.reload();");
                sb.AppendLine("});");
            }
            return sb.ToString();
        }

        public string BuildPrintList()
        {
            StringBuilder sb = new StringBuilder();

            if (gridConfiguration.IsSSRSReportEnabled)
            {

            }
            else
            {
                sb.AppendLine("$(\"#btnPrint\").on('click', function() {");
                sb.AppendLine(this.ID + "filterControlsData['Print'] = true;");
                sb.AppendLine("var dt = $('#" + this.ID + "').DataTable();");
                sb.AppendLine("dt.ajax.reload(function(){ ");
                sb.AppendLine("$('.buttons-print').trigger('click');");
                //sb.AppendLine("window.location.reload(true);");
                sb.AppendLine("});");
                sb.AppendLine("});");
            }

         
            //END Javascript Method

            return sb.ToString();
        }

        public string HandleModalClose()
        {
            StringBuilder sb = new StringBuilder();

            return sb.ToString();
        }

        private string ModalBuilderEntry()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("var action = -1;");

            sb.AppendLine("function " + this.ID + "LaunchModal(modalInt){");
            sb.AppendLine("$(\"[data-target]\").prop(\"disabled\",false);"); //Enable "Add" Button
            sb.AppendLine("action = modalInt;");
            sb.AppendLine("switch (modalInt)");
            sb.AppendLine("{");

            sb.AppendLine("case 0:");//Delete

            // code block
            sb.AppendLine("$('#" + this.ID + "confirmDeleteModal').modal({ backdrop: 'static', keyboard: false })");
            sb.AppendLine("$('#" + this.ID + "confirmDeleteModal').modal('show');");
            sb.AppendLine("$('#" + this.ID + "confirmDeleteModalTitle').html('" + this.ControlLabels.DeleteModalTitle + "');");
            sb.AppendLine("$('#" + this.ID + "confirmationDeleteMessage').html('" + this.ControlLabels.DeleteModalMessage + "');");
            //END CODE BLOCK
            sb.AppendLine("break;");
            sb.AppendLine("case 1:");//Save
            // code block
            sb.AppendLine("break;");
            sb.AppendLine("case 2:");//Edit
                                     // code block
            sb.AppendLine("$('#" + this.ID + "editModal').modal({ backdrop: 'static', keyboard: false })");
            sb.AppendLine("$('#" + this.ID + "editModal').modal('hide');");
            //sb.AppendLine("$('#" + this.ID + "confirmModal').modal('show');");
            //sb.AppendLine("$('#" + this.ID + "confirmModalTitle').html('" + this.ControlLabels.EditModalTitle + "');");
            //sb.AppendLine("$('#" + this.ID + "confirmationMessage').html('" + this.ControlLabels.EditModalMessage + "');");
            sb.AppendLine("break;");
            sb.AppendLine("case 3:");//Inline Edit
            // code block

            sb.AppendLine("$(\"[id$='-error']\").each(function(i,j){ $(j).remove(); });");
            sb.AppendLine(this.ID + "validator.form();");
            sb.AppendLine("$(\"[id$= '-error']\").each(function(i,j){");
            sb.AppendLine(" if($(j).next().hasClass(\"select2\")){");
            sb.AppendLine("     $(j).next().after(j.outerHTML);");
            sb.AppendLine("     $(j).html(\"\");");
            sb.AppendLine(" }");
            sb.AppendLine("});");

            //Check Validations
            sb.AppendLine("if(" + this.ID + "numOfInvalids < 1){");
            sb.AppendLine(this.ID.ToString() + "GRIDAJAXINLINEEDIT();");
            //sb.AppendLine("$('#" + this.ID + "confirmModal').modal('show');");
            // sb.AppendLine("$('#" + this.ID + "confirmModalTitle').html('" + this.ControlLabels.SaveInlineEditTitle + "');");
            // sb.AppendLine("$('#" + this.ID + "confirmationMessage').html('" + this.ControlLabels.SaveInlineEditMessage + "');");
            sb.AppendLine("};");
            sb.AppendLine("" + this.ID + "numOfInvalids = 0;");

            sb.AppendLine("break;");

            sb.AppendLine("case 4:");//Delete

            // code block
            sb.AppendLine("$('#" + this.ID + "deleteExceptionModal').modal({ backdrop: 'static', keyboard: false })");
            sb.AppendLine("$('#" + this.ID + "deleteExceptionModal').modal('show');");
            sb.AppendLine("$('#" + this.ID + "deleteExceptionModalTitle').html('" + this.ControlLabels.DeleteExceptionTitle + "');");
            sb.AppendLine("$('#" + this.ID + "deleteExceptionModalDeleteMessage').html('" + this.ControlLabels.DeleteExceptionMessage + "');");
            //sb.AppendLine("$('#" + this.ID + "deleteExceptionModalDeleteMessage').html('TEST MESSAGE');");
            //END CODE BLOCK
            sb.AppendLine("break;");

            sb.AppendLine("case 5:"); //Child record remove

            // code block
            sb.AppendLine("$('#" + this.ID + "confirmRemoveModal').modal({ backdrop: 'static', keyboard: false })");
            sb.AppendLine("$('#" + this.ID + "confirmRemoveModal').modal('show');");
            sb.AppendLine("$('#" + this.ID + "confirmRemoveModalTitle').html('" + this.ControlLabels.DeleteModalTitle + "');");
            sb.AppendLine("$('#" + this.ID + "confirmationRemoveMessage').html('" + this.ControlLabels.DeleteModalMessage + "');");
            //END CODE BLOCK
            sb.AppendLine("break;");

            sb.AppendLine("default:");
            // code block
            sb.AppendLine("}");
            ///End Method
            sb.AppendLine("}");
            sb.AppendLine("$(\"#" + this.ID + "ConfirmModalButton\").click(function() {");
            sb.AppendLine("if(action == 2){");
            sb.AppendLine(this.ID.ToString() + "GRIDAJAXEDIT();");
            sb.AppendLine("$('#" + this.ID + "confirmModal').modal('hide');");
            sb.AppendLine("};");
            sb.AppendLine("if(action == 3){");

            sb.AppendLine(this.ID.ToString() + "GRIDAJAXINLINEEDIT();");

            //sb.AppendLine(" $('#" + this.ID + "confirmModal').modal('hide');");
            sb.AppendLine("};");

            sb.AppendLine("if(action ==0){");
            sb.AppendLine(this.ID.ToString() + "GRIDAJAXDELETE();");
            sb.AppendLine("$('#" + this.ID + "confirmModal').modal('hide');");
            sb.AppendLine("};");
            sb.AppendLine("});");

            sb.AppendLine("$(\"#" + this.ID + "ConfirmDeleteModalButton\").click(function() {");
            sb.AppendLine("if(action ==0){");
            sb.AppendLine(this.ID.ToString() + "GRIDAJAXDELETE();");
            sb.AppendLine("$('#" + this.ID + "confirmDeleteModal').modal('hide');");
            sb.AppendLine("};");
            sb.AppendLine("});");

            sb.AppendLine("$(\"#" + ID + "ConfirmRemoveModalButton\").click(function() {");
            sb.AppendLine("if(action == 5){");
            sb.AppendLine(ID.ToString() + "GRIDAJAXREMOVE();");
            sb.AppendLine("$('#" + ID + "confirmRemoveModal').modal('hide');");
            sb.AppendLine("};");
            sb.AppendLine("});");

            //Add Confirmation Button Events Here
            return sb.ToString();
        }

        private string sbFile(string strFileAndPath, List<KeyValuePair<string, string>> ldReplacements)
        {
            string strContent = string.Empty;

            //string strPath = ".\\TagHelpers\\js.txt";
            using (StreamReader sr = File.OpenText(strFileAndPath))
            {
                strContent = sr.ReadToEnd();
            }
            ListDictionary ld = new ListDictionary();

            //Make replacesments
            foreach (KeyValuePair<string, string> kvpItem in ldReplacements)
            {
                strContent = strContent.Replace("[" + kvpItem.Key + "]", kvpItem.Value);
            }

            StringBuilder sb = new StringBuilder();

            sb.Append(strContent);

            return sb.ToString();
        }

        /// <summary>
        /// Create Validation Definitions
        /// </summary>
        /// <returns></returns>
        public string BuildValidators()
        {
            StringBuilder sb = new StringBuilder();
            // sb.AppendLine("function " + this.ModalId + "BuildValidators(){");

            for (int c = 0; c < gridConfiguration.ColumnNames.Count; c++)
            {
                if (gridConfiguration.ColumnNames[c].ValidationSetting != null)
                {
                    if (gridConfiguration.ColumnNames[c].ValidationSetting != null)
                    {
                        if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.REQUIRED)
                        {
                            sb.AppendLine("jQuery.validator.messages = { required: '" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidatorMessage + "'};");
                        }
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.REQUIRED)
                    {
                        sb.AppendLine("jQuery.validator.addMethod(\"cRequired\",jQuery.validator.methods.required, \"" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidatorMessage + "\");");
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("cRequired: true");
                        sb.AppendLine("});");
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("range:" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("});");
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("range:" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule + ",");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");
                    }
                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_LOWER_RANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");

                        //Make sure that lower value is not greater than upper value
                        sb.AppendLine("jQuery.validator.addMethod(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", function(value, element) {");
                        sb.AppendLine("var validation_Rule = " + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var ctrlArray = validation_Rule;");
                        // sb.AppendLine("alert(ctrlArray[0])");
                        sb.AppendLine("var " + this.ID + "ctrl_1 = $(\".\" + ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ID + "ctrl_2 = $(\".\" + ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ID + "lowerRangeCustomEval(value," + this.ID + "ctrl_1," + this.ID + "ctrl_2 );");
                        sb.AppendLine("}, \"" + gridConfiguration.ColumnNames[c].ValidationSetting.RangeValidationMessage + "\");");
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_UPPER_RANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");

                        //Make sure that lower value is not greater than upper value
                        sb.AppendLine("jQuery.validator.addMethod(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", function(value, element) {");
                        sb.AppendLine("var validation_Rule = " + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var ctrlArray = validation_Rule;");

                        sb.AppendLine("var " + this.ID + "ctrl_1 = $(\".\" + ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ID + "ctrl_2 = $(\".\" + ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ID + "upperRangeCustomEval(value," + this.ID + "ctrl_1," + this.ID + "ctrl_2 );");
                        sb.AppendLine("}, \"" + gridConfiguration.ColumnNames[c].ValidationSetting.RangeValidationMessage + "\");");
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.CHARACTERRANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + gridConfiguration.ColumnNames[c].ClassName + "\", {");
                        sb.AppendLine("rangelength:" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("});");
                    }
                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.DATECOMPARE_2_FIELDS)
                    {
                        sb.AppendLine("jQuery.validator.addMethod(\"" + this.ID + "dateEval2\", function(value, element) {");
                        sb.AppendLine("var " + this.ID + "validation_Rule =" + gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var " + this.ID + "ctrlArray = " + this.ID + "validation_Rule;");
                        sb.AppendLine("alert(ctrlArray[0]);");
                        sb.AppendLine("var " + this.ID + "ctrl_1 = $(\".\" + ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ID + "ctrl_2 = $(\".\" + ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ID + "dateEval2(value," + this.ID + "ctrl_1," + this.ID + "ctrl_2 );");
                        sb.AppendLine("}, \"Date Range\");");
                    }

                    if (gridConfiguration.ColumnNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.DROPDOWN_REQUIRED)
                    {
                        sb.AppendLine("jQuery.validator.addMethod(\"" + this.ID + "dropDownReq\", function(value, element) {");
                        sb.AppendLine("alert(element);");
                        sb.AppendLine("return " + this.ID + "dropDownReq(" + gridConfiguration.ColumnNames[c].ClassName + ");");
                        sb.AppendLine("}, \"Date Range\");");
                    }
                }
            }

            return sb.ToString();
        }

        public string BuildValidationFunctions()
        {
            StringBuilder sb = new StringBuilder();

            //Evaluate Date Range
            sb.AppendLine("var " + this.ID + "dateEval2 = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ID + "date1 = ctr1;");
            sb.AppendLine("var " + this.ID + "date2 = ctr2;");

            sb.AppendLine("var " + this.ID + "d1 = new Date(" + this.ID + "date1);");
            sb.AppendLine("var " + this.ID + "d2 = new Date(" + this.ID + "date2);");
            sb.AppendLine("var " + this.ID + "same = " + this.ID + "d1.getTime() < " + this.ID + "d2.getTime();");
            sb.AppendLine("return " + this.ID + "same;");
            sb.AppendLine("};");

            //DropDown is Required
            sb.AppendLine("var " + this.ID + "dropDownReq = function(element) {");
            sb.AppendLine("var " + this.ID + "d1 =  $(\".\" + element).select2('data');");
            sb.AppendLine("var " + this.ID + "same = " + this.ID + "d1.length < 0");
            sb.AppendLine("return " + this.ID + "same;");
            sb.AppendLine("};");

            //lower value is not greater than upper value
            sb.AppendLine("var " + this.ID + "lowerRangeCustomEval = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ID + "_ctr1 = ctr1;");
            sb.AppendLine("var " + this.ID + "_ctr2 = ctr2;");
            sb.AppendLine("var " + this.ID + "lowerRangeIsNotGreaterThanUpper = ((" + this.ID + "_ctr2 > " + this.ID + "_ctr1) & (" + this.ID + "_ctr1  >= 0)) & (" + this.ID + "_ctr1  <= 2147483647);");
            sb.AppendLine("return " + this.ID + "lowerRangeIsNotGreaterThanUpper;");
            sb.AppendLine("};");

            //Upper value is not less than lower value
            sb.AppendLine("var " + this.ID + "upperRangeCustomEval = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ID + "_ctr1 = ctr1;");
            sb.AppendLine("var " + this.ID + "_ctr2 = ctr2;");
            sb.AppendLine("var " + this.ID + "upperRangeIsNotLowerThanLower = ((" + this.ID + "_ctr1 < " + this.ID + "_ctr2) & (" + this.ID + "_ctr2  >= 0 )) & (" + this.ID + "_ctr2  <= 2147483647) ;");
            sb.AppendLine("return " + this.ID + "upperRangeIsNotLowerThanLower;");
            sb.AppendLine("};");

            return sb.ToString();
        }
    }
}