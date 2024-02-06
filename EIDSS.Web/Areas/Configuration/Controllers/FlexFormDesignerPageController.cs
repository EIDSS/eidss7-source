//using Nancy.Extensions;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Configuration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;
using EIDSS.Domain.ViewModels;
using Newtonsoft.Json.Linq;
using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace EIDSS.Web.Controllers.Configuration
{
    [Area("Configuration")]
    [Controller]
    public class FlexFormDesignerPageController : BaseController
    {
        private FlexFormDesignerPageViewModel _flexFormDesignerPageViewModel;
        private readonly IFlexFormClient _flexFormClient;
        private readonly IStringLocalizer _localizer;
        private readonly AuthenticatedUser _authenticatedUser;
        private static bool bOutbreak = false;
        private static long? idfsDiagnosisOrDiagnosisGroup;
        private static long? idfOutbreak;
        private static long? idfsOutbreakTemplate;

        public enum ParameterTypes : long
        {
            FlexFormBoolean = 10071025,
            FlexFormString = 10071045,
            FlexFormNumericPositive = 10071060,
            FlexFormYesNoUnknown = 217140000000,
            FlexFormDate = 10071029
        }

        public enum ParameterMode : long
        {
            Ordinary = 10068001,
            Mandatory = 10068003
        }

        public class PasteTreeviewNodeRequestModel
        {
            public long? idfsParameter { get; set; }
            public long? idfsSection { get; set; }
            public long? idfsSectionDestination { get; set; }
            public long? idfsFormTypeDestination { get; set; }
        }

        public FlexFormDesignerPageController(IFlexFormClient flexFormClient, IStringLocalizer localizer, ITokenService tokenService, ILogger<FlexFormDesignerPageController> logger): base(logger, tokenService)
        {
            _flexFormClient = flexFormClient;
            _localizer = localizer; 
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public async Task<ActionResult> Index(OutbreakFlexFormDesignerModel outbreak)
        {
            var formTypesListRequest = new FlexFormFormTypesGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormType = outbreak.flexFormType
            };

            var templateListRequest = new FlexFormTemplateGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormType = outbreak.flexFormType,
                idfOutbreak = outbreak.idfOutbreak
            };

            FlexFormCopyTemplateResponseModel copyTemplateResult = new FlexFormCopyTemplateResponseModel();

            _flexFormDesignerPageViewModel = new FlexFormDesignerPageViewModel()
            {
                FormTypes = _flexFormClient.GetFormTypesList(formTypesListRequest).Result,
                Outbreak = outbreak
            };

            if (outbreak.flexFormType != null)
            {
                bOutbreak = true;
                idfsDiagnosisOrDiagnosisGroup = outbreak.idfsDiagnosisOrDiagnosisGroup;
                idfOutbreak = outbreak.idfOutbreak;

                if (outbreak.idfsFormTemplate is null)
                {
                    long? lDiseaseFormType = null;
                    bool bNonDiseaseFormType = false;

                    switch (outbreak.flexFormType)
                    {
                        case (long?)FlexibleFormTypeEnum.HumanOutbreakCaseQuestionnaire:
                            lDiseaseFormType = (long?)FlexibleFormTypeEnum.HumanEpiInvestigation;
                            break;
                        case (long?)FlexibleFormTypeEnum.LivestockOutbreakCaseQuestionnaire:
                            lDiseaseFormType = (long?)FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo;
                            break;
                        case (long?)FlexibleFormTypeEnum.AvianOutbreakCaseQuestionnaire:
                            lDiseaseFormType = (long?)FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo;
                            break;
                    }

                    if (lDiseaseFormType != null)
                    {
                        var templateRequest = new FlexFormFormTemplateRequestModel
                        {
                            idfsDiagnosis = outbreak.idfsDiagnosisOrDiagnosisGroup,
                            idfsFormType = lDiseaseFormType
                        };

                        var formTemplate = await _flexFormClient.GetFormTemplate(templateRequest);

                        if (formTemplate.First().idfsFormTemplate is null)
                        {
                            templateRequest.idfsDiagnosis = null;
                            formTemplate = await _flexFormClient.GetFormTemplate(templateRequest);
                        }

                        var copyTemplateRequest = new FlexFormCopyTemplateRequestModel()
                        {
                            LangId = GetCurrentLanguage(),
                            User = _authenticatedUser.EIDSSUserId,
                            idfsNewFormType = outbreak.flexFormType,
                            idfsFormTemplate = (long)formTemplate.First().idfsFormTemplate
                        };

                        copyTemplateResult = await _flexFormClient.CopyTemplate(copyTemplateRequest);

                        idfsOutbreakTemplate = copyTemplateResult.idfsFormTemplate;
                    }
                    else
                    {
                        //Create a new parameter, to keep everything contains to one outbreak session.
                        var parameterRequest = new FlexFormParametersSaveRequestModel()
                        {
                            idfsFormType = outbreak.flexFormType,
                            idfsParameterType = (long)ParameterTypes.FlexFormString,
                            idfsEditor = (long)FlexibleFormEditorTypeEnum.TextBox,
                            intHACode = 0,
                            intOrder = 100,
                            strNote = String.Empty,
                            DefaultName = "Comments",
                            DefaultLongName = "Comments",
                            NationalName = _localizer.GetString(FieldLabelResourceKeyConstants.SessionInformationCommentsFieldLabel), //Any resource with the word 'Comments' can be used for this.
                            NationalLongName = _localizer.GetString(FieldLabelResourceKeyConstants.SessionInformationCommentsFieldLabel) //Any resource with the word 'Comments' can be used for this.
                        };

                        JsonResult parameterResult = await SetParameter(parameterRequest);
                        string strParameterResult = JsonConvert.SerializeObject(parameterResult.Value);
                        FlexFormParametersSaveResponseModel parameterSaveResponse = new FlexFormParametersSaveResponseModel();
                        parameterSaveResponse = JsonConvert.DeserializeObject<FlexFormParametersSaveResponseModel>(strParameterResult);

                        string strTemplateName = string.Empty;

                        switch (outbreak.flexFormType)
                        {
                            case (long?)FlexibleFormTypeEnum.HumanOutbreakCaseContactTracing:
                                strTemplateName = "Human Outbreak Case Contact Tracing";
                                break;
                            case (long?)FlexibleFormTypeEnum.HumanOutbreakCaseMonitoring:
                                strTemplateName = "Human Outbreak Case Monitoring";
                                break;
                            case (long?)FlexibleFormTypeEnum.AvianOutbreakCaseContactTracing:
                                strTemplateName = "Avian Outbreak Case Contact Tracing";
                                break;
                            case (long?)FlexibleFormTypeEnum.AvianOutbreakCaseMonitoring:
                                strTemplateName = "Avian Outbreak Case Monitoring";
                                break;
                            case (long?)FlexibleFormTypeEnum.LivestockOutbreakCaseContactTracing:
                                strTemplateName = "Livestock Outbreak Case Contact Tracing";
                                break;
                            case (long?)FlexibleFormTypeEnum.LivestockOutbreakCaseMonitoring:
                                strTemplateName = "Livestock Outbreak Case Monitoring";
                                break;
                        }
                        var templateRequest = new FlexFormTemplateSaveRequestModel()
                        {
                            idfsFormType = outbreak.flexFormType,
                            DefaultName = strTemplateName,
                            NationalName = strTemplateName,
                            strNote = "Default Outbreak Template",
                            blnUNI = true
                        };

                        JsonResult templateResult = await SetTemplate(templateRequest);

                        string strTemplateResult = JsonConvert.SerializeObject(templateResult.Value);
                        FlexFormParameterTemplateSaveResponseModel templateSaveResponse = new FlexFormParameterTemplateSaveResponseModel();
                        templateSaveResponse = JsonConvert.DeserializeObject<FlexFormParameterTemplateSaveResponseModel>(strTemplateResult);

                        var templateParameterRequest = new FlexFormParameterTemplateSaveRequestModel()
                        {
                            idfsParameter = parameterSaveResponse.idfsParameter,
                            idfsFormTemplate = templateSaveResponse.idfsFormTemplate,
                            idfsEditMode = (long)ParameterMode.Ordinary,
                            intOrder = 100
                        };

                        JsonResult templateParameterResult = await SetTemplateParameter(templateParameterRequest);

                        idfsOutbreakTemplate = templateSaveResponse.idfsFormTemplate;
                    }
                }
                else
                {
                    idfsOutbreakTemplate = outbreak.idfsFormTemplate;
                }
            }
            else
            {
                bOutbreak = false;
            }

            return View(_flexFormDesignerPageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetSectionParameterTreeContent(long? idfsFormType, long? idfsSection)
        {
            if (idfsSection != null)
            {
                idfsFormType = null;
            }

            var sectionRequest = new FlexFormSectionsGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormType = idfsFormType,
                idfsParentSection = idfsSection
            };

            var parameterRequest = new FlexFormParametersGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormType = idfsFormType,
                idfsSection = idfsSection
            };

            _flexFormDesignerPageViewModel = new FlexFormDesignerPageViewModel
            {
                Sections = _flexFormClient.GetSectionsList(sectionRequest).Result,
                Parameters = _flexFormClient.GetParametersList(parameterRequest).Result
            };

            return Json(_flexFormDesignerPageViewModel);
        }

        public async Task<JsonResult> GetTemplateTreeContent(FlexFormTemplateGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();

            var result = new List<FlexFormTemplateListViewModel>();
            request.LanguageId = GetCurrentLanguage();

            if (bOutbreak)
            {
                request.idfsFormTemplate = idfsOutbreakTemplate;
                request.idfsFormType = null;
            }
            else
            {
                request.idfsFormType = request.idfsFormType;
            }

            return Json(_flexFormClient.GetTemplateList(request).Result);
        }

        public async Task<JsonResult> GetTemplateDetails(FlexFormTemplateDetailsGetRequestModel request)
        {
            request.Langid = GetCurrentLanguage();
            return Json(_flexFormClient.GetTemplateDetails(request).Result.First());
        }

        public async Task<string> GetTemplateDesign(FlexFormTemplateDesignGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            _flexFormDesignerPageViewModel = new FlexFormDesignerPageViewModel
            {
                TemplateDesign = _flexFormClient.GetTemplateDesignList(request).Result
            };

            var html = Empty;
            var floatingSection = Empty;
            var strSection = Empty;
            var floatingHtml = Empty;
            long? idfsCurrentSection = null;
            var strDisabled = Empty;
            var strUp = Empty;
            var strDown = Empty;
            var iResult = -1;
            int? iObservations;
            var bLocked = true;

            if (_flexFormDesignerPageViewModel != null)
            {
                if (_flexFormDesignerPageViewModel.TemplateDesign.Count > 0)
                {
                    iObservations = _flexFormDesignerPageViewModel.TemplateDesign.First().Observations;
                    bLocked = iObservations > 0 ? true : false;

                    int iSections = _flexFormDesignerPageViewModel.TemplateDesign.Select(x => x.idfsSection).Distinct().Count();
                    int iSectionCount = 0;
                    List<FlexFormTemplateDesignListViewModel> lSections = _flexFormDesignerPageViewModel.TemplateDesign.DistinctBy(x => x.idfsSection).OrderBy(x => x.intSectionOrder).ToList();

                    string strSectionMoveHtml = string.Empty;

                    foreach (var dl in _flexFormDesignerPageViewModel.TemplateDesign)
                    {
                        if (strSection.IndexOf(dl.idfsSection.ToString()) == -1)
                        {
                            if (dl.idfsSection == -1)
                            {
                                iSections--;
                                strSection += dl.idfsSection + "|";
                                floatingHtml += "<div idfsSection='" + dl.idfsSection + "' intOrder='" + dl.intSectionOrder + "'> ";
                                floatingHtml += "       <legend runat='server'>" + dl.SectionName + "</legend>";
                                floatingHtml += strSectionMoveHtml;
                                floatingHtml += "       [" + dl.idfsSection + "]";
                                floatingHtml += "</div>";
                            }
                            else
                            {
                                strSectionMoveHtml = "<div style='float:right;position:relative;top:-20px'>";

                                if (lSections.Count > 1)
                                {
                                    if (++iSectionCount == 1)
                                    {
                                        strSectionMoveHtml += " <div style='padding-right:5px;' class='fas fa-arrow-down' onclick='flexForm.moveTemplateSection(\"" + request.idfsFormTemplate + "\",\"" + dl.idfsSection + "\",\"" + lSections[lSections.IndexOf(dl) + 1].idfsSection + "\");'></div>";
                                    }
                                    else if (iSectionCount == iSections)
                                    {
                                        strSectionMoveHtml += " <div style='padding-right:5px;' class='fas fa-arrow-up' onclick='flexForm.moveTemplateSection(\"" + request.idfsFormTemplate + "\",\"" + dl.idfsSection + "\",\"" + lSections[lSections.IndexOf(dl) - 1].idfsSection + "\");'></div>";
                                    }
                                    else
                                    {
                                        strSectionMoveHtml += " <div style='padding-right:5px;' class='fas fa-arrow-down' onclick='flexForm.moveTemplateSection(\"" + request.idfsFormTemplate + "\",\"" + dl.idfsSection + "\",\"" + lSections[lSections.IndexOf(dl) + 1].idfsSection + "\");'></div>";
                                        strSectionMoveHtml += " <div style='padding-right:5px;' class='fas fa-arrow-up' onclick='flexForm.moveTemplateSection(\"" + request.idfsFormTemplate + "\",\"" + dl.idfsSection + "\",\"" + lSections[lSections.IndexOf(dl) - 1].idfsSection + "\");'></div>";
                                    }
                                }

                                strSectionMoveHtml += "</div>";

                                strSection += dl.idfsSection + "|";
                                html += "<div idfsSection='" + dl.idfsSection + "' intOrder='" + dl.intSectionOrder + "'> ";
                                html += "   <fieldset " + strDisabled + ">";
                                html += "       <legend runat='server'>" + dl.SectionName + "</legend>";
                                html += strSectionMoveHtml;
                                html += "       [" + dl.idfsSection + "]";
                                html += "   </fieldset>";
                                html += "</div>";
                            }
                        }
                    }

                    strSection += floatingSection;
                    html += floatingHtml;

                    foreach (var dl in _flexFormDesignerPageViewModel.TemplateDesign)
                    {
                        iResult++;
                        strDown = Empty;
                        strUp = Empty;

                        if (dl.idfsSection != idfsCurrentSection)
                        {
                            html = html.Replace("[" + idfsCurrentSection.ToString() + "]", strSection);
                            strSection = Empty;

                            idfsCurrentSection = long.Parse(dl.idfsSection.ToString());

                            if ((iResult + 1) < _flexFormDesignerPageViewModel.TemplateDesign.Count)
                            {
                                strDown = " <div id=\"imgDown" + dl.idfsParameter + "\" downParameter class='fa fa-arrow-down' style='display:normal;' onclick='flexForm.moveTemplateParameter(" + request.idfsFormTemplate + "," + dl.idfsParameter + "," + _flexFormDesignerPageViewModel.TemplateDesign[iResult + 1].idfsParameter + ",1);'></div>";
                            }
                        }
                        else
                        {
                            strUp = " <div id=\"imgUp" + dl.idfsParameter + "\" upParameter class='fa fa-arrow-up' style='display:normal;' onclick='flexForm.moveTemplateParameter(" + request.idfsFormTemplate + "," + dl.idfsParameter + "," + _flexFormDesignerPageViewModel.TemplateDesign[iResult - 1].idfsParameter + ",0);'></div>";
                            if ((iResult + 1) < _flexFormDesignerPageViewModel.TemplateDesign.Count)
                            {
                                if (_flexFormDesignerPageViewModel.TemplateDesign[iResult + 1].idfsSection == idfsCurrentSection)
                                {
                                    strDown = " <div id=\"imgDown" + dl.idfsParameter + "\" downParameter class='fa fa-arrow-down' style='display:normal;' onclick='flexForm.moveTemplateParameter(" + request.idfsFormTemplate + "," + dl.idfsParameter + "," + _flexFormDesignerPageViewModel.TemplateDesign[iResult + 1].idfsParameter + ",1);'></div>";
                                }
                            }
                        }

                        strSection += "<div class='row'>";
                        strSection += " <div id='dParameter" + dl.idfsParameter + "' templateParameter style='border: 2px dotted grey;border-radius:5px;' class='row col-lg-10 col-md-10 col-sm-10 col-xs-10 embed-panel' onclick='flexForm.showTemplateParameterDelete(" + dl.idfsParameter + ");'>";
                        strSection += "     <div class='col-lg-6 col-md-6 col-sm-6 col-xs-6'>";
                        strSection += "         <label>" + dl.ParameterName + "</label>";
                        strSection += "     </div>";
                        strSection += "     <div class='col-lg-5 col-md-5 col-sm-5 col-xs-5'>";
                        
                        
                        if (dl.idfsEditor != null)
                        {
                            strSection += ControlHTML(dl.idfsEditor, dl.idfsParameter);
                        }

                        strSection += "     </div>";
                        strSection += " </div>";

                        strSection += " <div id='imgDelete" + dl.idfsParameter + "' deleteParameter class='fa fa-trash' style='display:none;' onclick='flexForm.deleteTemplateParameter(" + dl.idfsParameter + "," + request.idfsFormTemplate + ");'></div>";
                        strSection += " <div id='imgRule" + dl.idfsParameter + "' ruleParameter class='' style='display:none;' onclick='flexForm.addRuleParameter(" + dl.idfsParameter + ");'><img src='" + Url.Content("~/Includes/Images/treeViewRules.png") + "' /></div>";
                        if ((ParameterMode)dl.idfsEditMode == ParameterMode.Mandatory)
                        {
                            strSection += " <div id='imgRequired" + dl.idfsParameter + "' requiredParameter class='' onclick='flexForm.setRequiredParameter(" + dl.idfsParameter + ", " + (long)ParameterMode.Ordinary + ");'><img src='" + Url.Content("~/Includes/Images/redStar.png") + "' /></div>";
                        }
                        else
                        {
                            strSection += " <div id='imgRequired" + dl.idfsParameter + "' requiredParameter class='' onclick='flexForm.setRequiredParameter(" + dl.idfsParameter + ", " + (long)ParameterMode.Mandatory + ");'><img src='" + Url.Content("~/Includes/Images/greyStar.png") + "' /></div>";
                        }

                        strSection += strUp;
                        strSection += strDown;
                        strSection += "</div>";
                    }

                    html = html.Replace("[" + idfsCurrentSection.ToString() + "]", strSection);
                }
            }

            return (html);
        }

        private string ControlHTML(long? idfsEditor, long? idfsParameter)
        {
            try
            {
                string strControl = string.Empty;
                string strValue = string.Empty;
                bool bSelect2Created = false;

                switch (idfsEditor)
                {
                    case (long)FlexibleFormEditorTypeEnum.CheckBox:
                        var checkedAttribute = strValue == "1" ? "checked" : string.Empty;
                        strControl += "<input type='checkbox'></input>";
                        break;

                    case (long)FlexibleFormEditorTypeEnum.DropDown:
                        string strOptions = string.Empty;

                        var request = new FlexFormParameterSelectListGetRequestModel
                        {
                            LangID = GetCurrentLanguage(),
                            idfsParameter = idfsParameter
                        };

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

                        strControl += "<select>" + strOptions + "</select>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.DatePicker:
                    case (long)FlexibleFormEditorTypeEnum.DateTimePicker:
                        string strDateformat = String.Empty;
                        string strControlFormat = string.Empty;

                        switch (GetCurrentLanguage())
                        {
                            case "ar-JO":
                            case "az-Latn-AZ":
                            case "ka-GE":
                            case "ru-RU":
                                strDateformat = "dd.MM.yyyy";
                                strControlFormat = "dd.mm.yy"; ;
                                break;

                            default:
                                strDateformat = "MM/dd/yyyy";
                                strControlFormat = "mm/dd/yy";
                                break;
                        }

                        if (!string.IsNullOrEmpty(strValue))
                        {
                            DateTime dt = DateTime.Parse(strValue);
                            strValue = dt.ToString(strDateformat);
                        }

                        strControl += "<input type='text' style='position:relative;float:left;width:85%'></input>";
                        strControl += "<script type='text/javascript'>$(document).ready(function(){$(\"#" + idfsParameter + "\").val(\"" + strValue + "\");";
                        strControl += "$('#" + idfsParameter + "').datepicker(";
                        strControl += " $.extend({";
                        strControl += " changeMonth: true,";
                        strControl += " changeYear: true,";
                        strControl += " showOn: \"both\",";
                        strControl += " yearRange: \"-122:+79\",";
                        strControl += " constrainInput: false,";
                        strControl += " buttonText: \"<i class='fas fa-calendar'></i>\",";
                        strControl += " beforeShow: function() {";
                        strControl += "     setTimeout(function(){";
                        strControl += "         $('.ui-datepicker').css('z-index', 9999);";
                        strControl += "     }, 0);";
                        strControl += " }";
                        strControl += "},";
                        strControl += "$.datepicker.regional[\"" + GetCurrentLanguage().Split("-")[0].ToString() + "\"],";
                        strControl += " { dateFormat: '" + strControlFormat + "'}";
                        strControl += " ))";
                        strControl += "})";
                        strControl += "</script>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.TextArea:
                        strControl += "<input type='textarea'></input>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.TextBox:
                        strControl += "<input type='text'></input>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.TextBoxSummingField:
                        strControl += "<input type='number' />";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.TextBoxTotalField:
                        strControl += "<input type='number' />";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.Numeric:
                        strControl += "<input type='number'></input>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.Empty:
                        strControl += "";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.RadioButtonList:
                        strControl += "<input type='radio'></input>";
                        break;
                    case (long)FlexibleFormEditorTypeEnum.Statement:
                        break;
                    default:
                        strControl += "Unknown Object:" + idfsEditor + ", Parameter Id: " + idfsParameter;
                        break;
                }

                return strControl;
            }
            catch (Exception e)
            {
                return "Unknown Object:" + idfsEditor + ", Parameter Id: " + idfsParameter;
            }
        }

        public async Task<JsonResult> GetTemplateDeterminants(FlexFormTemplateDeterminantValuesGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            return Json(await _flexFormClient.GetTemplateDeterminantValues(request));
        }

        public async Task<JsonResult> GetSectionDetails(FlexFormSectionsGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            return Json(await _flexFormClient.GetSectionsList(request));
        }

        public async Task<JsonResult> GetParameterDetails(FlexFormParameterDetailsGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            return Json(_flexFormClient.GetParameterDetails(request).Result.First());
        }

        public async Task<JsonResult> GetTemplatesByParameter(FlexFormTemplateByParameterGetRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            return Json(await _flexFormClient.GetTemplatesByParameterList(request));
        }

        public async Task<JsonResult> SetSection(FlexFormSectionSaveRequestModel request)
        {
            request.LangID = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.SetSection(request));
        }

        public async Task<JsonResult> SetParameter(FlexFormParametersSaveRequestModel request)
        {
            request.LangID = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.SetParameter(request));
        }

        public async Task<JsonResult> DeleteSection(FlexFormSectionDeleteRequestModel request)
        {
            return Json(await _flexFormClient.DeleteSection(request));
        }

        public async Task<JsonResult> DeleteParameter(FlexFormParameterDeleteRequestModel request)
        {
            request.LangId = GetCurrentLanguage();
            request.User = _authenticatedUser.UserName;            
            return Json(await _flexFormClient.DeleteParameter(request));
        }

        public async Task<JsonResult> SetRequiredParameter(FlexFormRequiredParameterSaveRequestModel request)
        {
            request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.SetRequiredParameter(request));
        }

        public async Task<JsonResult> MoveTemplateParameter(FlexFormTemplateParameterOrderRequestModel request)
        {
            request.LangId = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.SetTemplateParameterOrder(request));
        }

        public async Task<JsonResult> MoveTemplateSection(FlexFormTemplateSectionOrderRequestModel request)
        {
            request.User = _authenticatedUser.EIDSSUserId;
            request.LangId = GetCurrentLanguage();
            return Json(await _flexFormClient.SetTemplateSectionOrder(request));
        }

        public async Task<JsonResult> DeleteTemplateParameter(FlexFormParameterTemplateDeleteRequestModel request)
        {
            //request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.DeleteTemplateParameter(request));
        }

        public async Task<JsonResult> SetTemplateParameter(FlexFormParameterTemplateSaveRequestModel request)
        {
            request.LangID = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            return Json(await _flexFormClient.SetTemplateParameter(request));
        }

        public async Task<JsonResult> DeleteTemplate(FlexFormTemplateDeleteRequestModel request)
        {
            //request.User = _authenticatedUser.EIDSSUserId;
            request.LangId = GetCurrentLanguage();

            return Json(await _flexFormClient.DeleteTemplate(request));
        }

        public async Task<JsonResult> AddToOutbreak(FlexFormAddToOutbreakSaveRequestModel request)
        {
            //request.User = _authenticatedUser.EIDSSUserId;
            await _flexFormClient.SetOutbreakFlexForm(request);
            return Json("");
        }

        public async Task<JsonResult> PasteTreeViewNode(PasteTreeviewNodeRequestModel request)
        {
            //request.User = _authenticatedUser.EIDSSUserId;
            if (request.idfsParameter != null)
            {
                var copyRequest = new FlexFormParameterCopyRequestModel
                {
                    idfsParameterSource = request.idfsParameter,
                    idfsFormTypeDestination = request.idfsFormTypeDestination,
                    idfsSectionDestination = request.idfsSectionDestination,
                    LangId = GetCurrentLanguage()
                };

                return Json(await _flexFormClient.CopyParameter(copyRequest));
            }
            else
            {
                var copyRequest = new FlexFormSectionCopyRequestModel
                {
                    idfsSectionSource = request.idfsSection,
                    idfsFormTypeDestination = request.idfsFormTypeDestination,
                    idfsSectionDestination = request.idfsSectionDestination
                };

                return Json(await _flexFormClient.CopySection(copyRequest));
            }
        }

        public async Task<JsonResult> SetTemplate(FlexFormTemplateSaveRequestModel request)
        {
            request.LangID = GetCurrentLanguage();
            request.User = _authenticatedUser.EIDSSUserId;
            request.EventTypeId = (long) SystemEventLogTypes.FlexibleFormUNITemplateChange;
            request.SiteId = Convert.ToInt64(_authenticatedUser.SiteId);
            request.UserId = Convert.ToInt64(_authenticatedUser.EIDSSUserId);
            request.LocationId = _authenticatedUser.RayonId;

            return Json(await _flexFormClient.SetTemplate(request));
        }

        public async Task<JsonResult> IsParameterAnswered(FlexFormParameterInUseRequestModel request)
        {
            return Json(await _flexFormClient.IsParameterInUse(request));
        }

        public async Task<JsonResult> SetDeterminant(string[] idfsDiagnosisGroupList, long idfsFormTemplate, int intRowStatus)
        {
            var request = new FlexFormDeterminantSaveRequestModel
            {
                idfsFormTemplate = idfsFormTemplate,
                intRowStatus = intRowStatus,
                User = _authenticatedUser.EIDSSUserId,
                EventTypeId = (long) SystemEventLogTypes.FlexibleFormDeterminantChange,
                SiteId = Convert.ToInt64(_authenticatedUser.SiteId),
                UserId = Convert.ToInt64(_authenticatedUser.EIDSSUserId),
                LocationId = _authenticatedUser.RayonId
            };

            foreach (var idfsDiagnosisGroup in idfsDiagnosisGroupList)
            {
                request.idfsDiagnosisGroup = long.Parse(idfsDiagnosisGroup);
                await _flexFormClient.SetDeterminant(request);
            }

            return Json("");
        }

        public async Task<string> GetTemplateSectionParameterList(long idfsFormTemplate)
        {
            var request = new FlexFormTemplateDesignGetRequestModel
            {
                idfsFormTemplate = idfsFormTemplate,
                LanguageId = GetCurrentLanguage()
            };

            var designList = _flexFormClient.GetTemplateDesignList(request).Result;

            long? idfsCurrentSection = 0;
            var strHTML = Empty;

            foreach (var item in designList)
            {
                if (idfsCurrentSection != item.idfsSection)
                {
                    idfsCurrentSection = item.idfsSection;
                    strHTML += "<div><input type='checkbox' id='cb" + idfsCurrentSection + "' ffType='Section' onchange='flexForm.toggleParameters(" + item.idfsSection + ");' />" + item.SectionName + "</div>[" + idfsCurrentSection + "]";
                }
            }

            strHTML = designList.Aggregate(strHTML, (current, item) => current.Replace("[" + item.idfsSection + "]", "<div style='text-indent:20px'><input type='checkbox' id='cb" + item.idfsParameter + "' ffType='Parameter' idfsSection='" + item.idfsSection + "'onchange='flexForm.setSectionSelection(" + item.idfsSection + ");' />" + item.ParameterName + "</div>[" + item.idfsSection + "]"));

            return designList.Aggregate(strHTML, (current, item) => current.Replace("[" + item.idfsSection + "]", ""));
        }

        public async Task<string> GetRulesForParameter(FlexFormRulesGetRequestModel request)
        {
            var strOptions = "<option value='-1'>-- " + _localizer.GetString(FieldLabelResourceKeyConstants.FlexibleFormDesignerNewEntryFieldLabel) + " -- </option>";
            request.LangID = GetCurrentLanguage();
            var rules = _flexFormClient.GetRulesList(request).Result;

            foreach (var rule in rules)
            {
                strOptions += "<option value='" + rule.idfsRule + "'>" + rule.RuleName + "</option>";
            }

            return strOptions;
        }

        public async Task<JsonResult> SaveRule(FlexFormRuleSaveRequestModel request)
        {
            request.LanguageId = GetCurrentLanguage();
            request.User = _authenticatedUser.UserName;
            
            return Json(await _flexFormClient.SetRule(request));
        }

        public long CopyTemplate(long idfsFormTemplate, long? idfsSite)
        {
            var request = new FlexFormCopyTemplateRequestModel
            {
                idfsFormTemplate = idfsFormTemplate,
                idfsSite = idfsSite,
                User = _authenticatedUser.EIDSSUserId,
                LangId = GetCurrentLanguage()
            };

            var response = _flexFormClient.CopyTemplate(request).Result;

            return request.idfsFormTemplate;
        }

        public async Task<JsonResult> GetRuleDetails(FlexFormRuleDetailsGetRequestModel request)
        {
            request.LangID = GetCurrentLanguage();
            return Json(_flexFormClient.GetRuleDetails(request).Result.First());
        }

        public async Task<string> GetSectionsParametersForSearch(FlexFormSectionsParametersRequestModel request)
        {
            request.LangId = GetCurrentLanguage();
            var response = _flexFormClient.GetSectionsParametersList(request).Result;

            var strHTML = Empty;
            var li = Empty;
            var strText = Empty;
            var idfs = Empty;
            var strType = "Form";
            var iLevel = 0;
            var iLevels = 0;
            var strParent = Empty;
            var idfsFormType = Empty;
            var random = new Random();

            if (response.Count != 0)
            {
                iLevels = response.First().Section.Split('!').Length - 1;
            }

            //Form nodes
            foreach (var item in response)
            {
                idfs = item.Section.Split('!')[0].Split('¦')[0].ToString();
                strText = item.Section.Split('!')[0].Split('¦')[1].ToString();

                if (strHTML.IndexOf("name=\"" + idfs + "\"") == -1)
                {
                    strHTML += "<li>";
                    strHTML += "	<img name=\"" + idfs + "\" src=\"" + Url.Content("~/Includes/Images/treeViewForm-plus.png") + "\" onclick=\"flexForm.getSectionParameterTreeContent(" + idfs + " , undefined, true);\">";
                    strHTML += "	<span class=\"parameterTreeViewItem\" idfs=\"" + idfs + "\" type=\"Form\" onclick=\"flexForm.selectTreeViewItem(this);\">" + strText + "</span>";
                    strHTML += "	<ul name=\"" + idfs + "\" style=\"display:none\">";
                    strHTML += "     [" + idfs + "]";
                    strHTML += "	</ul>";
                    strHTML += "</li>";
                }
            }

            var strPreviousParent = Empty;

            //Section nodes
            for (iLevel = 1; iLevel < iLevels; iLevel++)
            {
                li = Empty;
                strParent = Empty;

                foreach (var item in response)
                {
                    strParent = item.Section.Split('!')[iLevel - 1].Split('¦')[0].ToString();
                    idfs = item.Section.Split('!')[iLevel].Split('¦')[0].ToString();
                    strText = item.Section.Split('!')[iLevel].Split('¦')[1].ToString();

                    if (strParent != strPreviousParent && !IsNullOrEmpty(strPreviousParent))
                    {
                        strHTML = strHTML.Replace("[" + strPreviousParent + "]", li);
                        li = Empty;
                    }

                    if ((li.IndexOf(idfs) == -1) && idfs != "0")
                    {
                        var num = random.Next(999999);
                        li += "<li>";
                        li += "	<img name=\"" + idfs + "\" src=\"" + Url.Content("~/Includes/Images/treeViewSection-plus.png") + "\" onclick=\"flexForm.getSectionParameterTreeContent(" + strParent + ", " + idfs + ", true, 'a" + num.ToString() + "');\">";
                        li += "	<span class=\"parameterTreeViewItem\" idfs=\"" + idfs + "\" type=\"Section\" onclick=\"flexForm.selectTreeViewItem(this);\">" + strText + "</span>";
                        li += "	<ul name=\"" + idfs + "\" style=\"display:none\" parent=\"a" + num + "\">";
                        li += "     [" + idfs + "]";
                        li += "	</ul>";
                        li += "</li>";

                        strPreviousParent = strParent;
                        strParent = Empty;
                    }
                }

                strHTML = strHTML.Replace("[" + strPreviousParent + "]", li);
            }

            //Parameters
            li = Empty;
            strParent = Empty;

            foreach (var item in response)
            {
                idfsFormType = item.Section.Split('!')[0].Split('¦')[0].ToString();

                for (iLevel = 1; iLevel < iLevels; iLevel++)
                {
                    idfs = item.Section.Split('!')[iLevel].Split('¦')[0].ToString();
                    strText = item.Section.Split('!')[iLevel].Split('¦')[1].ToString();

                    if (idfs == "0" && IsNullOrEmpty(strParent))
                    {
                        strParent = item.Section.Split('!')[iLevel - 1].Split('¦')[0].ToString();
                    }
                    else if (idfs != "0" && !IsNullOrEmpty(strParent))
                    {
                        if (strParent != strPreviousParent && !IsNullOrEmpty(strPreviousParent))
                        {
                            strHTML = strHTML.Replace("[" + strPreviousParent + "]", li);
                            li = Empty;
                        }

                        li += "<li class=\"parameterType\"><span class=\"parameterTreeViewItem\" idfs=\"" + idfs + "\" type=\"Parameter\" onclick=\"flexForm.selectTreeViewItem(this);\" idfsformtype=\"" + idfsFormType + "\" idfsparentsection=\"" + strParent + "\">" + strText + "</span></li>";
                        strPreviousParent = strParent;
                        strParent = Empty;
                    }
                }
            }

            strHTML = strHTML.Replace("[" + strPreviousParent + "]", li);
            strHTML = "<ul>" + strHTML + "</ul>";

            return strHTML;
        }

        public async Task<JsonResult> GetDeterminantDiseaseList(int intHACode, long idfsFormTemplate, long idfsFormType)
        {
            var request = new FlexFormDiseaseGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                SortColumn = "strName",
                SortOrder = SortConstants.Ascending,
                AccessoryCode = intHACode,
                SimpleSearch = "",
                AdvancedSearch = "",
                idfsFormTemplate = idfsFormTemplate,
                idfsFormType = idfsFormType
            };

            var list = await _flexFormClient.GetDiseaseList(request);

            return Json(list);
        }

        public async Task<JsonResult> GetParameterTypeEditorMapping(long idfsParameterType)
        {
            var request = new FlexFormParameterTypeEditorMappingRequestModel()
            {
                LanguageID = GetCurrentLanguage(),
                idfsParameterType = idfsParameterType
            };

            var list = await _flexFormClient.GetParameterTypeEditorMapping(request);

            return Json(list);
        }
    }
}
