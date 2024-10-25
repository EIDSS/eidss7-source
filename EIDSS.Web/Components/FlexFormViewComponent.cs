using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.Enumerations;
using System;
using System.IO;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Linq;
using Microsoft.Net.Http.Headers;
using Microsoft.Extensions.FileSystemGlobbing.Internal;
using EIDSS.Web.Components.FlexForm;
using EIDSS.Web.Extensions;
using static System.Collections.Specialized.BitVector32;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "FlexFormView")]
    public class FlexFormViewComponent : ViewComponent
    {
        private FlexFormQuestionnaireViewModel _flexFormQuestionnaireViewModel;
        private readonly IFlexFormClient _flexFormClient;

        private string LanguageID { get; set; }

        private class Section
        {
            public long idfsSection { get; set; }
            public bool blnGrid { get; set; }
        }

        public FlexFormViewComponent(IFlexFormClient flexFormClient)
        {
            _flexFormClient = flexFormClient;
        }

        public async Task<IViewComponentResult> InvokeAsync(FlexFormQuestionnaireGetRequestModel request)
        {
            _flexFormQuestionnaireViewModel = new FlexFormQuestionnaireViewModel();

            await DiplayQuestionnaire(request);

            return View(_flexFormQuestionnaireViewModel);
        }

        private async Task DiplayQuestionnaire(FlexFormQuestionnaireGetRequestModel request)
        {
            try
            {
                string strTitle = "";//TODO: Remove Title//""<h6>" + request.Title + "</h6>";
                string strFlexFormSectionHTML = string.Empty;
                string strFlexFormParameterHTML = string.Empty;
                string strGridHeaderRow = string.Empty;
                Section SectionItem = new Section();
                long? idfsSection = null;
                long? idfsFormTemplate = null;
                string strObservationIdentity = string.Empty;
                long? idfRow = 0;

                List<Section> sections = new List<Section>();
                List<FlexFormQuestionnaireResponseModel> flexForm = await _flexFormClient.GetQuestionnaire(request);

                List<FlexFormActivityParametersListResponseModel> answers = new List<FlexFormActivityParametersListResponseModel>();
                List<long> gridRows;

                LanguageID = request.LangID;

                if (flexForm.Count > 0)
                    idfsFormTemplate = flexForm[0].idfsFormTemplate;

                if (request.idfObservation != null)
                {
                    var answersRequest = new FlexFormActivityParametersGetRequestModel
                    {
                        observationList = request.idfObservation.ToString(),
                        LangID = request.LangID
                    };

                    answers = await _flexFormClient.GetAnswers(answersRequest);
                }

                //Iterate through to create section containers
                foreach (var item in flexForm)
                {
                    if (item.idfsSection == item.idfsParameter)
                    {
                        SectionItem = new Section
                        {
                            blnGrid = item.blnGrid ?? false,
                            idfsSection = (item.idfsSection ?? 0) == 0
                                ? item.idfsParameter
                                : item.idfsSection ?? 0
                        };
                        sections.Add(SectionItem);

                        //First-level or embedded section
                        if (item.idfsSection != 0)
                        {
                            strFlexFormSectionHTML += "<legend>" + item.SectionName + "</legend>";

                            //First-level section only
                            if ((item.idfsParentSection == null))
                            {
                                strFlexFormSectionHTML += "<div class=\"card-header\"><h6 title></h6></div>";
                            }
                        }
                    }

                    //Table item (header, sub-header or column (parameter)) (TODO: implement sub-header) 
                    if (item.blnGrid.HasValue && item.blnGrid.Value)
                    {
                        //Table Section
                        if (item.idfsSection == item.idfsParameter)
                        {
                            //TODO: temporary ignore sub-headers
                            var isSubHeader = false;
                            if (item.idfsParentSection != null && sections is { Count: > 0 })
                            {
                                var parentSectionItem = sections.Where(x => x != null && x.idfsSection == item.idfsParentSection).ToList().FirstOrDefault();
                                if (parentSectionItem is { blnGrid: true })
                                    isSubHeader = true;
                            }

                            if (!isSubHeader)
                            {
                                strFlexFormSectionHTML += "<div id='" + item.idfsSection + "' style='margin-left:-10px;border: solid 0px black'>[" + item.idfsSection + "]</div>";
                                strGridHeaderRow = "<table><tr>";

                                if (request.MatrixColumns == null)
                                {
                                    request.MatrixColumns = new List<string>();
                                    request.MatrixData = new List<FlexFormMatrixData>();
                                }

                                foreach (string matrixColumn in request.MatrixColumns)
                                {
                                    strGridHeaderRow += "<td>" + matrixColumn + "</td>";
                                }

                                gridRows = new List<long>();
                                //Iterate through to determine columns and their headers in the table section
                                foreach (FlexFormQuestionnaireResponseModel tableItem in flexForm)
                                {
                                    if (tableItem.idfsSection == item.idfsSection && tableItem.idfsParameter != item.idfsSection && tableItem.idfsEditor != null)
                                    {
                                        strGridHeaderRow += "<td style='padding-right:15px'>" + tableItem.ParameterName + "</td>";

                                        if (answers.Count > 0)
                                        {
                                            //Iterate through to determine rows in the table section from answers
                                            foreach (FlexFormActivityParametersListResponseModel answer in answers.Where(x =>
                                                         x.idfsParameter == tableItem.idfsParameter && x.idfRow.HasValue &&
                                                         !gridRows.Contains(x.idfRow.Value)).ToList())
                                            {
                                                gridRows.Add(answer.idfRow.Value);
                                            }
                                        }
                                    }
                                }

                                strGridHeaderRow += "</tr>";

                                if (answers.Count == 0)
                                {
                                    //Empty table row if no answers exist
                                    strFlexFormParameterHTML = "<tr>";
                                    foreach (FlexFormQuestionnaireResponseModel tableItem in flexForm.Where(x => x.idfsSection == item.idfsSection && x.idfsParameter != item.idfsSection && x.idfsEditor != null).ToList())
                                    {
                                        strFlexFormParameterHTML += ControlHTML(answers, tableItem.idfsEditor, tableItem.idfsParameterType, tableItem.idfsParameter, tableItem.ParameterName, true, 0, false, request.IsFormDisabled);
                                    }
                                    //TODO: Add and implement DeleteRow button
                                    strFlexFormParameterHTML += "    <td colspan=\"@iColumns\">";
                                    strFlexFormParameterHTML += "        <button onclick=\"copyParameter(0)\" class=\"btn btn-link\" id=\"strCopyId\" name=\"strCopyId\" type=\"button\">";
                                    strFlexFormParameterHTML += "            <span class=\"fas fa-copy fa-lg\"></span>";
                                    strFlexFormParameterHTML += "        </button>";
                                    strFlexFormParameterHTML += "        <button @onclick=\"@(args => PasteRow(args, strPasteId))\" class=\"btn btn-link\" id=\"@strPasteId\" name=\"@strPasteId\" type=\"button\">";
                                    strFlexFormParameterHTML += "            <span class=\"fas fa-paste fa-lg\"></span>";
                                    strFlexFormParameterHTML += "        </button>";
                                    strFlexFormParameterHTML += "        <button @onclick=\"@(args => AddRow(args, strAddId))\" class=\"btn btn-link\" id=\"@strAddId\" name=\"@strAddId\" type=\"button\">";
                                    strFlexFormParameterHTML += "            <span class=\"fas fa-plus fa-lg\"></span>";
                                    strFlexFormParameterHTML += "        </button>";
                                    strFlexFormParameterHTML += "    </td>";
                                    strFlexFormParameterHTML += "</tr>";
                                }
                                else
                                {
                                    //Table rows where answers exist
                                    strFlexFormParameterHTML = "";
                                    foreach (long gridRow in gridRows)
                                    {
                                        idfRow = gridRow;
                                        foreach (FlexFormQuestionnaireResponseModel tableItem in flexForm.Where(x => x.idfsSection == item.idfsSection && x.idfsParameter != item.idfsSection && x.idfsEditor != null).ToList())
                                        {
                                            strFlexFormParameterHTML += "<tr>";
                                            strFlexFormParameterHTML += ControlHTML(answers, tableItem.idfsEditor, tableItem.idfsParameterType, tableItem.idfsParameter, tableItem.ParameterName, true, idfRow, false, request.IsFormDisabled);
                                            //TODO: Add and implement DeleteRow button
                                            strFlexFormParameterHTML += "    <td colspan=\"@iColumns\">";
                                            strFlexFormParameterHTML += "        <button onclick=\"copyParameter('" + idfRow + "');\" class=\"btn btn-link\" id=\"strCopyId\" name=\"strCopyId\" type=\"button\">";
                                            strFlexFormParameterHTML += "            <span class=\"fas fa-copy fa-lg\"></span>";
                                            strFlexFormParameterHTML += "        </button>";
                                            strFlexFormParameterHTML += "        <button @onclick=\"@(args => PasteRow(args, strPasteId))\" class=\"btn btn-link\" id=\"@strPasteId\" name=\"@strPasteId\" type=\"button\">";
                                            strFlexFormParameterHTML += "            <span class=\"fas fa-paste fa-lg\"></span>";
                                            strFlexFormParameterHTML += "        </button>";
                                            strFlexFormParameterHTML += "        <button @onclick=\"@(args => AddRow(args, strAddId))\" class=\"btn btn-link\" id=\"@strAddId\" name=\"@strAddId\" type=\"button\">";
                                            strFlexFormParameterHTML += "            <span class=\"fas fa-plus fa-lg\"></span>";
                                            strFlexFormParameterHTML += "        </button>";
                                            strFlexFormParameterHTML += "    </td>";
                                            strFlexFormParameterHTML += "</tr>";
                                        }
                                    }
                                }

                                strFlexFormSectionHTML = strFlexFormSectionHTML.Replace("[" + item.idfsSection + "]", strGridHeaderRow + strFlexFormParameterHTML + "</table>");

                            }
                        }
                    }
                    else if (item.idfsParameter != item.idfsSection)
                    {
                        //Create Parameter
                        if (item.idfsEditor != null)
                        {
                            strFlexFormSectionHTML += "<div style='margin-left:-10px;border: solid 0px black'>[" + item.idfsParameter + "]</div>";
                            bool bMandatory = item.idfsEditMode == (long?)FlexFormEditMode.Mandatory;
                            strFlexFormParameterHTML = "<div class='row' style='padding-top: 5px;padding-bottom: 5px'>" + 
                                                       ControlHTML(answers,
                                item.idfsEditor, item.idfsParameterType, item.idfsParameter, item.ParameterName, false, 0, bMandatory,
                                request.IsFormDisabled) + "</div>";
                            strFlexFormSectionHTML = strFlexFormSectionHTML.Replace("[" + item.idfsParameter + "]", strFlexFormParameterHTML);
                        } 
                        //Create Label
                        else if (!string.IsNullOrEmpty(item.DecoreElementText))
                        {
                            strFlexFormSectionHTML += "<legend>" + item.DecoreElementText + "</legend>";
                        }
                    }
                }


                strFlexFormSectionHTML += "<input type='hidden' id='idfCopyRow' />";
                strFlexFormSectionHTML += "<script type='text/javascript'>$(document).ready(function(){";
                strFlexFormSectionHTML += " function copyParameter(idfRow) {";
                strFlexFormSectionHTML += "     $('#idfCopyRow').val(idfRow);";
                strFlexFormSectionHTML += " }";
                strFlexFormSectionHTML += "});";
                strFlexFormSectionHTML += "</script>";


                List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>
                {
                    new KeyValuePair<string, string>("IDFSFORMTYPE", request.idfsFormType.ToString()),
                    new KeyValuePair<string, string>("IDFSFORMTEMPLATE",
                        string.IsNullOrEmpty(idfsFormTemplate.ToString()) ? "undefined" : idfsFormTemplate.ToString()),
                    new KeyValuePair<string, string>("IDFOBSERVATION", string.IsNullOrEmpty(request.idfObservation.ToString()) ? "undefined" : request.idfObservation.ToString()),
                    new KeyValuePair<string, string>("OBSERVATIONFIELDID", request.ObserationFieldID)
                };

                string strFunctionNameOnly = request.CallbackFunction.Replace("()", "").Replace(";", "");

                kvpReplacements.Add(new KeyValuePair<string, string>("CALLBACKFUNCTION", "if (typeof " + strFunctionNameOnly + " === \"function\") { " + request.CallbackFunction + " } else { " +
                    request.CallbackErrorFunction + " }"));

                _flexFormQuestionnaireViewModel.FlexFormScript = sbContent(getFlexFormAnswers(flexForm.Count == 0), kvpReplacements);
                if (flexForm.Count > 0)
                {
                    _flexFormQuestionnaireViewModel.QuestionnaireHTML = strTitle + "<div id='" + request.idfsFormType + "' flexform><input type='hidden' asp-for='" + request.ObserationFieldID + "' value='" + request.idfObservation + "'>" + strFlexFormSectionHTML + "</input></div>";
                }
            }
            catch (Exception e)
            {
            }
        }

        private string ControlHTML(List<FlexFormActivityParametersListResponseModel>? answers, long? idfsEditor, long? idfsParameterType, long idfsParameter, string strParameterName, bool blnGrid, long? idfRow, bool bMandatory, bool? bDisableControl = false)
        {
            try
            {
                string strLabelCSS = "class=''";
                //TODO: Redesign text-align:left for RTL languages
                string strContainerCSS = "class='col-lg-6 col-md-6 col-sm-6' style='text-align: left;'";
                string strControlCSS = "class='form-control'";
                string strControl = string.Empty;
                string strControlHTML = string.Empty;
                string strControlLabel = string.Empty;
                string strValue = string.Empty;
                long idfActivityParameters = 0;
                string strElementAttributes = string.Empty;

                if (!blnGrid)
                {
                    if (bMandatory)
                    {
                        //strLabelCSS = "class='fas fa-asterisk text-danger'";
                        strControlLabel = "<div " + strContainerCSS + "><span class='fas fa-asterisk text-danger'></span><span " + strLabelCSS + ">" + strParameterName + "</span></div>";
                    }
                    else
                    {
                        strControlLabel = "<div " + strContainerCSS + "><span style='list-style:disc;'></span><span " + strLabelCSS + ">" + strParameterName + "</span></div>";
                    }
                }

                switch (idfsEditor)
                {
                    case (long)FlexibleFormEditorTypeEnum.CheckBox:
                        strControlCSS = "";
                        break;
                }


                strElementAttributes = "id='" + idfsParameter + "' idfsEditor='" + idfsEditor + "' idfActivityParameters='[IDFACTIVITYPARAMETERS]'" + strControlCSS + " idfRow='[IDFROW]' value='[VALUE]' [DISABLED] parameter";

                if (answers != null)
                {
                    if (answers.Count > 0)
                    {
                        if (answers.Exists(x => x.idfsParameter == idfsParameter))
                        {
                            strValue = answers.First(x => x.idfsParameter == idfsParameter).varValue;
                            idfActivityParameters = answers.First(x => x.idfsParameter == idfsParameter).idfActivityParameters;
                            strElementAttributes = strElementAttributes.Replace("[IDFACTIVITYPARAMETERS]", idfActivityParameters.ToString());
                            if (idfsEditor is (long)FlexibleFormEditorTypeEnum.CheckBox)
                            {
                                strElementAttributes = strElementAttributes.Replace("[VALUE]", strValue) + $"{(strValue == "1" ? " checked" : "")}";
                            }
                            else
                            {
                                strElementAttributes = strElementAttributes.Replace("[VALUE]", strValue);
                            }
                        }
                    }
                }

                strElementAttributes = strElementAttributes.Replace("[IDFACTIVITYPARAMETERS]", "");
                strElementAttributes = strElementAttributes.Replace("[IDFROW]", idfRow.ToString());
                strElementAttributes = strElementAttributes.Replace("[VALUE]", "");

                if (bDisableControl != null && bDisableControl.Value)
                {
                    strElementAttributes = strElementAttributes.Replace("[DISABLED]", "disabled='disabled'");
                }
                else
                {
                    strElementAttributes = strElementAttributes.Replace("[DISABLED]", "");
                }

                switch (idfsEditor)
                {
                    case (long)FlexibleFormEditorTypeEnum.CheckBox:
                        var checkedAttribute = strValue == "1" ? "checked" : string.Empty;
                        strControl += "<input type='checkbox' [ATTRIBUTES] [REQUIRED] style='min-width: 30px;min-height: 30px;outline: none;'></input>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.DropDown:
                        string strOptions = string.Empty;

                        var request = new FlexFormParameterSelectListGetRequestModel
                        {
                            LangID = LanguageID,
                            idfsParameter = idfsParameter
                        };

                        List<FlexFormParameterSelectListResponseModel> options = _flexFormClient.GetDropDownOptionsList(request).Result;

                        //strOptions = "<option value='-1'></option>";
                        strOptions = "<option value='' selected></option>";

                        foreach (var option in options)
                        {
                            if (option.idfsValue.ToString() == strValue)
                            {
                                strOptions += "<option value='" + option.idfsValue + "' selected>" + option.strValueCaption + "</option>";
                            }
                            else
                            {
                                strOptions += "<option value='" + option.idfsValue + "'>" + option.strValueCaption + "</option>";
                            }
                        }

                        strControl += "<select [ATTRIBUTES] [REQUIRED]>" + strOptions + "</select>";
                        break;

                    case (long)FlexibleFormEditorTypeEnum.DatePicker:
                    case (long)FlexibleFormEditorTypeEnum.DateTimePicker:
                        if (!string.IsNullOrEmpty(strValue))
                        {
                            DateTime dt = DateTime.Parse(strValue);
                            strValue = dt.ToString(CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern);
                        }
                        strControl += "<input type='text' [ATTRIBUTES] [REQUIRED] style='position:relative;float:left;width:85%;max-width:220px'></input>";
                        strControl += "<script type='text/javascript'>$(document).ready(function(){$(\"#" + idfsParameter + "\").val(\"" + strValue + "\");";
                        strControl += "$('#" + idfsParameter + "').datepicker(";
                        strControl += " $.extend({";
                        strControl += " changeMonth: true,";
                        strControl += " changeYear: true,";
                        strControl += " showOn: \"both\",";
                        strControl += " yearRange: \"-122:+79\",";
                        strControl += " constrainInput: false,";
                        strControl += " buttonText: \"\",";
                        strControl += " beforeShow: function() {";
                        strControl += "     setTimeout(function(){";
                        strControl += "         $('.ui-datepicker').css('z-index', 9999);";
                        strControl += "     }, 0);";
                        strControl += " }";
                        strControl += "},";
                        strControl += "$.datepicker.regional[\"" + CultureInfo.CurrentCulture.TwoLetterISOLanguageName + "\"],";
                        strControl += " { dateFormat: '" + CultureInfo.CurrentCulture.DateTimeFormat.ToJavascriptShortDatePattern() + "'}";
                        strControl += " )).next('.ui-datepicker-trigger').addClass('flex-form-datepicker fas fa-calendar');";
                        strControl += "})";
                        strControl += "</script>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.TextArea:
                        strControl += "<input type='textarea' [ATTRIBUTES] [REQUIRED]></input>";
                        break;

                    case (long)FlexibleFormEditorTypeEnum.TextBox:
                        strControl += "<input type='text' [ATTRIBUTES] [REQUIRED] style='max-width: 250px;'></input>";
                        break;

                    case (long)FlexibleFormEditorTypeEnum.Numeric:
                        var numericInputTemplate = "<input type='number'{0} [ATTRIBUTES] [REQUIRED] style='max-width: 250px;'></input>";
                        strControl += idfsParameterType switch
                        {
                            (long)FlexibleFormParameterTypeEnum.NumericNatural => string.Format(numericInputTemplate,
                                " min='0' step='1'"),
                            (long)FlexibleFormParameterTypeEnum.NumericInteger => string.Format(numericInputTemplate,
                                " step='1'"),
                            (long)FlexibleFormParameterTypeEnum.NumericPositive => string.Format(numericInputTemplate,
                                " min='0'"),
                            _ => string.Format(numericInputTemplate, "")
                        };
                        break;

                    case (long)FlexibleFormEditorTypeEnum.Empty:
                        strControl += "";
                        break;

                    case (long)FlexibleFormEditorTypeEnum.RadioButtonList:
                        strControl += "<input type='radio' [ATTRIBUTES] [REQUIRED] style='max-width: 250px;'></input>";
                        break;

                    default:
                        string test = "";
                        break;
                }

                strControl = strControl.ToString().Replace("[ATTRIBUTES]", strElementAttributes);
                strControlHTML = strControlHTML.Replace("[IDFROW]", idfRow.ToString());

                if (!blnGrid)
                {
                    if(bMandatory)
                    {
                        strControl = strControl.Replace("[REQUIRED]", "name=\"" + idfsParameter.ToString() + "\" required data-val-datecomparer-compare=\"LessThanOrEqualTo\"");
                        //strControl += "<span class=\"text-danger field-validation-error\" data-valmsg-for=\"" + idfsParameter.ToString() + "\" data-valmsg-replace=\"true\"><span id=\"" + idfsParameter.ToString() + "-error\" class=\"\">This field is required.</span></span>";
                        strControl += "<span class=\"text-danger field-validation-error\" data-valmsg-for=\"" + idfsParameter.ToString() + "\" data-valmsg-replace=\"true\"><span id=\"" + idfsParameter.ToString() + "-error\" class=\"\"></span></span>";

                    }
                    else
                    {
                        strControl = strControl.Replace("[REQUIRED]", "");
                    }

                    strControlHTML = strControlLabel + "<div " + strContainerCSS + ">" + strControl + "</div>";
                }
                else
                {
                    strControlHTML += "<td>" + strControl + "</td>";
                }

                

                return strControlHTML;
            }
            catch (Exception e)
            {
                return "<td>" + e.Message + "</td>";
            }
        }

        private string sbFile(string strFileAndPath, List<KeyValuePair<string, string>> ldReplacements)
        {
            string strContent = string.Empty;

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

        private string sbContent(string strContent, List<KeyValuePair<string, string>> ldReplacements)
        {
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

        private string getFlexFormAnswers(bool bSkipAnswers)
        {
            string strFile = string.Empty;
            string strSaveAnswersURL = Url.Action("SaveAnswers", "FlexForm", new { Area = "CrossCutting" });

            strFile += "function getFlexFormAnswers[IDFSFORMTYPE]() {\n";

            if (bSkipAnswers)
            {
                strFile += "[CALLBACKFUNCTION]";
            }
            else
            {
                strFile += "	var inputAnswers = '';\n";
                strFile += "	var selectAnswers = '';\n";
                strFile += "	$('#[IDFSFORMTYPE] input[parameter]').each(function (i, j) {\n";
                strFile += "		if (j.type == \"checkbox\") {\n";
                strFile += "		    if (j.checked) {\n";
                strFile += "		        inputAnswers += j.id + '☼' + $(j).attr(\"idfsEditor\") + '☼' + 'true' + '☼' + $(j).attr(\"idfRow\") + '‼';\n";
                strFile += "	        }\n";
                strFile += "	        else {\n";
                strFile += "	            inputAnswers += j.id + '☼' + $(j).attr(\"idfsEditor\") + '☼' + '☼' + $(j).attr(\"idfRow\") + '‼';\n";
                strFile += "	        }\n";
                strFile += "	    }\n";
                strFile += "	    else {\n";
                strFile += "	        inputAnswers += j.id + '☼' + $(j).attr(\"idfsEditor\") + '☼' + $(j).val() + '☼' + $(j).attr(\"idfRow\") + '‼';\n";
                strFile += "	    }\n";
                strFile += "	});\n";
                strFile += "	$('#[IDFSFORMTYPE] select[parameter]').each(function (i, j) {\n";
                strFile += "		selectAnswers += j.id + '☼' + $(j).attr(\"idfsEditor\") + '☼' + $(j).val() + '☼' + $(j).attr(\"idfRow\") + '‼';\n";
                strFile += "	});\n";
                strFile += "	inputAnswers = (inputAnswers + \".\").replace(\"‼.\", \"\");\n";
                strFile += "	selectAnswers = (selectAnswers + \".\").replace(\"‼.\", \"\");\n";
                strFile += "	$.ajax({\n";
                strFile += "		url: '" + strSaveAnswersURL + "',\n";
                strFile += "		type: 'POST',\n";
                strFile += "		data:\n";
                strFile += "		{\n";
                strFile += "			inputAnswers: inputAnswers,\n";
                strFile += "			selectAnswers: selectAnswers,\n";
                strFile += "			idfsFormTemplate: [IDFSFORMTEMPLATE],\n";
                strFile += "			idfObservation: [IDFOBSERVATION]\n";
                strFile += "		},\n";
                strFile += "		dataType: 'text',\n";
                strFile += "		async: false,\n";
                strFile += "		success: function (idfObservation) {\n";
                strFile += "			$(\"[asp-for='[OBSERVATIONFIELDID]']\").val(idfObservation);\n";
                strFile += "            [CALLBACKFUNCTION]";
                strFile += "		},\n";
                strFile += "		complete: function (json) {\n";
                strFile += "		}\n";
                strFile += "	});\n";
            }

            strFile += "};\n";

            return strFile;
        }
    }
}