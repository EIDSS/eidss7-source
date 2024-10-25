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

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "FlexFormMatrixView")]
    public class FlexFormMatrixViewComponent : ViewComponent
    {
        FlexFormQuestionnaireViewModel _flexFormQuestionnaireViewModel;
        readonly IFlexFormClient _flexFormClient;

        private string LanguageID { get; set; }

        private class Section
        {
            public long idfsSection { get; set; }
            public bool blnGrid { get; set; }
        }

        public FlexFormMatrixViewComponent(IFlexFormClient flexFormClient)
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
            string strTitle = "<h6 style='left:0px;position:sticky'>" + request.Title + "</h6>";
            string strFlexFormSectionHTML = string.Empty;
            string strFlexFormParameterHTML = string.Empty;
            string strFlexFormRowHTML = string.Empty;
            string strGridHeaderRow = string.Empty;
            Section SectionItem = new Section();
            long? idfsSection = null;
            long? idfsFormTemplate = null;
            string strObservationIdentity = string.Empty;

            List<Section> Sections = new List<Section>();
            List<FlexFormQuestionnaireResponseModel> flexForm = await _flexFormClient.GetQuestionnaire(request);
            FlexFormActivityParametersGetRequestModel answersRequest = new FlexFormActivityParametersGetRequestModel();
            List<FlexFormActivityParametersListResponseModel> answers = new List<FlexFormActivityParametersListResponseModel>();

            LanguageID = request.LangID;
            if (flexForm.Count > 0)
                idfsFormTemplate = flexForm[0].idfsFormTemplate;

            if (request.idfObservation != null)
            {
                answersRequest.observationList = request.idfObservation.ToString();
                answersRequest.LangID = request.LangID;

                answers = await _flexFormClient.GetAnswers(answersRequest);
            }

            //Iterate through to create section containers
            foreach (var item in flexForm)
            {
                //TODO: skip sections until proper implementation
                if (item.idfsSection == item.idfsParameter || item.idfsEditor is null)
                    continue;
                if (item.idfsSection != idfsSection)
                {
                    SectionItem = new Section();
                    SectionItem.blnGrid = (bool)(item.blnGrid ?? false);
                    SectionItem.idfsSection = (long)item.idfsSection;
                    idfsSection = (long)item.idfsSection;
                    Sections.Add(SectionItem);
                    strFlexFormSectionHTML += "<legend>" + item.SectionName + "</legend>" +
                        "<div class=\"card-header\"><h6 title></h6></div>" +
                        "<div id='" + item.idfsSection + "' style='margin-left:-10px;border: solid 0px black'>[" + item.idfsSection + "]</div>";
                }
            }

            foreach (var section in Sections)
            {
                strFlexFormParameterHTML = string.Empty;

                if (section.blnGrid)
                {
                    //Build columns headers
                    foreach (var _seciton in Sections)
                    {
                        if (string.IsNullOrEmpty(strGridHeaderRow))
                        {
                            int i = 0;
                            //Matrix columns
                            foreach (string matrixColumn in request.MatrixColumns)
                            {
                                string otherStyles = request.MatrixColumnStyles.Count >= i ? request.MatrixColumnStyles.ToArray()[i] : string.Empty;
                                strGridHeaderRow += "<th style='padding-right:15px;" + otherStyles + "'>" + matrixColumn + "</th>";
                                i++;
                            }
                        }

                        foreach (var item in flexForm)
                        {
                            //Parameter Columns
                            if (item.idfsSection == _seciton.idfsSection)
                            {
                                strGridHeaderRow += "<th style='padding-right:15px'>" + item.ParameterName + "</th>";
                            }
                        }
                    }

                    strGridHeaderRow = "<tr>" + strGridHeaderRow + "</tr>";

                    int TotalID = 0;
                    
                    //Build Data Fields
                    request.MatrixData ??= new List<FlexFormMatrixData>();

                    foreach (var matrixDataRow in request.MatrixData)
                    {
                        TotalID++;
                        strFlexFormRowHTML = string.Empty;
                        foreach (var _seciton in Sections)
                        {
                            if (string.IsNullOrEmpty(strFlexFormRowHTML))
                            {
                                int i = 0;
                                foreach (string data in matrixDataRow.MatrixData)
                                {
                                    string otherStyles = request.MatrixColumnStyles.Count >= i ? request.MatrixColumnStyles.ToArray()[i] : string.Empty;
                                    strFlexFormRowHTML += "<td style='" + otherStyles + "'>" + data + "</td>";
                                    i++;
                                }
                            }

                            foreach (var item in flexForm)
                            {
                                if (_seciton.idfsSection == item.idfsSection)
                                {
                                    strFlexFormRowHTML += ControlHTML(answers, item.idfsEditor, item.idfsParameter, item.ParameterName, true, matrixDataRow.idfRow, TotalID);
                                }
                            }
                        }
                        strFlexFormParameterHTML += "<tr>" + strFlexFormRowHTML + "</tr>";
                    }

                    strFlexFormSectionHTML = "<table cellspacing=0 cellpadding=0>" + strGridHeaderRow + strFlexFormParameterHTML + "</table>";
                    break;
                }
                else
                {
                    foreach (var item in flexForm)
                    {
                        //TODO: skip sections and labels until proper implementation
                        if (item.idfsSection == item.idfsParameter || item.idfsEditor is null)
                            continue;
                        if (section.idfsSection == item.idfsSection)
                        {
                            strFlexFormParameterHTML += "<div class='row'>" + ControlHTML(answers, item.idfsEditor, item.idfsParameter, item.ParameterName, false, 0) + "</div>";
                        }
                    }

                    strFlexFormSectionHTML = strFlexFormSectionHTML.Replace("[" + section.idfsSection + "]", strFlexFormParameterHTML);
                }
            }

            List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>();

            kvpReplacements.Add(new KeyValuePair<string, string>("SUBMITBUTTONID", request.SubmitButtonID));
            kvpReplacements.Add(new KeyValuePair<string, string>("IDFSFORMTYPE", request.idfsFormType.ToString()));
            kvpReplacements.Add(new KeyValuePair<string, string>("IDFSFORMTEMPLATE", string.IsNullOrEmpty(idfsFormTemplate.ToString()) ? "undefined" : idfsFormTemplate.ToString()));
            kvpReplacements.Add(new KeyValuePair<string, string>("IDFOBSERVATION", string.IsNullOrEmpty(request.idfObservation.ToString()) ? "undefined" : request.idfObservation.ToString()));
            kvpReplacements.Add(new KeyValuePair<string, string>("OBSERVATIONFIELDID", request.ObserationFieldID));

            _flexFormQuestionnaireViewModel.FlexFormScript = sbContent(getFlexFormAnswers(), kvpReplacements);
            _flexFormQuestionnaireViewModel.QuestionnaireHTML = strTitle + "<div id='" + request.idfsFormType + "' flexform><input type='hidden' asp-for='" + request.ObserationFieldID + "' value='" + request.idfObservation + "'>" + strFlexFormSectionHTML + "</input></div>";
        }

        private string ControlHTML(List<FlexFormActivityParametersListResponseModel>? answers, long? idfsEditor, long idfsParameter, string strParameterName, bool blnGrid, long? idfRow, int? TotalID = null)
        {
            string strLabelCSS = "class=''";
            string strContainerCSS = "class='col-lg-6 col-md-6 col-sm-6'";
            string strControlCSS = "class='form-control'";
            string strControl = string.Empty;
            string strControlHTML = string.Empty;
            string strControlLabel = string.Empty;
            string strValue = string.Empty;
            string strElementAttributes = string.Empty;
            
            string onChangeScript = "var t = 0;$(\"[sumtag=MSF-" + TotalID + "]\").each(function (i, j) { if(!isNaN(parseInt($(j).val()))) { t += parseInt($(j).val()); }});$(\"[totaltag=MTF-" + TotalID + "]\").val(t);";
            string SumTag = "MSF-" + TotalID.ToString();
            string TotalTag = "MTF-" + TotalID.ToString();

            if (!blnGrid)
            {
                strControlLabel = "<div " + strContainerCSS + "><span class='fa fa-minus'></span><span " + strLabelCSS + ">" + strParameterName + "</span></div>";
            }

            strElementAttributes = "id='" + idfsParameter + "' idfsEditor='" + idfsEditor + "' idfActivityParameters='[IDFACTIVITYPARAMETERS]'" + strControlCSS + " idfRow='[IDFROW]' value='[VALUE]' parameter";

            if (answers != null)
            {
                foreach (var answer in answers)
                {
                    if (answer.idfsParameter == idfsParameter && answer.idfRow == idfRow)
                    {
                        strValue = answer.varValue;
                        strElementAttributes = strElementAttributes.Replace("[IDFACTIVITYPARAMETERS]", answer.idfActivityParameters.ToString());
                        strElementAttributes = strElementAttributes.Replace("[VALUE]", strValue);
                        break;
                    }
                }
            }

            strElementAttributes = strElementAttributes.Replace("[IDFACTIVITYPARAMETERS]", "");
            strElementAttributes = strElementAttributes.Replace("[IDFROW]", idfRow.ToString());
            strElementAttributes = strElementAttributes.Replace("[VALUE]", "");

            switch (idfsEditor)
            {
                case (long)FlexibleFormEditorTypeEnum.CheckBox:
                    strControl += "<input type='checkbox' [ATTRIBUTES]></input>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.DropDown:
                    FlexFormParameterSelectListGetRequestModel request = new FlexFormParameterSelectListGetRequestModel();
                    string strOptions = string.Empty;

                    request.LangID = LanguageID;
                    request.idfsParameter = idfsParameter;

                    List<FlexFormParameterSelectListResponseModel> options = _flexFormClient.GetDropDownOptionsList(request).Result;

                    strOptions = "<option value='-1'></option>";

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

                    strControl += "<select [ATTRIBUTES]>" + strOptions + "</select>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.DatePicker:
                case (long)FlexibleFormEditorTypeEnum.DateTimePicker:
                    if (!string.IsNullOrEmpty(strValue))
                    {
                        DateTime dt = DateTime.Parse(strValue);
                        strValue = dt.ToString(CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern);
                    }
                    strControl += "<input type='date' [ATTRIBUTES]></input>";
                    strControl += "<script type='text/javascript'>$(document).ready(function(){$(\"#" + idfsParameter + "\").val(\"" + strValue + "\");});</script>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.TextArea:
                    strControl += "<input type='textarea' [ATTRIBUTES]></input>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.TextBox:
                    strControl += "<input type='text' [ATTRIBUTES]></input>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.TextBoxSummingField:
                    strControl += "<input type='number' [ATTRIBUTES] SumTag='" + SumTag + "' class='form-control' style='border-radius:0;min-width:80px;' onchange='" + onChangeScript + "' />";
                    break;
                case (long)FlexibleFormEditorTypeEnum.TextBoxTotalField:
                    strControl += "<input type='number' [ATTRIBUTES] TotalTag='" + TotalTag + "' class='form-control' style='order-radius:0;min-width:80px' />";
                    break;
                case (long)FlexibleFormEditorTypeEnum.Numeric:
                    strControl += "<input type='number' [ATTRIBUTES] style='min-width:80px;'></input>";
                    break;
                case (long)FlexibleFormEditorTypeEnum.Empty:
                    strControl += "";
                    break;
                case (long)FlexibleFormEditorTypeEnum.RadioButtonList:
                    strControl += "<input type='radio' [ATTRIBUTES]></input>";
                    break;
                default:
                    string test = "";
                    break;
            }

            strControl = strControl.ToString().Replace("[ATTRIBUTES]", strElementAttributes);
            strControlHTML = strControlHTML.Replace("[IDFROW]", idfRow.ToString());

            if (!blnGrid)
            {
                strControlHTML = strControlLabel + "<div " + strContainerCSS + ">" + strControl + "</div>";
            }
            else
            {
                strControlHTML += "<td>" + strControl + "</td>";
            }

            return strControlHTML;
        }

        private string sbContent(string strContent, List<KeyValuePair<string, string>> ldReplacements)
        {
            ListDictionary ld = new ListDictionary();

            //Make replacements
            foreach (KeyValuePair<string, string> kvpItem in ldReplacements)
            {
                strContent = strContent.Replace("[" + kvpItem.Key + "]", kvpItem.Value);
            }

            StringBuilder sb = new StringBuilder();

            sb.Append(strContent);

            return sb.ToString();
        }

        private string sbFile(string strFileAndPath, List<KeyValuePair<string, string>> ldReplacements)
        {
            string strContent = string.Empty;

            using (StreamReader sr = File.OpenText(strFileAndPath))
            {
                strContent = sr.ReadToEnd();
            }
            ListDictionary ld = new ListDictionary();

            //Make replacements
            foreach (KeyValuePair<string, string> kvpItem in ldReplacements)
            {
                strContent = strContent.Replace("[" + kvpItem.Key + "]", kvpItem.Value);
            }

            StringBuilder sb = new StringBuilder();

            sb.Append(strContent);

            return sb.ToString();
        }

        private string getFlexFormAnswers()
        {
            string strFile = string.Empty;
            string strSaveAnswersURL = Url.Action("SaveAnswers", "FlexForm", new { Area = "CrossCutting" });

            strFile += "$(document).ready(function () {\n";
            strFile += "	//Add javascript to the \"Save\" of the sidebar navigation\n";
            strFile += "	$(\"[href = '#finish']\").attr('onclick', 'getFlexFormAnswers[IDFSFORMTYPE]();' + $('#[SUBMITBUTTONID]').attr('onclick'));\n";
            strFile += "	//Add javascript to the known submit button, by id.\n";
            strFile += "	$('#[SUBMITBUTTONID]').attr('onclick', 'getFlexFormAnswers[IDFSFORMTYPE]();' + $('#[SUBMITBUTTONID]').attr('onclick'));\n";
            strFile += "});\n";
            strFile += "function getFlexFormAnswers[IDFSFORMTYPE]() {\n";
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
            strFile += "			$(\"[asp-for= '[OBSERVATIONFIELDID]']\").val(idfObservation);\n";
            strFile += "		},\n";
            strFile += "		complete: function (json) {\n";
            strFile += "		}\n";
            strFile += "	});\n";
            strFile += "};\n";
            return strFile;
        }
    }
}
