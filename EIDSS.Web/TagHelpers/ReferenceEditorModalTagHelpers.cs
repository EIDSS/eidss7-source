using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using System.IO;
using System.Collections.Specialized;

namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-reference-editors-modal")]
    public class ReferenceEditorModalTagHelpers : TagHelper
    {
        EIDSSControlLabels _controlLabels;
        /// <summary>
        /// Labels For buttons and Messages
        /// </summary>
        public EIDSSControlLabels ControlLabels { get { return _controlLabels; } set { _controlLabels = value; } }

        public string ModalId { get; set; }
        public Boolean enableDebug { get; set; }
        public string AjaxSaveUrl { get; set; }
        EIDSSModalConfiguration _eIDSSModalConfiguration;

        public string TargetGridControlID { get; set; }
        /// <summary>
        /// Grid Definition
        /// </summary>
        public EIDSSModalConfiguration modalConfiguration { get { return _eIDSSModalConfiguration; } set { _eIDSSModalConfiguration = value; } }
        public ReferenceEditorModalTagHelpers()
        {
            _eIDSSModalConfiguration = new EIDSSModalConfiguration();
            _controlLabels = new EIDSSControlLabels();
        }
        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            output.TagName = "div";
            //Enable Start and  End Tag
            output.TagMode = TagMode.StartTagAndEndTag;
            var sb = new StringBuilder();
            output.Content.AppendHtml(GenerateModal());
            output.Content.AppendHtml(LoadSuccessConfirmationMessages());
            //Render Output
            output.PreContent.SetHtmlContent(string.Empty);
            //Injecting Javascript For Select2
            output.PostElement.AppendHtml(LoadJavascript());
        }

        private string DefineDefaultJSDefinitions()
        {
            StringBuilder sb = new StringBuilder();
            if (_eIDSSModalConfiguration.ControlNames.Count > 0)
            {
                var jsonObj = Newtonsoft.Json.JsonConvert.SerializeObject(_eIDSSModalConfiguration).Replace("null", "\"\"");
                sb.AppendLine("var " + this.ModalId + "modalJSObject=" + jsonObj + ";");
            }
            //Initialze Validator For Form Elements
            sb.AppendLine("var "+ this.ModalId+"numOfInvalids = 0;");
            sb.AppendLine("var " + this.ModalId + "validator = $(\"#" + this.ModalId + "ModalForm\").validate({");
            sb.AppendLine("invalidHandler: function() {");
            sb.AppendLine(this.ModalId + "numOfInvalids = " + this.ModalId + "validator.numberOfInvalids();");
            sb.AppendLine("}");
            sb.AppendLine("});");
            sb.AppendLine(BuildValidationFunctions());


            return sb.ToString();
        }

        public string GenerateModal()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<form id=\"" + this.ModalId + "ModalForm\" >");
            sb.AppendLine("<div class=\"modal fade overflowy\" id=\"" + this.ModalId + "\" role=\"dialog\">");
            sb.AppendLine("<div class=\"modal-dialog  modal-lg\">");
            sb.AppendLine("<div class=\"modal-content\">");
            sb.AppendLine("<div class=\"modal-header " + this.modalConfiguration.ModalHeaderClass + "\">");
            sb.AppendLine("<h4 class=\"modal-title\">" + this.ControlLabels.ModalTitle + "</h4>");
            //sb.AppendLine("<a  href=\"#\" class=\"close\" onclick=\"" + this.ModalId + "MODALRESET();\">&times;</a>");
            sb.AppendLine("<button type=\"button\" class=\"btn btn-link close\" onclick=\"" + this.ModalId + "MODALRESET();\">&times;</button>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div id=\"addmodalbodyContent\" class=\"modal-body\">");
            sb.AppendLine("</br>");
            sb.AppendLine("<p><small>");
            sb.AppendLine(this.ControlLabels.ModalMessage);
            sb.AppendLine("</small></p>");
            sb.AppendLine("</br>");

            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {
                string validatorMessage = string.Empty;
                string validatorRangMessage = string.Empty;
                string validatorDateMessage = string.Empty;
                string validatorPhoneMessage = string.Empty;


                if (_eIDSSModalConfiguration.ControlNames[i].ValidationSetting != null)
                {
                    validatorMessage = !string.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidatorMessage) ? _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidatorMessage : string.Empty;
                    validatorRangMessage = !string.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ValidationSetting.RangeValidationMessage) ? _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.RangeValidationMessage : string.Empty;
                   // validatorPhoneMessage = !string.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ValidationSetting.PhoneValidationMessage) ? _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.PhoneValidationMessage : string.Empty;
                    if (_eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.PHONE)
                    {
                        var phoneData = _eIDSSModalConfiguration.ControlNames[i].DefaultContent;
                        if (!string.IsNullOrEmpty(phoneData))
                        {
                            validatorPhoneMessage = !string.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ValidationSetting.PhoneValidationMessage) ? _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.PhoneValidationMessage : string.Empty;
                        }
                    }
                }
                var _columnType = _eIDSSModalConfiguration.ControlNames[i].ControlType;

                sb.AppendLine("<div id =\'div" + i + "_" + this.ModalId + "\'>"); //wrapping a div around every control for better show/hide when needed

                if (_eIDSSModalConfiguration.ControlNames[i].ValidationSetting != null) {
                    bool bRequired = _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.REQUIRED | _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_LOWER_RANGE | _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_UPPER_RANGE | _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED;
                        //| _eIDSSModalConfiguration.ControlNames[i].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.PHONE;
                    sb.AppendLine(bRequired ? "<i class=\"text-danger fas fa-asterisk fa-sm\"></i>" : string.Empty);
                }

                switch (_columnType)
                {
                    case ControlType.Hidden:                        
                        sb.AppendLine("<input id='" + this.ModalId + "ctrlAdd_" + i + "' type='hidden' value='" + _eIDSSModalConfiguration.ControlNames[i].DefaultContent + "'>");                        
                        break;
                    case ControlType.DropDownAddButtonURL:
                            sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label>");
                            sb.AppendLine("<div class=\"input-group\">");
                            sb.AppendLine("<select class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\'   id =\'" + this.ModalId + "ctrlAdd_" + i + "\' name=\'" + this.ModalId + "ctrlAdd_" + i + "\'  style=\'width: 100 % \' data-msg=\'" + validatorMessage + "\'></select>");
                            sb.AppendLine("<div class=\"input-group-append\">");
                            sb.AppendLine("<button class=\"btn btn-outline-secondary\" type=\"button\" onclick=\"" + _eIDSSModalConfiguration.ControlNames[i].ClassName + this.ModalId + "AddButtonClick()\">+</button>");
                            sb.AppendLine("</div>");
                            sb.AppendLine("</div>");
                        break;
                    case ControlType.DropDown:
                            sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br><select class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\'   id =\'" + this.ModalId + "ctrlAdd_" + i + "\' name =\'" + this.ModalId + "ctrlAdd_" + i + "\'  style=\'width: 100 % \'  data-msg=\'" + validatorMessage + "\'></select></br>");
                        break;
                    case ControlType.DropDownAddButtonOpenModal:
                        string strCustomScrpt = _eIDSSModalConfiguration.ControlNames[i].DropDownAddButtonOpenModalCustomFunction;
                        
                        if (!string.IsNullOrEmpty(strCustomScrpt))
                        {
                            strCustomScrpt = (strCustomScrpt.Replace(";", "")) + ";";
                        }

                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label>");
                            sb.AppendLine("<div class=\"input-group\">");
                            sb.AppendLine("<select class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\'   id =\'" + this.ModalId + "ctrlAdd_" + i + "\' name =\'" + this.ModalId + "ctrlAdd_" + i + "\'  style=\'width: 100 % \'  data-msg=\'" + validatorMessage + "\'></select>");
                            sb.AppendLine("<div class=\"input-group-append\">");
                            sb.AppendLine("<button class=\"btn btn-outline-secondary\" type=\"button\" onclick=\"" + strCustomScrpt + _eIDSSModalConfiguration.ControlNames[i].ClassName + this.ModalId + "OpenModalClick()\">+</button>");
                            sb.AppendLine("</div>");
                            sb.AppendLine("</div>");
                        break;
                    case ControlType.Default:
                        sb.AppendLine("<input id='" + this.ModalId + "ctrlhidden_" + i + "' type='hidden' value='" + validatorPhoneMessage + "'>");
                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br><input id=\'" + this.ModalId + "ctrlAdd_" + i + "\'  name=\'" + this.ModalId + "ctrlAdd_" + i + "\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' data-msg=\'" + validatorMessage + "\'  data-msg-range =\'" + validatorRangMessage + "\' data-msg-phone =\'" + validatorPhoneMessage + "\'></input></br>");
                        break;
                    case ControlType.Numeric:
                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br><input onkeydown='return event.keyCode !== 69' type=\"number\" id=\'" + this.ModalId + "ctrlAdd_" + i + "\'  name=\'" + this.ModalId + "ctrlAdd_" + i + "\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' data-msg=\'" + validatorMessage + "\'  data-msg-range =\'" + validatorRangMessage + "\'  onfocusout=\'" + _eIDSSModalConfiguration.ControlNames[i].FocusOutMethod + "\'></input></br>");
                        break;
                    case ControlType.NumericRangeRequired:
                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br><input onkeydown='return event.keyCode !== 69' type=\"number\" id=\'" + this.ModalId + "ctrlAdd_" + i + "\'  name=\'" + this.ModalId + "ctrlAdd_" + i + "\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName  + "\' required  onfocusout=\'" + _eIDSSModalConfiguration.ControlNames[i].FocusOutMethod + "\'></input></br>");
                        break;
                    case ControlType.CheckBox:
                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br>");
                        if (_eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions != null)
                        {
                            for (int c = 0; c < _eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions.Count(); c++)
                            {
                                var options = _eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions[c];
                                if (options.IsChecked == true)
                                {
                                    sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + options.Key + "</label><input type=\'checkbox\' id=\'" + this.ModalId + "ctrlAdd_" + i + "\' name=\'" + this.ModalId + "ctrlAdd_" + i + "\' value=\'" + options.Value + "\' checked=\'checked\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' ></input></br>");
                                }
                                else
                                {
                                    sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + options.Key + "</label><input type=\'checkbox\' id=\'" + this.ModalId + "ctrlAdd_" + i + "\' name=\'" + this.ModalId + "ctrlAdd_" + i + "\' value=\'" + options.Value + "\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' ></input></br>");
                                }
                            }
                        }
                        break;
                    case ControlType.RadioButton:
                        sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + _eIDSSModalConfiguration.ControlNames[i].LabelNameForControl + "</label></br>");
                        if (_eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions != null)
                        {


                            for (int r = 0; r < _eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions.Count(); r++)
                            {
                                var options = _eIDSSModalConfiguration.ControlNames[i].RadioCheckBoxOptions[r];

                                if (options.IsChecked == true)
                                {
                                    sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + options.Key + "</label></br><input type=\'radio\' id=\'" + this.ModalId + "ctrlAdd_" + i + "\'  name=\'" + this.ModalId + "ctrlAdd_" + i + "\' value=\'" + options.Value + "\' checked=\'checked\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' ></input></br>");
                                }
                                else
                                {
                                    sb.AppendLine("<label id =\'" + this.ModalId + "lblAdd_" + i + "\'>" + options.Key + "</label></br><input type=\'radio\' id=\'" + this.ModalId + "ctrlAdd_" + i + "\'  name=\'" + this.ModalId + "ctrlAdd_" + i + "\' value=\'" + options.Value + "\' class=\'" + _eIDSSModalConfiguration.ControlNames[i].ClassName + "\' ></input></br>");
                                }

                            }
                        }
                        break;
                    default:
                        break;
                }
                sb.AppendLine("</div>");
            }
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"modal-footer\">");
            //sb.AppendLine("<a class=\"btn btn-default\" href=\"#\" onclick=\"" + this.ModalId + "MODALAJAXPOST();\">" + _eIDSSModalConfiguration.ControlLabels.SaveButtonLabel + "</a>");
            sb.AppendLine("<button id=\"" + this.ModalId + "btnSave\" class=\"btn btn-primary\" type=\"button\" onclick=\"" + this.ModalId + "MODALAJAXPOST();\">" + _eIDSSModalConfiguration.ControlLabels.SaveButtonLabel + "</button>");
            //sb.AppendLine("<a id=\"" + this.ModalId + "btnCancel\"  class=\"btn btn-default\" href=\"javascript: void(0)\" onclick=\"" + this.ModalId + "MODALRESET();\">" + _eIDSSModalConfiguration.ControlLabels.CloseButtonLabel + "</a>");
            if (_eIDSSModalConfiguration.DisplayConfirmCancelModal == true)
            {
                sb.AppendLine("<button id=\"" + this.ModalId + "btnCancel\"  type=\"button\" class=\"btn btn-outline-primary\" onclick=\"" + _eIDSSModalConfiguration.CancelConfirmationFunction +"\">" + _eIDSSModalConfiguration.ControlLabels.CancelButtonLabel + "</button>");
            }
            else
            {
                sb.AppendLine("<button id=\"" + this.ModalId + "btnCancel\"  type=\"button\" class=\"btn btn-outline-primary\" onclick=\"" + this.ModalId + "MODALRESET();\">" + _eIDSSModalConfiguration.ControlLabels.CancelButtonLabel + "</button>");
            }
          

            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</form>");
            return sb.ToString();
        }

        public string LoadSuccessConfirmationMessages()
        {
            List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>();

            kvpReplacements.Add(new KeyValuePair<string, string>("MODALID", this.ModalId + "SuccessModal"));
            kvpReplacements.Add(new KeyValuePair<string, string>("MODALHEADERCLASS", this.modalConfiguration.ModalHeaderClass));
            kvpReplacements.Add(new KeyValuePair<string, string>("SUCCESSMODALTITLE", this.modalConfiguration.ControlLabels.SuccessModalTitle));
            kvpReplacements.Add(new KeyValuePair<string, string>("SUCCESSMESSAGE", this.modalConfiguration.ControlLabels.SuccessMessage));
            kvpReplacements.Add(new KeyValuePair<string, string>("OKBUTTONLABEL", _eIDSSModalConfiguration.ControlLabels.OkButtonLabel));

            return sbFile(".\\TagHelpers\\CustomFiles\\LoadSuccessConfirmationMessages.html", kvpReplacements);
        }

        public string LoadJavascript()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<script type='text/javascript'>");
            //DEFINE OBJECTS
            sb.AppendLine(DefineDefaultJSDefinitions());
            sb.AppendLine(GenerateJSSelect2DropDowns());
            sb.AppendLine(SetFilteredDataFunction());
            sb.AppendLine(GenerateModalSave());
            sb.AppendLine(RefreshTarget());
            //Validation Rules
            sb.AppendLine(BuildValidators());

            //DROPDOWN ADD BUTTON URL FOR AJAX
            sb.AppendLine(GenerateAddButtonAjaxCall());

            sb.AppendLine("function OpenAddModal() { ");
            sb.AppendLine(" $(\"#" + this.ModalId + "SuccessModal\").modal('hide');");
            sb.AppendLine(" $(\"#" + this.ModalId + "\").modal('show');");
            sb.AppendLine("}");
            sb.AppendLine("</script>");
            return sb.ToString();
        }

        //Functon to filter dropdowns data
        private string SetFilteredDataFunction()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function " + this.ModalId + "SetFilteredData(){");
            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {
                if (!string.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                {
                    string[] filteredControlIds = _eIDSSModalConfiguration.ControlNames[i].FilteredControlId.Split(',');
                    sb.AppendLine("var controlType =\"\"");
                    sb.AppendLine("var idfFilteredData=\"\"");
                    for (int j = 0; j < filteredControlIds.Length; j++)
                    {
                        sb.AppendLine("controlType = $('#" + filteredControlIds[j] + "').prop('type')");
                        //Creating JSON OBJECT TO SEND TO API TO FILTER THIS DROP DOWNS DATA
                        sb.AppendLine("var data = {");
                        sb.AppendLine(" id: '',");
                        sb.AppendLine(" text: ''");
                        sb.AppendLine(" };");
                        //CHECK FOR THE CONTROL TYPE FROM THE LIST OF FILTERED CONTROLS
                        sb.AppendLine("if(controlType != undefined ){");
                        sb.AppendLine("if(controlType == \"text\" || controlType == \"number\"|| controlType == \"hidden\"){");
                        sb.AppendLine("data.id = $('#" + filteredControlIds[j] + "').prop('id');");
                        sb.AppendLine("data.text = $('#" + filteredControlIds[j] + "').val();");
                        sb.AppendLine("idfFilteredData = data");
                        sb.AppendLine("}");
                        sb.AppendLine("else if(controlType == \"checkbox\"){");
                        sb.AppendLine("data.id = $('#" + filteredControlIds[j] + "').prop('id');");
                        sb.AppendLine("data.text =  $('#" + filteredControlIds[j] + "').is(':checked');");
                        sb.AppendLine("idfFilteredData = data");
                        sb.AppendLine("}");
                        sb.AppendLine("else if( controlType == \"radio\"){");
                        sb.AppendLine("data.id = $('#" + filteredControlIds[j] + "').prop('id');");
                        sb.AppendLine("data.text =  $('input[name=\"" + filteredControlIds[j] + "\"]:checked').val();");
                        sb.AppendLine("idfFilteredData = data");
                        sb.AppendLine("}");
                        sb.AppendLine("else if( controlType == \"number\"){");
                        sb.AppendLine("data.id = $('#" + filteredControlIds[j] + "').prop('id');");
                        sb.AppendLine("data.text = $('#" + filteredControlIds[j] + "').val();");
                        sb.AppendLine("idfFilteredData  =" + filteredControlIds[j] + "data");
                        sb.AppendLine("}");
                        sb.AppendLine("else if (controlType == \"select-one\"){");
                        sb.AppendLine("var select2Data= $('#" + filteredControlIds[j] + "').select2('data');");
                        sb.AppendLine("if (select2Data.length > 0){");
                        sb.AppendLine("idfFilteredData =select2Data[0]");
                        sb.AppendLine("}");
                        sb.AppendLine("else if (controlType == \"select-multiple\"){");
                        sb.AppendLine("select2Data= $('#" + filteredControlIds[j] + "').select2('data');");
                        sb.AppendLine("if (select2Data.length > 0){");
                        sb.AppendLine("idfFilteredData = select2Data");
                        sb.AppendLine("};");
                        sb.AppendLine("};");
                        sb.AppendLine("};");
                        sb.AppendLine("return idfFilteredData; ");
                        sb.AppendLine("};");

                    }
                }
            }
            sb.AppendLine("};");
            return sb.ToString();
        }
        /// <summary>
        ///GENERATE SELECT 2 DROPDOWN
        /// </summary>
        /// <returns></returns>
        private string GenerateJSSelect2DropDowns()
        {
            string idfFilteredData = string.Empty;
            StringBuilder sb = new StringBuilder();
            UriBuilder uriBuilder = new UriBuilder();
            sb.AppendLine("var  out_idfFilteredData = \"\";");
            sb.AppendLine("//Instantiate Select 2 Library on DropDown");
            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {
                var _controlType = _eIDSSModalConfiguration.ControlNames[i].ControlType;
                string colClass = string.Empty;
                switch (_controlType)
                {
                    case ControlType.DropDown:
                         colClass = this.ModalId + "eidssSelect2DropDown" + i.ToString();
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ClassName))
                        {
                            colClass = _eIDSSModalConfiguration.ControlNames[i].ClassName;
                        }

                        //FILTERING --REMOVE REDUNDANCY
                        if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("var data ='" + Newtonsoft.Json.JsonConvert.SerializeObject(_eIDSSModalConfiguration.ControlNames[i].FilteredData) + "'");
                            // sb.AppendLine("console.log(data);");
                        }
                        else if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("out_idfFilteredData = "  + this.ModalId + "SetFilteredData();");
                            //sb.AppendLine("var idfFilteredData = $('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').select2('data')[0];");
                        }

                        
                        sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i + "').select2({");
                        sb.AppendLine("ajax: {");
                        sb.AppendLine("url:" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlAjaxDataUrl,");
                        sb.AppendLine("data: function (params) {");
                        sb.AppendLine("var query = {");

                        //FILTERING
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("data: JSON.stringify(out_idfFilteredData),");
                        }
                        else if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("data ,");
                        }


                        sb.AppendLine(" term: params.term, page: params.page || 1");
                        sb.AppendLine("}");
                        sb.AppendLine("return query");
                        sb.AppendLine("}");
                        sb.AppendLine("},");
                        sb.AppendLine("width: '400',");
                        sb.AppendLine("tags:" + _eIDSSModalConfiguration.ControlNames[i].AllowTags.ToString().ToLower() + ", ");
                        sb.AppendLine("closeOnSelect: true,");
                        sb.AppendLine("allowClear: true,");
                        sb.AppendLine("multiple:" + _eIDSSModalConfiguration.ControlNames[i].AllowMultipleDropDownItemSelection.ToString().ToLower() + ", ");
                        sb.AppendLine("placeholder: ' '");
                        sb.AppendLine("});");

                        //On Change Event of Filtering Control We Use It's Data
                        //if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        //{
                        //    sb.AppendLine("$('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').on('select2:select', function(e) {");
                        //    sb.AppendLine("out_idfFilteredData =  e.params.data;");
                        //    sb.AppendLine(" });");
                        //}

                        //OnChange Event Of DropDown
                        sb.AppendLine("$('." + colClass + "').on('select2:opening', function(e) {");
                        
                        sb.AppendLine("out_idfFilteredData = " + this.ModalId + "SetFilteredData(); ");

                        sb.AppendLine("});");
                        break;
                    case ControlType.DropDownAddButtonOpenModal:
                         colClass = this.ModalId + "eidssSelect2DropDown" + i.ToString();
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ClassName))
                        {
                            colClass = _eIDSSModalConfiguration.ControlNames[i].ClassName;
                        }

                        if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("var data ='" + Newtonsoft.Json.JsonConvert.SerializeObject(_eIDSSModalConfiguration.ControlNames[i].FilteredData) + "'");
                            // sb.AppendLine("console.log(data);");
                        }
                        else if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("out_idfFilteredData = " + this.ModalId + "SetFilteredData();");
                            //sb.AppendLine("var idfFilteredData = $('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').select2('data')[0];");
                        }

                        sb.AppendLine("$('." + colClass + "').select2({");
                        sb.AppendLine("ajax: {");
                        sb.AppendLine("url:" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlAjaxDataUrl,");
                        sb.AppendLine("data: function (params) {");
                        sb.AppendLine("var query = {");

                        //FILTERING
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("data: JSON.stringify(out_idfFilteredData),");
                        }
                        else if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("data ,");
                        }


                        sb.AppendLine(" term: params.term, page: params.page || 1");
                        sb.AppendLine("}");
                        sb.AppendLine("return query");
                        sb.AppendLine("}");
                        sb.AppendLine("},");
                        sb.AppendLine("width: '400',");
                        sb.AppendLine("tags:" + _eIDSSModalConfiguration.ControlNames[i].AllowTags.ToString().ToLower() + ", ");
                        sb.AppendLine("closeOnSelect: true,");
                        sb.AppendLine("allowClear: true,");
                        sb.AppendLine("multiple:" + _eIDSSModalConfiguration.ControlNames[i].AllowMultipleDropDownItemSelection.ToString().ToLower() + ", ");
                        sb.AppendLine("placeholder: ' '");
                        sb.AppendLine("});");
                        //On Change Event of Filtering Control We Use It's Data
                        //if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        //{
                        //    sb.AppendLine("$('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').on('select2:select', function(e) {");
                        //    sb.AppendLine("out_idfFilteredData =  e.params.data;");
                        //    sb.AppendLine(" });");
                        //}

                        //OnChange Event Of DropDown
                        sb.AppendLine("$('." + colClass + "').on('select2:opening', function(e) {");
                       
                        sb.AppendLine("out_idfFilteredData = " + this.ModalId + "SetFilteredData(); ");
                        sb.AppendLine("});");
                        break;
                    case ControlType.DropDownAddButtonURL:
                         colClass = this.ModalId + "eidssSelect2DropDown" + i.ToString();
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].ClassName))
                        {
                            colClass = _eIDSSModalConfiguration.ControlNames[i].ClassName;
                        }


                        //FILTERING
                        if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("var data ='" + Newtonsoft.Json.JsonConvert.SerializeObject(_eIDSSModalConfiguration.ControlNames[i].FilteredData) + "'");
                            // sb.AppendLine("console.log(data);");
                        }
                        else if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("out_idfFilteredData = " + this.ModalId + "SetFilteredData();");
                            //sb.AppendLine("var idfFilteredData = $('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').select2('data')[0];");
                        }

                        sb.AppendLine("$('." + colClass + "').select2({");
                        sb.AppendLine("ajax: {");
                        sb.AppendLine("url:" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlAjaxDataUrl,");
                        sb.AppendLine("data: function (params) {");
                        sb.AppendLine("var query = {");

                        //FILTERING
                        if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        {
                            sb.AppendLine("data: JSON.stringify(out_idfFilteredData),");
                        }
                        else if (_eIDSSModalConfiguration.ControlNames[i].FilteredData != null)
                        {
                            sb.AppendLine("data ,");
                        }

                        sb.AppendLine(" term: params.term, page: params.page || 1");
                        sb.AppendLine("}");
                        sb.AppendLine("return query");
                        sb.AppendLine("}");
                        sb.AppendLine("},");
                        sb.AppendLine("width: '400',");
                        sb.AppendLine("tags:" + _eIDSSModalConfiguration.ControlNames[i].AllowTags.ToString().ToLower() + ", ");
                        sb.AppendLine("closeOnSelect: true,");
                        sb.AppendLine("allowClear: true,");
                        sb.AppendLine("multiple:" + _eIDSSModalConfiguration.ControlNames[i].AllowMultipleDropDownItemSelection.ToString().ToLower() + ", ");
                        sb.AppendLine("placeholder: ' '");
                        sb.AppendLine("});");
                        //On Change Event of Filtering Control We Use It's Data
                        //if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.ControlNames[i].FilteredControlId))
                        //{
                        //    sb.AppendLine("$('." + _eIDSSModalConfiguration.ControlNames[i].FilteredControlId + "').on('select2:select', function(e) {");
                        //    sb.AppendLine("out_idfFilteredData =  e.params.data;");
                        //    sb.AppendLine(" });");
                        //}

                        //OnChange Event Of DropDown
                        sb.AppendLine("$('." + colClass + "').on('select2:opening', function(e) {");

                        sb.AppendLine("out_idfFilteredData = " + this.ModalId + "SetFilteredData(); ");

                        sb.AppendLine("});");
                        break;
                    default:
                        break;
                }


              

            }


            return sb.ToString();
        }

        private string GenerateAddButtonAjaxCall()
        {

            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {

                if (_eIDSSModalConfiguration.ControlNames[i].ControlType ==  ControlType.DropDownAddButtonURL)
                {
                    sb.AppendLine("function " + _eIDSSModalConfiguration.ControlNames[i].ClassName + this.ModalId + "AddButtonClick()");
                    sb.AppendLine("{");
                    //SEND DATA TO ENPOINT
                    sb.AppendLine("var " + this.ModalId + "ctrlAdd_" + i + " = $('#" + this.ModalId + "ctrlAdd_" + i + "').select2('data')[0];");
                    sb.AppendLine("$.ajax({url:'" + _eIDSSModalConfiguration.ControlNames[i].AddButtonAjaxUrl + "', type: 'POST' , dataType: 'JSON', data:  JSON.stringify(" + this.ModalId + "ctrlAdd_" + i + ") ,    contentType: 'application/json; charset=utf-8' })");
                    sb.AppendLine(".done(function() { ");


                    sb.AppendLine("});");

                    //END JS FUNCTION
                    sb.AppendLine("}");
                }
                else if (_eIDSSModalConfiguration.ControlNames[i].ControlType == ControlType.DropDownAddButtonOpenModal)
                {
                    sb.AppendLine("function " + _eIDSSModalConfiguration.ControlNames[i].ClassName + this.ModalId + "OpenModalClick()");
                    sb.AppendLine("{");

                    //OPEN MODAL
                    sb.AppendLine("$(\"#" + _eIDSSModalConfiguration.ControlNames[i].OpenModalName + "\").modal({ backdrop: 'static', keyboard: false })");
                    sb.AppendLine("$(\"#" + _eIDSSModalConfiguration.ControlNames[i].OpenModalName + "\").modal(\'show\');");

                    //END JS FUNCTION
                    sb.AppendLine("}");
                }
            }

            return sb.ToString();
        }
        /// <summary>
        /// Iterate through DOM to find Objects and thier value
        /// Builds an object to send to server
        /// </summary>
        /// <returns></returns>
        private string GenerateModalSave()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function " + this.ModalId + "MODALAJAXPOST()");
            sb.AppendLine("{");

            sb.AppendLine("$(\"[id$='-error']\").remove();");

            sb.AppendLine(this.ModalId + "validator.form();");

            sb.AppendLine("$(\"[id$='-error']\").addClass(\"text-danger\");");

            //Move validation messages to the right, for Select2 objects.
            //Also check for the "Add/Plus" control that may be after the dropdown
            sb.AppendLine("$(\"select.error\").each(function(i, j){");
            sb.AppendLine("$(\"#\" + j.id + \"-error\").next().after($(\"#\" + j.id + \"-error\"));");
            
            sb.AppendLine("if($(\"#\" + j.id + \"-error\").next().hasClass(\"input-group-append\")) {");
            sb.AppendLine("$(\"#\" + j.id + \"-error\").next().after($(\"#\" + j.id + \"-error\"));");
            sb.AppendLine("}");
            sb.AppendLine("});");

            //Check Validations
            // sb.AppendLine("alert(" + this.ModalId + "numOfInvalids);");
            sb.AppendLine("if(" + this.ModalId + "numOfInvalids < 1){");

            sb.AppendLine("var modalpostObj ={};");
            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {
                sb.AppendLine("if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').get(0) != undefined ){");

                sb.AppendLine("if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"text\"){");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName] = $('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val();");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"hidden\"){");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName] = $('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val();");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"number\"){");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName] = $('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val();");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"radio\"){");
                sb.AppendLine("var radioValuesArray =[];");
                sb.AppendLine("var radioValues ={};");
                sb.AppendLine(" $.each($(\"input[name =\'" + this.ModalId + "ctrlAdd_" + i.ToString() + "\']:checked\"), function() {");
                sb.AppendLine("radioValues.Value =$(this).val();");
                sb.AppendLine("radioValuesArray.push(radioValues);");
                sb.AppendLine("});");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName] = radioValuesArray;");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"checkbox\"){");
                sb.AppendLine("var checkboxValuesArray =[];");
                sb.AppendLine(" $.each($(\"input[name =\'" + this.ModalId + "ctrlAdd_" + i.ToString() + "\']:checked\"), function() {");
                sb.AppendLine("var checkboxValues ={};");
                sb.AppendLine("checkboxValues.Value =$(this).is(\":checked\");");
                sb.AppendLine("checkboxValuesArray.push(checkboxValues);");
                sb.AppendLine("});");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName] = checkboxValuesArray;");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type') == \"select-one\"){");
                sb.AppendLine("var " + this.ModalId + "select2Data= $('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').select2('data');");
                sb.AppendLine("if (" + this.ModalId + "select2Data.length > 0){");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName ] = " + this.ModalId + "select2Data;}");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type') == \"select-multiple\"){");
                sb.AppendLine("var " + this.ModalId + "select2Data= $('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').select2('data');");
                sb.AppendLine("if (" + this.ModalId + "select2Data.length > 0){");
                sb.AppendLine("modalpostObj[" + this.ModalId + "modalJSObject.ControlNames[" + i + "].ControlName ] =  " + this.ModalId + "select2Data;}");
                sb.AppendLine("};");

                sb.AppendLine("};");
            }
            if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.SavingControlsCollection))
            {
                string[] controlsCollection = _eIDSSModalConfiguration.SavingControlsCollection.Split(',');
                for (int i = 0; i < controlsCollection.Length; i++)
                {
                    sb.AppendLine("if($('#" + controlsCollection[i] + "').get(0) != undefined ){");
                    //START IF

                    sb.AppendLine(" var controlType = $('#" + controlsCollection[i] + "').prop('type'); ");

                    sb.AppendLine("if( controlType == \"text\" || controlType == \"number\"){");
                    sb.AppendLine("modalpostObj['" + controlsCollection[i] + "'] = $('#" + controlsCollection[i] + "').val();");
                    sb.AppendLine("}");
                    sb.AppendLine("else if(controlType == \"select-one\"  || controlType == \"select-multiple\"){");
                    sb.AppendLine("var " + this.ModalId + "select2Data= $('#" + controlsCollection[i] + "').select2('data');");
                    sb.AppendLine("if (" + this.ModalId + "select2Data.length > 0)");
                    sb.AppendLine("modalpostObj['" + controlsCollection[i] + "'] =  " + this.ModalId + "select2Data;");
                    sb.AppendLine("};");
                    sb.AppendLine("if( controlType == \"radio\"){");
                    sb.AppendLine("modalpostObj['" + controlsCollection[i] + "'] =  $('input[name=\"" + controlsCollection[i] + "\"]:checked').val();");
                    sb.AppendLine("}");

                    //END IF
                    sb.AppendLine("};");
                }
                // sb.AppendLine("console.log(modalpostObj)");
            }
            
            sb.AppendLine("localStorage.setItem('" + this.ModalId + "',JSON.stringify(modalpostObj));");//PLACE IN LOCAL STORAGE IN CASE THE DATA NEEDS TO BE REFERENCED
            sb.AppendLine("$.ajax({url: '" + this.AjaxSaveUrl + "' , type: 'POST' , dataType: 'JSON', data:  JSON.stringify(modalpostObj) ,    contentType: 'application/json; charset=utf-8' })");
            sb.AppendLine(".done(function(data) { ");
            sb.AppendLine(this.ModalId + "refreshTarget();");
            sb.AppendLine(this.ModalId + "MODALRESET();");
            sb.AppendLine("$('#" + this.ModalId + "').modal('hide');");

            if (!String.IsNullOrEmpty(_eIDSSModalConfiguration.SaveCompleteMethod))//Javascript method defined in VIEW
            {
                sb.AppendLine(_eIDSSModalConfiguration.SaveCompleteMethod + "(data);");
            }
            else
            {
  
                sb.AppendLine("$('#" + this.ModalId + "SuccessModal').modal({ backdrop: 'static', keyboard: false })");

                sb.AppendLine("$('#" + this.ModalId + "SuccessModal').modal('show');");
                
            }            
            
            sb.AppendLine("})");
            ////End Validation Check
            sb.AppendLine("}");
            //END JS FUNCTION
            sb.AppendLine(this.ModalId + "numOfInvalids =0;");
            sb.AppendLine("}");

            //Create the reset function, to be used from multiple locations
            sb.AppendLine("function " + this.ModalId + "MODALRESET() {");
            sb.AppendLine("$(\"[id$='-error']\").remove();"); //clear all validation messages

            //Reset Controls
            for (int i = 0; i < _eIDSSModalConfiguration.ControlNames.Count; i++)
            {
                sb.AppendLine("if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').get(0) != undefined ){");

                sb.AppendLine("if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"text\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val(\"\");");
                sb.AppendLine("}");

                sb.AppendLine("if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"number\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val(\"\");");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"radio\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop(\"checked\",false);");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type')  == \"checkbox\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop(\"checked\",false);");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type') == \"select-one\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val(null).trigger('change');");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').prop('type') == \"select-multiple\"){");
                sb.AppendLine("$('#" + this.ModalId + "ctrlAdd_" + i.ToString() + "').val(null).trigger('change');");
                sb.AppendLine("};");

                sb.AppendLine("};");
            }
            //sb.AppendLine("$('#" + this.ModalId + "ModalForm').model.('hide');");
            sb.AppendLine("$('#" + this.ModalId + "').modal('hide');");

            sb.AppendLine("}");

            return sb.ToString();
        }


        //Control to Refresh After Modal Updates
        public string RefreshTarget()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function " + this.ModalId + "refreshTarget(){");
            if (this._eIDSSModalConfiguration.TargetGridControlID != null)
            {

                sb.AppendLine("if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').get(0) != undefined ){");

                sb.AppendLine("if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type')  == \"text\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').val(\"\");");
                sb.AppendLine("}");

                sb.AppendLine("if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type')  == \"number\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').val(\"\");");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type')  == \"radio\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop(\"checked\",false);");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type')  == \"checkbox\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop(\"checked\",false);");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type') == \"select-one\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').val(null).trigger('change');");
                sb.AppendLine("}");

                sb.AppendLine("else if($('#" + _eIDSSModalConfiguration.TargetGridControlID + "').prop('type') == \"select-multiple\"){");
                sb.AppendLine("$('#" + _eIDSSModalConfiguration.TargetGridControlID + "').val(null).trigger('change');");
                sb.AppendLine("};");


                sb.AppendLine("};");


                sb.AppendLine("var " + this.ModalId + "dt = $('#" + this._eIDSSModalConfiguration.TargetGridControlID + "').DataTable();");
                sb.AppendLine("if(" + this.ModalId + "dt != undefined){");
                sb.AppendLine(this.ModalId + "dt.ajax.reload();}");
            }
            sb.AppendLine("}");
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
            for (int c = 0; c < _eIDSSModalConfiguration.ControlNames.Count(); c++)
            {
                //if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting != null)
                //{
                //    sb.AppendLine("jQuery.validator.messages = { required: '" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidatorMessage + "'};");
                //}

                if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting != null)
                {
                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.REQUIRED)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");
                    }

                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("range:" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("});");
                    }

                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("required: true,");
                        sb.AppendLine("range:" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("});");
                    }




                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.CHARACTERRANGE)
                    {
                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("rangelength:" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("});");
                    }
                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.DATECOMPARE_2_FIELDS)
                    {

                        sb.AppendLine("jQuery.validator.addMethod(\""+ this.ModalId + "dateEval2\", function(value, element) {");
                        sb.AppendLine("var " + this.ModalId + "validation_Rule =" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule);
                        sb.AppendLine("var " + this.ModalId + "ctrlArray = " + this.ModalId + "validation_Rule;");
                        //sb.AppendLine("alert( ctrlArray[0])");
                        sb.AppendLine(" var " + this.ModalId + "ctrl_1 = $(\".\" + " + this.ModalId + "ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ModalId + "ctrl_2 = $(\".\" + " + this.ModalId + "ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ModalId + "dateEval2(value," + this.ModalId + "ctrl_1," + this.ModalId + "ctrl_2 );");
                        sb.AppendLine("}, \"Date Range\");");
                    }

                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_LOWER_RANGE)
                    {


                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");


                        //Make sure that lower value is not greater than upper value
                        sb.AppendLine("jQuery.validator.addMethod(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", function(value, element) {");
                        sb.AppendLine("var validation_Rule = " + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var ctrlArray = validation_Rule;");
                        // sb.AppendLine("alert(ctrlArray[0])");
                        sb.AppendLine("var " + this.ModalId + "ctrl_1 = $(\".\" + ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ModalId + "ctrl_2 = $(\".\" + ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ModalId + "lowerRangeCustomEval(value," + this.ModalId + "ctrl_1," + this.ModalId + "ctrl_2 );");
                        sb.AppendLine("}, \"" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.RangeValidationMessage + "\");");
                    }


                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.RANGE_AND_REQUIRED_COMPARE_UPPER_RANGE)
                    {


                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("required: true");
                        sb.AppendLine("});");


                        //Make sure that lower value is not greater than upper value
                        sb.AppendLine("jQuery.validator.addMethod(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", function(value, element) {");
                        sb.AppendLine("var validation_Rule = " + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var ctrlArray = validation_Rule;");

                        sb.AppendLine("var " + this.ModalId + "ctrl_1 = $(\".\" + ctrlArray[0].toString()).val();");
                        sb.AppendLine("var " + this.ModalId + "ctrl_2 = $(\".\" + ctrlArray[1].toString()).val();");
                        sb.AppendLine("return " + this.ModalId + "upperRangeCustomEval(value," + this.ModalId + "ctrl_1," + this.ModalId + "ctrl_2 );");
                        sb.AppendLine("}, \"" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.RangeValidationMessage + "\");");
                    }
                    
                    
                    if (_eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRuleTypes == VaildationRuleType.ValidationRuleType.PHONE)
                    {



                        sb.AppendLine("jQuery.validator.addClassRules(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", {");
                        sb.AppendLine("required: false");
                        sb.AppendLine("});");




                        //Make sure that lower value is not greater than upper value
                        sb.AppendLine("var message='';");
                        sb.AppendLine("jQuery.validator.addMethod(\"" + _eIDSSModalConfiguration.ControlNames[c].ClassName.Replace("form-control ", "") + "\", function(element) {");
                        sb.AppendLine("var validation_Rule = " + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.ValidationRule + ";");
                        sb.AppendLine("var ctrlArray = validation_Rule;");
                        sb.AppendLine("var elemPhone=" + this.ModalId + "d1 =  $(\".\" + \"Phone\");");

                        sb.AppendLine("var result= " + this.ModalId + "phoneCustomVal(elemPhone, validation_Rule);");
                        sb.AppendLine("if(result==false){");
                        sb.AppendLine("if(elemPhone.val() != null && elemPhone.val() != ''){");
                        sb.AppendLine("message= \"" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.PhoneValidationMessage + "\";");
                        sb.AppendLine("elemPhone.data('msg-phone',message)");
                        sb.AppendLine("}");                     
                        sb.AppendLine("}");
                        sb.AppendLine("else{");
                        sb.AppendLine("debugger;");
                        sb.AppendLine("elemPhone.data('msg-phone','')");
                        sb.AppendLine("elemPhone.removeClass('error')");
                        sb.AppendLine("elemPhone.addClass('valid')");
                        sb.AppendLine("}");

                        //sb.AppendLine("return " + this.ModalId + "phoneCustomVal(" + this.ModalId + "d1,validation_Rule);");
                        //sb.AppendLine("debugger;");
                        //sb.AppendLine("if(" + this.ModalId + "d1.val() !=null &&" + this.ModalId + "d1.val() != ''){");
                        //sb.AppendLine("message= \"" + _eIDSSModalConfiguration.ControlNames[c].ValidationSetting.PhoneValidationMessage + "\";");
                        //sb.AppendLine("$('#"+this.ModalId + "d1').attr('data-msg-phone',message)");
                        //sb.AppendLine("}");
                        sb.AppendLine("},message)");
                        
                    }

                    
                }
            }

            return sb.ToString();
        }

        public string BuildValidationFunctions()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("var " + this.ModalId + "dateEval2 = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ModalId + "date1 = " + this.ModalId + "ctr1");
            sb.AppendLine("var " + this.ModalId + "date2 = " + this.ModalId + "ctr2;");

            sb.AppendLine("var " + this.ModalId + "d1 = new Date(" + this.ModalId + "date1);");
            sb.AppendLine("var " + this.ModalId + "d2 = new Date(" + this.ModalId + "date2);");
            sb.AppendLine("var " + this.ModalId + "same = " + this.ModalId + "d1.getTime() < " + this.ModalId + "d2.getTime();");
            sb.AppendLine("return " + this.ModalId + "same;");
            sb.AppendLine("}");



            //DropDown is Required
            sb.AppendLine("var " + this.ModalId + "dropDownReq = function(element) {");
            sb.AppendLine("var " + this.ModalId + "d1 =  $(\".\" + element).select2('data');");
            sb.AppendLine("var " + this.ModalId + "same = " + this.ModalId + "d1.length < 0");
            sb.AppendLine("return " + this.ModalId + "same;");
            sb.AppendLine("};");

            //lower value is not greater than upper value
            sb.AppendLine("var " + this.ModalId + "lowerRangeCustomEval = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ModalId + "_ctr1 = ctr1;");
            sb.AppendLine("var " + this.ModalId + "_ctr2 = ctr2;");
            sb.AppendLine("var " + this.ModalId + "lowerRangeIsNotGreaterThanUpper = ((" + this.ModalId + "_ctr2 > " + this.ModalId + "_ctr1) & (" + this.ModalId + "_ctr1  >= 0)) & (" + this.ModalId + "_ctr1  <= 2147483647);");
            sb.AppendLine("return " + this.ModalId + "lowerRangeIsNotGreaterThanUpper;");
            sb.AppendLine("};");




            //Upper value is not less than lower value
            sb.AppendLine("var " + this.ModalId + "upperRangeCustomEval = function(value,ctr1,ctr2) {");
            sb.AppendLine("var " + this.ModalId + "_ctr1 = ctr1;");
            sb.AppendLine("var " + this.ModalId + "_ctr2 = ctr2;");
            sb.AppendLine("var " + this.ModalId + "upperRangeIsNotLowerThanLower = ((" + this.ModalId + "_ctr1 < " + this.ModalId + "_ctr2) & (" + this.ModalId + "_ctr2  >= 0 )) & (" + this.ModalId + "_ctr2  <= 2147483647) ;");
            sb.AppendLine("return " + this.ModalId + "upperRangeIsNotLowerThanLower;");
            sb.AppendLine("};");

            //DropDown is Required
            sb.AppendLine("var " + this.ModalId + "phoneCustomVal = function(element,rule) {");
            sb.AppendLine("var " + this.ModalId + "d1 =  $(element).val();");
            //sb.AppendLine("var filter = /^[0-9]{8,15}$/;");
            sb.AppendLine("var result=false;");
            sb.AppendLine("if(rule.test(" + this.ModalId + "d1)){");
            sb.AppendLine("result=true;");
            sb.AppendLine("};");
            sb.AppendLine("return result;");
            sb.AppendLine("};");
            

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

    }
}
