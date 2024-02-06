using EIDSS.Localization.Constants;
using EIDSS.Web.ViewModels;
using Microsoft.Extensions.Localization;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Text;
using EIDSS.Localization.Providers;
using EIDSS.Localization.Extensions;

namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-select2DropDown")]
    public class EIDSSDropDownTagHelper : TagHelper
    {
        /// <summary>
        /// ID Of Control
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// Name Of Control
        /// </summary>
        public string Name { get; set; }

        [HtmlAttributeName("asp-for")]
        public ModelExpression AspFor { get; set; }

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
        /// Set to true if using control in a partial view
        /// or view component.
        /// </summary>
        public bool ConfigureForPartial { get; set; }

        /// <summary>
        /// Set to true if using control in a partial view Dynamic Refresh
        /// or view component.
        /// </summary>
        public bool PartialDynamicLoad { get; set; }

        /// <summary>
        /// Default Data for dropdown
        /// </summary>
        public Select2DataItem selectct2DefaultData { get; set; }

        /// <summary>
        /// Default Data for multi select dropdown
        /// </summary>
        public List<Select2DataItem> defaultSelect2MultipleSelection { get; set; }

        /// <summary>
        /// Control who's data is sent to endpoint
        /// To filter this control's data
        /// </summary>
        public string FilterId { get; set; }

        /// <summary>
        /// Multiple selecetion option
        /// </summary>
        public bool Multiple { get; set; }

        /// <summary>
        /// Allows users to create their own items
        /// </summary>
        public bool AllowTags { get; set; }

        public EIDSSGenericPostParameters filteredData { get; set; }

        public bool isDisabled { get; set; }
        public bool isVisible { get; set; }
        public bool isRequired { get; set; }
        public string RequiredErrorMessage { get; set; }
        public string ControlTargetId { get; set; }
        public string CustomJsOnChangeFunction { get; set; }
        public string CustomJsOnClearFunction { get; set; }
        public string CustomJsOnUnselectFunction { get; set; }
        public string CustomJsOnLoadFunction { get; set; }

        public string PartialUrl { get; set; }

        /// <summary>
        /// Controls that are disabled when dropdown is empty comma dilimeted list of controls
        /// </summary>
        public string DisabledControls { get; set; }
        public bool IncludeAddButton { get; set; }
        public string AddModalId { get; set; }
        public string AddButtonId { get; set; }
        public bool IncludeSearchButton { get; set; }
        public string SearchModalId { get; set; }
        public string SearchButtonId { get; set; }
        public bool FilterSortEnable { get; set; }
        public string FilterSortPlaceholder { get; set; }
        public string FilterSortTotalColumns { get; set; }
        public string FilterSortTemplateSelectorColumn { get; set; }
        public string FilterSortSortColumn { get; set; }
        private readonly IStringLocalizer Localizer;
        private readonly IServiceProvider ServiceProvider;
        private LocalizationMemoryCacheProvider CacheProvider;

        //public string EIDSSSSelect2CustomDropdownAdapter { get; set; }

        public EIDSSDropDownTagHelper(IStringLocalizer localizer, IServiceProvider serviceProvider)
        {
            Localizer = localizer;
            ServiceProvider = serviceProvider;
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            if (isVisible == true)
            {
                //ClassName
                output.PreElement.AppendHtml("<label class='" + LabelClassName + "' for='" + ID + "'>" + LabelName + "</label>");
                if (IncludeAddButton == true || IncludeSearchButton == true)
                {
                    output.PreElement.AppendHtml("<div class=\"input-group flex-nowrap\">");
                }
               
                //Actual Element
                output.TagName = "select";
              
                //Create Attributes
                if (!string.IsNullOrEmpty(ID))
                {
                    output.Attributes.SetAttribute("id", ID);
                }
                if (!string.IsNullOrEmpty(Name))
                {
                    output.Attributes.SetAttribute("name", Name);
                }
                if (!string.IsNullOrEmpty(ClassName))
                {
                    //output.Attributes.SetAttribute("class", this.ClassName);
                }

                if (IncludeAddButton)
                {
                    output.Attributes.SetAttribute("style", "min-width: 100px; width: 90%;");
                }
                else
                {
                    output.Attributes.SetAttribute("style", "min-width: 100px; width: 100%;");
                }

                if (isRequired)
                {
                    output.Attributes.SetAttribute("data-val", "true");
                    output.Attributes.SetAttribute("data-val-required", RequiredErrorMessage);
                }

                if (AspFor != null)
                {
                    output.Attributes.Add("value", AspFor.Model);

                    if ((AspFor.Metadata.ValidatorMetadata.Count > 0))
                    {
                        CacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
                        output.Attributes.Add("data-val", "true");

                        foreach (object validator in AspFor.Metadata.ValidatorMetadata)
                        {
                            switch (validator.GetType().Name)
                            {
                                case nameof(Localization.Helpers.LocalizedRequiredAttribute):
                                    var localizedRequiredAttribute = AspFor.Metadata.ValidatorMetadata.OfType<Localization.Helpers.LocalizedRequiredAttribute>().FirstOrDefault();
                                    output.Attributes.Add("data-val-required", Localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage));
                                    break;
                                case nameof(Localization.Helpers.LocalizedRequiredIfTrueAttribute):
                                    var localizedRequiredIfTrueAttribute = AspFor.Metadata.ValidatorMetadata.OfType<Localization.Helpers.LocalizedRequiredIfTrueAttribute>().FirstOrDefault();
                                    string propertyValue = typeof(FieldLabelResourceKeyConstants).GetField(localizedRequiredIfTrueAttribute.PropertyName).GetValue(typeof(FieldLabelResourceKeyConstants)).ToString();

                                    if (bool.TryParse(CacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(System.Threading.Thread.CurrentThread.CurrentCulture.Name, propertyValue), out bool isRequired))
                                        if (isRequired)
                                            output.Attributes.Add("data-val-localizedrequirediftrue", Localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage));
                                    break;
                            }
                        }
                    }
                }

                //Enable Start and  End Tag
                output.TagMode = TagMode.StartTagAndEndTag;

                var sb = new StringBuilder();
                //Adding Options to Select 
                sb.AppendFormat("<option> </option>");

                //Render Output
                output.PreContent.SetHtmlContent(sb.ToString());

                if (IncludeAddButton == true || IncludeSearchButton == true)
                {
                    output.PostElement.AppendHtml("<div class=\"input-group-append\">");

                    if (IncludeSearchButton == true)
                        output.PostElement.AppendHtml("<button id='" + SearchButtonId + "'" + "class=\"btn btn-outline-secondary btn-sm\" type=\"button\" data-toggle=\"modal\" data-target=\"#" + SearchModalId + "\"><span class=\"fas fa-search\" aria-hidden=\"true\"></span></button>");

                    if (IncludeAddButton == true)
                        output.PostElement.AppendHtml("<button id='" + AddButtonId + "'" + "class=\"btn btn-outline-secondary btn-sm\" type=\"button\" data-toggle=\"modal\" data-target=\"#" + AddModalId + "\"><span class=\"fas fa-plus\" aria-hidden=\"true\"></span></button>");

                    output.PostElement.AppendHtml("</div>");
                    output.PostElement.AppendHtml("</div>");
                }

                //jQuery validation span
                output.PostElement.AppendHtml("<span class='text-danger field-validation-valid' data-valmsg-for='" + Name + "' data-valmsg-replace='true'></span>");

                //Injecting Javascript For Select2
                output.PostElement.AppendHtml(LoadJavascript());
            }
        }

        DropDownTargetTypes _targetType;
        public DropDownTargetTypes TargetType { get { return _targetType; } set { _targetType = value; } }

        public string TargetAjaxUrl { get; set; }
        public string LoadJavascript()
        {
            StringBuilder sb = new();
            sb.AppendLine("<script>");

            if (PartialDynamicLoad)
            {
                sb.AppendLine(LoadSelect2DropDown(true));
            }

            if (!ConfigureForPartial)
            {
                sb.AppendLine("window.addEventListener('load', function() {");
                sb.AppendLine("$(document).ready(function() {");
            }

            sb.AppendLine(SetFilteredDataFunction());

            sb.AppendLine(LoadSelect2DropDown());

            if (PartialDynamicLoad)
            {
                var functionName = ID + "Select2Function";
                sb.AppendLine(functionName + "();");
            }

            if (!ConfigureForPartial)
            {
                sb.AppendLine("});");
                sb.AppendLine("});");
            }

            if (FilterSortEnable)
            {
                sb.AppendLine(LoadFilterSort());
            }

            sb.AppendLine("</script>");
            return sb.ToString();
        }

        private string LoadSelect2DropDown(bool generateAsFunction =false)
        {

            StringBuilder sb = new();

            if (PartialDynamicLoad)
            {
                var functionName = ID + "Select2Function";
                sb.AppendLine("function " + functionName + "(){");
            }
            var select2JsElement =GenerateSelect2JsElement();
            sb.AppendLine(select2JsElement);
            sb.AppendLine();
            if (PartialDynamicLoad)
            {
                sb.AppendLine("}");
            }
          
            
            sb.AppendLine();

            return sb.ToString();
        }

        private string GenerateSelect2JsElement()
        {
            StringBuilder sb = new();
            if (filteredData != null)
            {
                sb.AppendLine("var " + ID + "data ='" + Newtonsoft.Json.JsonConvert.SerializeObject(filteredData) + "'");
                // sb.AppendLine("console.log(data);");
            }
            else if (!string.IsNullOrEmpty(FilterId))
            {
                sb.AppendLine("var " + ID + "idfFilteredData =\"\";");
                sb.AppendLine(ID + "SetFilteredData(); ");
            }

            sb.AppendLine("//Instantiate Select 2 Library on DropDown");
            sb.AppendLine(" $('#" + ID + "').select2({");
            sb.AppendLine("ajax: {");
            sb.AppendLine("url:'" + EndPoint + "',");
            sb.AppendLine("data: function (params) {");
            sb.AppendLine("var query = {");

            if (!String.IsNullOrEmpty(FilterId))
            {
                sb.AppendLine("data: JSON.stringify(" + ID + "idfFilteredData),");
            }
            else if (filteredData != null)
            {
                sb.AppendLine(ID + "data ,");
            }

            sb.AppendLine(" term: params.term, page: params.page || 1");
            sb.AppendLine("}");
            sb.AppendLine("return query");
            sb.AppendLine("}");
            sb.AppendLine("},");
            sb.AppendLine("width:'resolve',");
            sb.AppendLine("theme:'bootstrap',");
            sb.AppendLine("tags:" + AllowTags.ToString().ToLower() + ",");
            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            if (isDisabled)
            {
                sb.AppendLine("disabled: true,");
            }

            sb.AppendLine("minimumInputLength: 0,");
            sb.AppendLine("multiple:" + Multiple.ToString().ToLower() + ",");
            sb.AppendLine("placeholder: ' '");
            sb.AppendLine("});");
            //END SELECT 2 INSTANTIATION

            //On Change Event of Filtering Control We Use It's Data
            if (!string.IsNullOrEmpty(FilterId))
            {
                sb.AppendLine("$('#" + this.FilterId + "').on('select2:select', function(e) {");
                sb.AppendLine("idfFilteredData =  e.params.data;");
                sb.AppendLine(" });");
            }

            //Disable or Enable Control
            // sb.AppendLine("$('#" + ID + "').prop('disabled', " + isDisabled.ToString().ToLower() + ");");

            // if(isDisabled)
            //sb.AppendLine("$('#" + ID + "').prop('disabled','true'" + ");");

            //Set Default data
            if (selectct2DefaultData != null)
            {
                //Needed to get past apostrophes, which break the javascript string values.
                string strSelect2Text = string.Empty;

                if (!string.IsNullOrEmpty(selectct2DefaultData.text))
                {
                    strSelect2Text = selectct2DefaultData.text.Replace("'", "\'");
                }

                sb.AppendLine("var " + ID + "newOption = new Option('" + strSelect2Text + "','" + selectct2DefaultData.id +
                              "', true, true);");
                sb.AppendLine("$('#" + ID + "').append(" + ID + "newOption);");

                //Set selected Value
                sb.AppendLine(" $('#" + ID + "').select2(");
                sb.AppendLine("'data',{ id: '" + selectct2DefaultData.id + "', text: '" + strSelect2Text + "'})");
            }

            //Custom Onload Function
            if (!string.IsNullOrEmpty(CustomJsOnLoadFunction))
            {
                sb.AppendLine(CustomJsOnLoadFunction + "(" + selectct2DefaultData.id + ");");
            }

            //Check for multiple select default data
            if (Multiple == true && defaultSelect2MultipleSelection != null && defaultSelect2MultipleSelection.Count > 0)
            {
                foreach (var selectItem in defaultSelect2MultipleSelection)
                {
                    sb.AppendLine("var " + ID + defaultSelect2MultipleSelection.IndexOf(selectItem) +
                                  "newOption = new Option('" + selectItem.text + "','" + selectItem.id + "', true, true);");
                    sb.AppendLine("$('#" + ID + "').append(" + ID + defaultSelect2MultipleSelection.IndexOf(selectItem) +
                                  "newOption);");
                }
            }

            //ON Select Event Of Main Control
            sb.AppendLine("$('#" + ID + "').on('select2:select', function(e) {");
            // Do somethingAler

            if (!string.IsNullOrEmpty(ControlTargetId))
            {
                if (TargetType == DropDownTargetTypes.Table)
                {
                    sb.AppendLine("var grid = $('#" + ControlTargetId + "').DataTable();");
                    sb.AppendLine("grid.ajax.url('" + TargetAjaxUrl + "').load();");
                }
                else if (TargetType == DropDownTargetTypes.Partial)
                {
                    //sb.AppendLine("var grid = $('#" + ControlTargetId + "').DataTable();");

                    //sb.AppendLine("$('#_gridPartial').load('" + PartialUrl + "');");
                }
                else if (TargetType == DropDownTargetTypes.DropDown)
                {
                }
                else
                {
                }
            }

            if (!string.IsNullOrEmpty(CustomJsOnChangeFunction))
            {
                sb.AppendLine(CustomJsOnChangeFunction + "(e.params.data);");
            }


            sb.AppendLine("});");

            //On Open EVENT OF Main Control 


            sb.AppendLine("$('#" + ID + "').on('select2:opening', function(e) {");
            if (!string.IsNullOrEmpty(FilterId))
            {
                sb.AppendLine(ID + "SetFilteredData(); ");
            }

            sb.AppendLine("});");
            //End Open EVENT

            // On Close event; trigger validation to potentially add or remove required field message if
            // user has selected a value.
            sb.AppendLine("$('#" + ID + "').on('select2:close', function(e) {");
            if (AspFor != null || isRequired)
            {
                sb.AppendLine("$(this).valid();");
            }

            sb.AppendLine("});");
            // End Close Event

            // On unselect event allow client side function
            if (!string.IsNullOrEmpty(CustomJsOnUnselectFunction))
            {
                sb.AppendLine("$('#" + ID + "').on('select2:unselect', function(e) {");
                sb.AppendLine(CustomJsOnUnselectFunction + "(e);");
                sb.AppendLine("});");
            }

            //END CHANGE EVENT
            if (!string.IsNullOrEmpty(CustomJsOnClearFunction))
            {
                sb.AppendLine("$('#" + ID + "').on('select2:clear', function(e) {");
                sb.AppendLine(CustomJsOnClearFunction + "(e);");
                sb.AppendLine("});");
            }

            //Disable Controls When Blank
            if (!string.IsNullOrEmpty(DisabledControls))
            {
                sb.AppendLine("var initialData = $('#" + ID + "').select2('data')[0];");
                var controlList = DisabledControls.Split(',');

                for (int i = 0; i < controlList.Length; i++)
                {
                    sb.AppendLine("if(initialData.id ==\"\"){");
                    sb.AppendLine("$(\"#" + controlList[0] + "\").prop('disabled', true)");
                    sb.AppendLine("}else{");
                    sb.AppendLine("$(\"#" + controlList[0] + "\").prop('disabled', false)");
                    sb.AppendLine("};");
                }
            }

            return sb.ToString();
        }

        private string SetFilteredDataFunction()
        {
            StringBuilder sb = new();
            if (!string.IsNullOrEmpty(FilterId))
            {

          
            sb.AppendLine("function " + ID+"SetFilteredData(){");
            sb.AppendLine("var controlType = $('#" + FilterId + "').prop('type')");
            sb.AppendLine("var " + ID + "data = {");
            sb.AppendLine(" id: '',");
            sb.AppendLine(" text: ''");
            sb.AppendLine(" };");

            sb.AppendLine("if( controlType != undefined ){");
            sb.AppendLine("if( controlType == \"text\" || controlType == \"number\"|| controlType == \"hidden\"){");
            sb.AppendLine(ID + "data.id = $('#" + FilterId + "').prop('id');");
            sb.AppendLine(ID + "data.text = $('#" + FilterId + "').val();");
            sb.AppendLine( ID +"idfFilteredData = " + ID + "data");
            sb.AppendLine("}");
            sb.AppendLine("else if( controlType == \"hidden\"){");
            sb.AppendLine(ID + "data.id = $('#" + FilterId + "').data('id');");
            sb.AppendLine(ID + "data.text =  $('#" + FilterId + "').data('text');");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "data");
            sb.AppendLine("}");
            sb.AppendLine("else if( controlType == \"checkbox\"){");
            sb.AppendLine(ID + "data.id = $('#" + FilterId + "').prop('id');");
            sb.AppendLine(ID + "data.text =  $('#" + FilterId + "').is(':checked');");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "data");
            sb.AppendLine("}");
            sb.AppendLine("else if( controlType == \"radio\"){");
            sb.AppendLine(ID + "data.id = $('#" + FilterId + "').prop('id');");
                //sb.AppendLine(this.ID + "data.text =  $('input[name=\"" + this.FilterId + "\"]:checked').val();");
            //Chnaged this line because in side bar navigation name and id are different
            sb.AppendLine(ID + "data.text =  $('#" + FilterId + ":checked').val();");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "data");
            sb.AppendLine("}");
            sb.AppendLine("else if( controlType == \"number\"){");
            sb.AppendLine(ID + "data.id = $('#" + FilterId + "').prop('id');");
            sb.AppendLine(ID + "data.text = $('#" + FilterId + "').val();");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "data");
            sb.AppendLine("}");
            sb.AppendLine("else if (controlType == \"select-one\"){");
            sb.AppendLine("var " + ID + "select2Data= $('#" + FilterId + "').select2('data');");
            sb.AppendLine("if (" + ID + "select2Data.length > 0){");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "select2Data");
            sb.AppendLine("}");
            sb.AppendLine("else if (controlType == \"select-multiple\"){");
            sb.AppendLine("var " + ID + "select2Data= $('#" + FilterId + "').select2('data');");
            sb.AppendLine("if (" + ID + "select2Data.length > 0){");
            sb.AppendLine(ID + "idfFilteredData =" + ID + "select2Data");
            sb.AppendLine("};");
            sb.AppendLine("};");
            sb.AppendLine("};");
            sb.AppendLine("};");
            sb.AppendLine("};");

            }
            return sb.ToString();
        }

        private string LoadFilterSort()
        {
            List<KeyValuePair<string, string>> kvpReplacements = new();

            kvpReplacements.Add(new KeyValuePair<string, string>("DROP_DOWN_LIST", ID));
            kvpReplacements.Add(new KeyValuePair<string, string>("FILTER_PLACEHOLDER", FilterSortPlaceholder));
            kvpReplacements.Add(new KeyValuePair<string, string>("TOTAL_COLUMNS", FilterSortTotalColumns));
            kvpReplacements.Add(new KeyValuePair<string, string>("TEMPLATE_SELECTOR_COLUMN", FilterSortTemplateSelectorColumn));
            kvpReplacements.Add(new KeyValuePair<string, string>("SORT_COLUMN", FilterSortSortColumn));
            kvpReplacements.Add(new KeyValuePair<string, string>("EIDSS_SELECT2_CUSTOM_DROPDOWN_ADAPTER", "EIDSSSelect2CustomDropDownAdapter"));
            
            return sbFile(".\\TagHelpers\\CustomFiles\\Select2FilterSort.txt", kvpReplacements);
        }

        private string sbFile(string strFileAndPath, List<KeyValuePair<string, string>> ldReplacements)
        {
            string strContent = string.Empty;

            //string strPath = ".\\TagHelpers\\js.txt";
            using (StreamReader sr = File.OpenText(strFileAndPath))
            {
                strContent = sr.ReadToEnd();
            }
            ListDictionary ld = new();

            //Make replacesments
            foreach (KeyValuePair<string, string> kvpItem in ldReplacements)
            {
                strContent = strContent.Replace("[" + kvpItem.Key + "]", kvpItem.Value);
            }

            StringBuilder sb = new();

            sb.Append(strContent);

            return sb.ToString();
        }
    }
}
