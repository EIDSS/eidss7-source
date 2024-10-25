$(document).on("click", function (i, j) {
    if (!($(i.target).attr("class") == "parameterTreeViewItem" ||
        $(i.target).attr("class") == "templateTreeViewItem" ||
        $(i.target).attr("class") == "templateParameterTreeViewItem")) {
        $("#dFlexFormDecision").attr("style", "visibility:hidden");
    }
});

var flexForm = {
    //Permissions assigned in SetPermissions as defined per use case SAUC62.
    createWritePermission: '',
    deletePermission: '',
    parameterFields: "#txtDefaultLongName,#txtDefaultName,#ddlidfsEditor,#ddlidfsParameterType,#txtNationalLongName,#txtNationalName",
    GetSectionParameterTreeContentUrl: '',
    GetTemplateTreeContentUrl: '',
    GetParameterDetailsUrl: '',
    GetSectionDetailsUrl: '',
    GetFormDetailsUrl: '',
    CopyTemplateUrl: '',
    PasteTreeViewNodeUrl: '',
    SetTemplateUrl: '',
    DeleteTemplateUrl: '',
    GetTemplateDetailsUrl: '',
    GetTemplateDesignUrl: '',
    GetTemplateSectionParameterListUrl: '',
    GetTemplateDeterminantsUrl: '',
    GetTemplatesByParameterUrl: '',
    DeleteParameterUrl: '',
    DeleteSectionUrl: '',
    SetDeterminantUrl: '',
    SetSectionUrl: '',
    SetParameterUrl: '',
    DeleteTemplateParameterUrl: '',
    SetTemplateParameterUrl: '',
    IsParameterAnsweredUrl: '',
    GetDeterminantsUrl: '',
    MoveTemplateParameterUrl: '',
    MoveTemplateSectionUrl: '',
    AddToOutbreakUrl: '',
    SetRequiredParameterUrl: '',
    GetRulesForParameterUrl: '',
    GetRuleDetailsUrl: '',
    SaveRuleUrl: '',
    GetDeterminantDiseaseListUrl: '',
    GetSectionsParametersForSearchUrl: '',
    GetParameterTypeEditorMappingUrl: '',
    BaseReferenceListUrl: '',
    ImageURL: '',
    bParameter: false,

    init: function () {
        flexForm.postReadyActions();
        flexForm.enableContainer('Parameter');

        $("#iAddParameter,#iDeleteParameter,#iAddSection,#iDeleteSection,#btnAddParameter,#iCopyTreeviewNode,#iShowTemplateParameters,#iDeleteTemplate").addClass("disabled").removeClass("flex-form-pointer");
    },

    getTemplateParameterTreeContent: function (idfsFormType, idfsSection, bLoaded, parentId) {
        if (bLoaded == "false") {
            $.ajax({
                url: flexForm.GetSectionParameterTreeContentUrl,
                data: {
                    idfsFormType: idfsFormType,
                    idfsSection: idfsSection
                },
                dataType: 'json',
                type: 'POST',
                success: function (json) {
                    var ulList = "";

                    $(json.sections).each(function (i, j) {
                        parentId = Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 6);
                        ulList += "<li><img name='" + j.idfsSection + "' src='" + flexForm.ImageURL + "/treeViewSection-plus.png' loaded=false onclick=\"flexForm.getTemplateParameterTreeContent(" + idfsFormType + "," +
                            j.idfsSection + ",$(this).attr('loaded'), '" + parentId + "');\">" +
                            "<span class=\"templateParameterTreeViewItem\" idfs=\"" + j.idfsSection + "\" type=\"Section\" onclick=\"flexForm.selectTreeViewItem(this);\" idfsFormType=\"" + idfsFormType + "\">" + j.nationalName + "</span>" +
                            "<ul name=\"" + j.idfsSection + "\" parent=\"" + parentId + "\"></ul></li>";
                    });

                    $(json.parameters).each(function (i, j) {
                        ulList += "<li class='parameterType'>" +
                            "<span class=\"templateParameterTreeViewItem\" idfs=\"" + j.idfsParameter + "\" type=\"Parameter\" onclick=\"flexForm.selectTreeViewItem(this);\" idfsFormType=\"" + idfsFormType + "\" idfsParentSection=\"" + idfsSection + "\">" + j.nationalName + "</span>" +
                            "</li>";
                    });

                    var idfs = idfsFormType;
                    var type = "Form";

                    if (idfsSection != undefined) {
                        idfs = idfsSection;
                        type = "Section";
                    }

                    $("#dTemplateParameters ul[name='" + idfs + "']").html(ulList).get(0);
                    flexForm.toggleNode("dTemplateParameters", idfs, type, true);
                    flexForm.selectTreeViewItem(($("span[idfs='" + idfs + "']"))[0]);
                },
                error: function (xml) {
                    alert(xml);
                }
            });
        }
        else {
            if (idfsSection != undefined) {
                flexForm.toggleNode("dTemplateParameters", idfsSection, "Section", false, parentId);
            }
            else if (idfsFormType != undefined) {
                flexForm.toggleNode("dTemplateParameters", idfsFormType, "Form", false, parentId);
            }
        }
    },

    getSectionParameterTreeContent: function (idfsFormType, idfsSection, bLoaded, parentId) {
        if (bLoaded == "false") {
            $.ajax({
                url: flexForm.GetSectionParameterTreeContentUrl,
                data: {
                    idfsFormType: idfsFormType,
                    idfsSection: idfsSection
                },
                dataType: 'json',
                type: 'POST',
                success: function (json) {
                    var ulList = "";
                    var navigationImage = '';

                    $(json.sections).each(function (i, j) {
                        if (!(j.hasNestedSections || j.hasParameters)) {
                            navigationImage = flexForm.ImageURL + '/treeViewSection.png';
                        }
                        else {
                            navigationImage = flexForm.ImageURL + '/treeViewSection-plus.png';
                        }

                        parentId = Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 6);
                        ulList += "<li><img name='" + j.idfsSection + "' src='" + navigationImage + "' loaded=false onclick=\"flexForm.getSectionParameterTreeContent(" + idfsFormType + "," +
                            j.idfsSection + ",$(this).attr('loaded'), '" + parentId + "');\">" +
                            "<span class=\"parameterTreeViewItem\" idfs=\"" + j.idfsSection + "\" type=\"Section\" onclick=\"flexForm.selectTreeViewItem(this);\" idfsFormType=\"" + idfsFormType + "\">" + j.nationalName + "</span>" +
                            "<ul name=\"" + j.idfsSection + "\" parent=\"" + parentId + "\"></ul></li>";
                    });

                    $(json.parameters).each(function (i, j) {
                        ulList += "<li class='parameterType'>" +
                            "<span class=\"parameterTreeViewItem\" idfs=\"" + j.idfsParameter + "\" type=\"Parameter\" onclick=\"flexForm.selectTreeViewItem(this);\" idfsFormType=\"" + idfsFormType + "\" idfsParentSection=\"" + idfsSection + "\">" + j.nationalName + "</span>" +
                            "</li>";
                    });

                    var idfs = idfsFormType;
                    var type = "Form";

                    if (idfsSection != undefined) {
                        idfs = idfsSection;
                        type = "Section";
                    }

                    $("#dParameters ul[name='" + idfs + "']").html(ulList).get(0);
                    flexForm.toggleNode("dParameters", idfs, type, true);
                    flexForm.selectTreeViewItem(($("span[idfs='" + idfs + "']"))[0]);
                },
                error: function (xml) {
                    alert(xml);
                }
            });
        }
        else {
            if (idfsSection != undefined) {
                flexForm.toggleNode("dParameters", idfsSection, "Section", false, parentId);
            }
            else if (idfsFormType != undefined) {
                flexForm.toggleNode("dParameters", idfsFormType, "Form", false, parentId);
            }
        }
    },

    getTemplateTreeContent: function (idfsFormType, bLoaded) {
        if (bLoaded == "false") {
            $.ajax({
                url: flexForm.GetTemplateTreeContentUrl,
                data: {
                    idfsFormType: idfsFormType
                },
                dataType: 'json',
                success: function (json) {
                    var ulList = "";

                    $(json).each(function (i, j) {
                        ulList += "<li><img name='" + j.idfsFormTemplate + "' src='" + flexForm.ImageURL + "/treeViewTemplate.png'>" +
                            "<span class=\"templateTreeViewItem\" idfs=\"" + j.idfsFormTemplate + "\" type=\"Template\" onclick=\"flexForm.selectTreeViewItem(this);\">" + j.nationalName + "</span></li>";
                    });

                    $("#dFormTemplates ul[name='" + idfsFormType + "']").attr("loaded", true).html(ulList).get(0);
                    flexForm.toggleNode("dFormTemplates", idfsFormType, "Form", true);
                }
            });
        }
        else {
            if (idfsFormType != undefined) {
                flexForm.toggleNode("dFormTemplates", idfsFormType, "Form", false);
            }
            else if (idfsSection != undefined) {
                flexForm.toggleNode("dFormTemplates", idfsSection, "Section", false);
            }
        }
    },

    toggleNode: function (baseId, nameId, nodeType, bLoaded, parentId) {
        if (!bLoaded) {
            $("#" + baseId + " ul[name='" + nameId + "']").toggle();
        }

        if (parentId != undefined) {
            parentId = "[parent='" + parentId + "']";
        }
        else {
            parentId = "";
        }

        if ($("#" + baseId + " ul[name='" + nameId + "']" + parentId).is(":visible")) {
            $("#" + baseId + " img[name='" + nameId + "']").attr("loaded", true).attr("src", flexForm.ImageURL + "/treeView" + nodeType + "-minus.png");
        }
        else {
            $("#" + baseId + " img[name='" + nameId + "']").attr("src", flexForm.ImageURL + "/treeView" + nodeType + "-plus.png");
        }
    },

    selectTreeViewItem: function (obj) {
        $("span.parameterTreeViewItem,span.templateTreeViewItem,span.templateParameterTreeViewItem").attr("style", "");
        $(obj).attr("style", "background-color:#ffffaa");

        $("#iAddParameter,#iDeleteParameter,#iAddSection,#iDeleteSection,#btnAddParameter,#iCopyTreeviewNode,#iShowTemplateParameters,#iDeleteTemplate,#iAddTemplateParameter,#iAddTemplate").addClass("disabled").removeClass("flex-form-pointer");

        if ($("#hdnEditingMode").val() == "Parameter") {
            $("#dParameterForm,#dSectionForm,#fsTemplateContainer").hide();
            $("#dTemplatesUsedByParameter").html("");
        }

        var idfs = $(obj).attr("idfs");
        $("#hdnCurrentItemType").val($(obj).attr("type"));

        switch ($(obj).attr("type")) {
            case "Form":
                $("#iAddSection,#iAddParameter,#iAddTemplate").removeClass("disabled").addClass("flex-form-pointer");
                $("#hdnCurrentidfsFormType").val(idfs);
                if ($("a.active").attr("editmode") != "Template") {
                    $("#hdnCurrentidfsSection,#hdnCurrentidfsParameter,#hdnCurrentidfsFormTemplate").val("");
                }
                else {
                    $("#hdnCurrentidfsSection,#hdnCurrentidfsParameter").val("");
                }

                $("#txtFullPathSection,#txtParentSection,#txtFullPath").val(flexForm.getTreeViewPath(obj));
                flexForm.GetDiseaseList();
                break;
            case "Template":
                $("#hdnCurrentidfsFormTemplate").val(idfs);
                $("#iShowTemplateParameters").removeClass("disabled").addClass("flex-form-pointer");
                $("#hdnCurrentidfsParameter,#hdnCurrentidfsSection").val("");
                flexForm.loadTemplate();
                break;
            case "Section":
                $("#iAddParameter,#iAddSection,#iDeleteSection,#iCopyTreeviewNode").removeClass("disabled").addClass("flex-form-pointer");

                $("#hdnCurrentidfsFormType").val($(obj).attr("idfsFormType"));
                $("#hdnCurrentidfsSection").val(idfs);

                if ($("a.active").attr("editmode") != "Template") {
                    $("#hdnCurrentidfsParameter,#hdnCurrentidfsFormTemplate").val("");
                }
                else {
                    $("#hdnCurrentidfsParameter").val("");
                }

                flexForm.loadSection(idfs, flexForm.getTreeViewPath(obj), "");

                //Temp Code to keep working in this area.
                if ($("a.active").attr("editmode") != "Template") {
                    $("#dSectionForm").show();
                    $("#divParameterEditor").attr("class", "");
                    $("#dParameterForm").hide();
                }
                break;
            case "Parameter":
                $("#iDeleteParameter,#iCopyTreeviewNode,#iAddTemplateParameter").removeClass("disabled").addClass("flex-form-pointer");

                $("#hdnCurrentidfsFormType").val($(obj).attr("idfsFormType"));
                $("#hdnCurrentidfsSection").val($(obj).attr("idfsParentSection"));
                $("#hdnCurrentidfsParameter").val(idfs);

                if ($("a.active").attr("editmode") != "Template") {
                    $("#hdnCurrentidfsFormTemplate").val("");
                }

                flexForm.loadParameter(idfs, flexForm.getTreeViewPath(obj), "");

                //Temp Code to keep working in this area.
                if ($("a.active").attr("editmode") != "Template") {
                    $("#dParameterForm").show();
                    $("#divParameterEditor").attr("class", "");
                    $("#dSectionForm").hide();
                }
                break;
            default:
                break;
        }

        if ($(obj).offset() != undefined) {
            var top = $(obj).offset().top;
            var left = $(obj).offset().left;

            $("#dFlexFormDecision").removeAttr("style").attr("style", "position:absolute;top:" + top + "px;left:" + left + "px");
        }

        $("#dFlexFormDecisions").html($(".flex-form-icon:visible").html());
    },

    getTreeViewPath: function (obj) {
        var text = "";
        var path = "";
        var type = "";
        var name = "";

        while (true) {
            text = $($(obj)[0]).text();
            type = $($(obj)[0]).attr("type");
            name = $($(obj)[0]).parent().parent().attr("name");
            path = '/' + text + path;

            obj = $("[idfs='" + name + "']");

            if (type == "Form") {
                break;
            }
        }

        return path;
    },

    postReadyActions: function () {
        flexForm.fillDropDownList("ddlidfsParameterType", "Flexible Form Parameter Type", "226");
        flexForm.fillDropDownList("ddlidfsEditor", "Flexible Form Parameter Editor", "0", "", true);
        flexForm.fillDropDownList("ddlidfsRuleAction", "Flexible Form Rule Action", "0");
        flexForm.fillDropDownList("ddlidfsCheckPoint", "Flexible Form Check Point", "0");
        flexForm.fillDropDownList("ddlidfsRuleFunction", "Flexible Form Rule Function", "0");

        $("#ddlidfsParameterType,#ddlidfsEditor,#ddlidfsRuleAction,#ddlidfsCheckPoint,#ddlidfsRuleFunction").select2({
            placeholder: "",
            allowClear: true,
            width: 250
        });
    },

    getEditorList: function (idfsParameterType, idfsEditor) {
        if (idfsParameterType == undefined) {
            idfsParameterType = $("#ddlidfsParameterType").val();
        }

        if (idfsParameterType != undefined && idfsParameterType != "") {
            $.ajax({
                type: 'POST',
                url: flexForm.GetParameterTypeEditorMappingUrl,
                data: {
                    idfsParameterType: idfsParameterType
                },
                dataType: "json",
                success: function (json) {
                    var optionsHtml = "";
                    var iCount = 0;
                    var optionText = "";

                    $(json[0].idfsEditor.split(',')).each(function (i, j) {
                        iCount++;
                        optionText = json[0].editor.split(',')[i];

                        if (idfsEditor == j) {
                            optionsHtml += "<option value=\"" + j + "\" selected>" + optionText + "</option>";
                        }
                        else {
                            optionsHtml += "<option value=\"" + j + "\">" + optionText + "</option>";
                        }
                    });

                    if (iCount > 1) {
                        optionsHtml = "<option></option>" + optionsHtml;
                        $("#ddlidfsEditor").prop("disabled", "");
                    }
                    else {
                        $("#ddlidfsEditor").prop("disabled", "disabled");
                    }

                    $("#ddlidfsEditor").html(optionsHtml);

                    $("#ddlidfsEditor").prop("disabled", $("#ddlidfsParameterType").prop("disabled"));
                    $("#ddlidfsEditor").prop("readonly", $("#ddlidfsParameterType").prop("readonly"));
                },
                error: function (xml) {
                    alert(xml);
                }
            });
        }
    },

    fillDropDownList: function (controlId, referenceTypeName, accessoryCodes, selectedValue, bAppend) {
        $.ajax({
            type: 'Get',
            url: flexForm.BaseReferenceListUrl + "?ReferenceType=" + referenceTypeName + "&intHACode=" + accessoryCodes,
            dataType: "text",
            success: function (options) {
                var optionsHtml = "<option></option>";

                $($.parseJSON(options).results).each(function (i, j) {
                    if (j.id == selectedValue) {
                        optionsHtml += "<option value=\"" + j.id + "\" selected>" + j.text + "</option>";
                    }
                    else {
                        optionsHtml += "<option value=\"" + j.id + "\">" + j.text + "</option>";
                    }
                });

                if (bAppend) {
                    optionsHtml = $("#" + controlId).html() + optionsHtml;
                }

                $("#" + controlId).html(optionsHtml);
            },
            error: function (xml) {
            }
        });
    },

    restoreOriginalDetails: function () {
        if ($("#dSectionForm").is(":visible")) {
            var idfsSection = $("#hdnCurrentidfsSection").val();
            $("[idfs='" + idfsSection + "']").click();
        }

        if ($("#dParameterForm").is(":visible")) {
            var idfsParameter = $("#hdnCurrentidfsParameter").val();
            $("[idfs='" + idfsParameter + "']").click();
        }

        flexForm.selectTreeViewItem();
    },

    updateItem: function () {
        if ($("#dSectionForm").is(":visible")) {
            flexForm.updateSection();
        }

        if ($("#dParameterForm").is(":visible")) {
            flexForm.bParameter = true;
            flexForm.updateParameter();
        }
    },

    clearParameterFields: function () {
        $("#txtDefaultLongName,#txtDefaultName,#txtNationalLongName,#txtNationalName").val("");
        $("#ddlidfsEditor,#ddlidfsParameterType").val(-1);

        $(flexForm.parameterFields).removeAttr("disabled").remove("readonly").css("background-color", "");
    },

    clearSectionFields: function () {
        $("#txtDefaultLongNameSection").val("");
        $("#txtDefaultNameSection").val("");
        $("#txtFullPathSection").val("");
        $("#txtNationalLongNameSection").val("");
        $("#txtNationalNameSection").val("");
        $("#sDisplayType").val(-1);
    },

    clearTemplateFields: function () {
        $("#dTemplateDesign,#dDeterminantList").html("");
        $("#txtTemplateDefaultName,#txtTemplateIsUNITemplate,#txtTemplateNationalName,#txtTemplateNote").val("");
        $("#txtTemplateIsUNITemplate").prop("checked", false);
    },

    loadParameter: function (idfsParameter, fullPath) {
        if ($("a.active").attr("editmode") != "Template") {
            flexForm.enableContainer("Parameter");

            $("#dSectionForm").hide();
            $("#dParameterForm,#btnSubmit,#btnCancel").show();
        }

        $("#hdnCurrentidfsParameter").val(idfsParameter);

        flexForm.GetTemplatesByParameter(idfsParameter);
        $.ajax({
            type: 'GET',
            url: flexForm.GetParameterDetailsUrl,
            data: {
                idfsParameter: idfsParameter
            },
            dataType: "json",
            success: function (json) {
                var isUsed = false;
                var colorUsed = "";

                $("#txtFullPath").val(fullPath);
                $(json).each(function (i, j) {
                    $("#txtDefaultLongName").val(j.defaultLongName);
                    $("#txtDefaultName").val(j.defaultName);
                    $("#txtNationalLongName").val(j.nationalLongName);
                    $("#txtNationalName").val(j.nationalName);

                    flexForm.fillDropDownList("ddlidfsParameterType", "Flexible Form Parameter Type", "226", j.idfsParameterType);
                    flexForm.getEditorList(j.idfsParameterType, j.idfsEditor);

                    if (j.parameterUsed == 1) {
                        isUsed = true;
                        colorUsed = "lightgrey";
                    }
                });

                $("#txtFullPath").attr(
                    {
                        "disabled": "disabled",
                        "readonly": "readonly"
                    }
                );

                $("#txtFullPath").css("background-color", "lightgrey");

                $(flexForm.parameterFields).css("background-color", colorUsed);
                if (isUsed) {
                    $(flexForm.parameterFields).attr(
                        {
                            "disabled": "disabled",
                            "readonly": "readonly"
                        }
                    );
                }
                else {
                    $(flexForm.parameterFields).removeAttr("disabled").removeAttr("readonly");
                }
            },
            error: function (xml) {
            }
        });
    },

    loadSection: function (idfsSection, fullPathSection, fullPathParameter) {
        if ($("a.active").attr("editmode") != "Template") {
            flexForm.enableContainer("Section");
            $("#dSectionForm,#btnSubmit,#btnCancel").show();
            $("#dParameterForm,#btnAddParameter").hide();
        }

        $.ajax({
            type: 'POST',
            url: flexForm.GetSectionDetailsUrl,
            data: {
                idfsSection: idfsSection
            },
            dataType: "json",
            success: function (json) {
                $("#txtFullPathSection,#txtParentSection,#txtFullPath").val(fullPathSection);

                $(json).each(function (i, j) {
                    $("#txtDefaultLongNameSection").val(j.defaultLongName);
                    $("#txtDefaultNameSection").val(j.defaultName);
                    $("#txtNationalLongNameSection").val(j.nationalLongName);
                    $("#txtNationalNameSection").val(j.nationalName);

                    $("#idfsSectionParentSection").val(j.idfsParentSection);
                    $("#idfsSectionFormType").val(j.idfsFormType);
                    $("#intSectionOrder").val(j.intOrder);
                    $("#blnSectionGrid").val(j.blnGrid);

                    if (j.blnFixedRowSet) {
                        $("#cbEnableCopyPaste").prop("checked", "checked");
                    }
                    else {
                        $("#cbEnableCopyPaste").prop("checked", "");
                    }

                    $("#idfsSectionMatrixType").val(j.idfsMatrixType);

                    switch (j.blnGrid) {
                        case "10525000":
                            $("#blnSectionGrid").val(1);
                        case "10525001":
                            $("#blnSectionGrid").val(0);
                    }

                    $("#txtFullPathSection,#txtFullPath").attr(
                        {
                            "disabled": "disabled",
                            "readonly": "readonly"
                        }
                    );

                    $("#txtFullPathSection,#txtFullPath").css("background-color", "lightgrey");

                    var displayTypeValue = 0;

                    if (j.blnGrid == "0") {
                        displayTypeValue = "10525001"
                    }
                    else {
                        displayTypeValue = "10525000"
                    }
                    flexForm.fillDropDownList("sDisplayType", "Flexible Form Section Type", "0", displayTypeValue);
                    $("#sDisplayType").select2({
                        placeholder: "",
                        allowClear: true,
                        width: 250
                    });
                });
            },
            error: function (xml) {
            }
        });
    },

    loadForm: function (idfsFormType) {
        flexForm.enableContainer("Template");

        $("[idfs]").css("background-color", "");
        $("[idfsSelected='true']").removeAttr("idfsSelected");

        $("[idfs='" + idfsFormType + "']").css("background-color", "#ffffaa");
        $("[idfs='" + idfsFormType + "']").attr("idfsSelected", "true");

        $("#iAddTemplate").removeClass("disabled");
        $("#iDeleteTemplate,#iShowTemplateParameters").addClass("disabled");

        if (flexForm.createWritePermission == 'true') {
            $("#EIDSSBodyCPH_aAddTemplate").show();
        }
        else {
            $("#EIDSSBodyCPH_aAddTemplate").hide();
        }

        $("#dTemplateParameterButtons").hide();
        $("#hdnCurrentidfsFormType").val(idfsFormType);
    },

    showAddSection: function () {
        if ($("#iAddSection").hasClass("disabled")) { return false; }

        flexForm.fillDropDownList("sSectionDisplayType", "Flexible Form Section Type", "0", 10525001);

        $("#sSectionDisplayType").select2({
            placeholder: "",
            allowClear: true,
            width: 400
        });

        flexForm.enableContainer("Section");
        $("#txtSectionDefaultName,#txtSectionNationalName").val("");

        $("#dAddSection").modal({ show: true, backdrop: 'static' });
    },

    showDeleteSection: function () {
        if (!$("#iDeleteSection").hasClass("disabled")) {
            $("#btnDeleteParameter,#deleteSectionWarning,#deleteParameterWarning").hide();
            $("#btnDeleteSection,#deleteSectionWarning").show();
            $("#dWarningModalContainer").modal('show');
        }
    },

    showAddParameter: function () {
        if ($("#iAddParameter").hasClass("disabled")) { return false; }

        $("#ddlidfsParameterType,#ddlidfsEditor").select2("val", 0);

        flexForm.enableContainer("Parameter");
        flexForm.clearParameterFields();

        $("#dSectionForm").hide();
        $("#dParameterForm,#btnSubmit,#btnCancel").show();

        $("#btnAddParameter,#dParameterForm").removeClass("disabled").addClass("flex-form-pointer");
        $("#hHeaderTitle")[0].scrollIntoView();
        $("#ddlidfsEditor").prop("disabled", "disabled");

        $("#txtDefaultLongName,#txtDefaultName,#ddlidfsEditor,#txtNationalLongName,#txtNationalName").css("background-color", "#FFFFBB").animate({ backgroundColor: "#FFFFFF" }, 1500).removeAttr("readonly");
    },

    showDeleteParameter: function () {
        if ($("#iDeleteParameter").hasClass("disabled")) { return false; }

        $("#btnDeleteSection,#deleteSectionWarning,#deleteParameterWarning").hide();
        $("#btnDeleteParameter,#deleteParameterWarning").show();
        $("#dWarningModalContainer").modal({ show: true, backdrop: 'static' });
    },

    showAddTemplate: function () {
        if ($("#iAddTemplate").hasClass("disabled")) { return false; }

        flexForm.clearTemplateFields();

        $("#dTemplateEditor")[0].scrollIntoView();
        $("#hdnCurrentidfsFormTemplate").val("");

        $("#fsTemplateContainer,#dDeterminants").show();

        flexForm.GetDiseaseList();

        $("#txtTemplateDefaultName,#txtTemplateNationalName,#txtTemplateNote,#txtTemplateIsUNITemplate").css("background-color", "#FFFFBB").animate({ backgroundColor: "#FFFFFF" }, 1500);
    },

    showTemplateParameterDelete: function (idfsParameter) {
        $("#hdnCurrentidfsParameter").val(idfsParameter);

        $("[ruleParameter],[deleteParameter],[downParameter],[upParameter]").hide();
        $("[templateParameter]").css("background-color", "");

        $("[selectedForDelete]").each(function (i, j) {
            if (j.id != "dParameter" + idfsParameter) {
                $(j).removeAttr("selectedForDelete");
            }
        });

        if ($("#dParameter" + idfsParameter).attr("selectedForDelete") == "true") {
            $("[downParameter],[upParameter]").show();
            $("#dParameter" + idfsParameter).removeAttr("selectedForDelete");
        }
        else {
            $("#imgRule" + idfsParameter).toggle();
            $("#imgDelete" + idfsParameter).toggle();
            $("#imgUp" + idfsParameter).toggle();
            $("#imgDown" + idfsParameter).toggle();
            $("#dParameter" + idfsParameter).css("background-color", "lightgrey").attr("selectedForDelete", "true");
        }
    },

    showTemplates: function () {
        if ($("#iShowTemplates").hasClass("disabled")) { return false; }
        $("#iShowTemplates").addClass("disabled");

        if ($("#hdnCurrentidfsFormTemplate").val()) {
            $("#iShowTemplateParameters").removeClass("disabled");
            flexForm.bringTreeViewIntoView("nav-templates", $("#hdnCurrentidfsFormTemplate").val());
        }

        $("#dTemplateRules,#dTemplateParameters").hide();
        $("#dFormTemplates,#dTemplateButtons").show();

        flexForm.enableContainer('Template');
    },

    showTemplateParameters: function () {
        if ($("#iShowTemplateParameters").hasClass("disabled")) { return false; }

        $("#iShowTemplateParameters,#iDeleteTemplate").addClass("disabled");
        $("#iShowTemplates").removeClass("disabled");

        $("#dTemplateRules,#dFormTemplates").hide();
        $("#dTemplateParameters").show();

        $("#hdnEditingMode").val("Template");

        var idfsFormType = $("#hdnCurrentidfsFormType").val();
        var name = $("#dFormTemplates span[idfs=" + idfsFormType + "]").text();
        var html = "<img name=\"" + idfsFormType + "\" src='" + flexForm.ImageURL + "/treeViewForm-plus.png' loaded=false onclick=\"flexForm.getTemplateParameterTreeContent(" + idfsFormType + " , undefined, $(this).attr('loaded'));\" />" +
            "<span class=\"templateParameterTreeViewItem\" idfs=\"" + idfsFormType + "\" type=\"Form\" onclick=\"flexForm.selectTemplateParameterTreeViewItem(this);\">" + name + "</span>" +
            "<ul name=\"" + idfsFormType + "\"></ul>";

        $("#liTemplateParameters").html(html);
    },

    showTemplateRulesTree: function () {
    },

    copyTemplate: function () {
        if ($("#iCopyTemplate").hasClass("disabled")) { return false; }

        $.ajax({
            type: 'GET',
            url: flexForm.CopyTemplateUrl,
            data: {
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val()
            },
            dataType: "json",
            success: function (json) {
                flexForm.reloadNode();
            },
            complete: function (json) {
                flexForm.reloadNode();
            }
        });
    },

    copyTreeviewNode: function () {
        if ($("#iCopyTreeviewNode").hasClass("disabled")) { return false; }

        $("#hdnidfsSectionCopy,#hdnidfsParameterCopy").val("");

        switch ($("#hdnCurrentItemType").val()) {
            case "Section":
                $("#hdnidfsSectionCopy").val($("#hdnCurrentidfsSection").val());
                break;
            case "Parameter":
                $("#hdnidfsParameterCopy").val($("#hdnCurrentidfsParameter").val());
                break;
        }

        $("#iPasteTreeviewNode").removeClass("disabled").addClass("flex-form-pointer");

        return false;
    },

    pasteTreeviewNode: function () {
        if ($("#iPasteTreeviewNode").hasClass("disabled")) { return false; }

        $.ajax({
            type: 'POST',
            url: flexForm.PasteTreeViewNodeUrl,
            data: {
                idfsParameter: $("#hdnidfsParameterCopy").val(),
                idfsSection: $("#hdnidfsSectionCopy").val(),
                idfsSectionDestination: $("#hdnCurrentidfsSection").val(),
                idfsFormTypeDestination: $("#hdnCurrentidfsFormType").val()
            },
            dataType: "json",
            success: function (ret) {
                flexForm.reloadNode();
            },
            complete: function (xml) {
                flexForm.reloadNode();
            }
        });

        $("#hdnidfsFormTypeCopy,#hdnidfsSectionCopy,#hdnidfsParameterCopy").val("");

        return false;
    },

    addTemplate: function () {
        var bUni = $("#txtTemplateIsUNITemplate").is(":checked");
        var idfsFormTemplate = $("#hdnCurrentidfsFormTemplate").val();

        if (idfsFormTemplate == "") {
            idfsFormTemplate = -1;
        }

        $.ajax({
            type: 'POST',
            url: flexForm.SetTemplateUrl,
            data: {
                idfsFormType: $("#hdnCurrentidfsFormType").val(),
                idfsFormTemplate: idfsFormTemplate,
                NationalName: $("#txtTemplateNationalName").val(),
                DefaultName: $("#txtTemplateDefaultName").val(),
                strNote: $("#txtTemplateNote").val(),
                blnUni: bUni
            },
            dataType: "json",
            success: function (json) {
                $("#hdnCurrentidfsFormTemplate").val(json.idfsFormTemplate);

                if ($("#hdnSetDeterminant").val() == "SET") {
                    $("#hdnSetDeterminant").val("");
                    flexForm.setDeterminant();
                }
                else {
                    flexForm.reloadNode();
                    $("#dSuccessModalTemplateSaved").modal({ show: true, backdrop: 'static' });
                }
            },
            complete: function (json) {
                flexForm.reloadNode();
            }
        });
    },

    deleteTemplate: function () {
        if ($("#iDeleteTemplate").hasClass("disabled")) { return false; }

        var idfsCurrentFormTemplate = $("#hdnCurrentidfsFormTemplate").val();
        $("#hdnCurrentidfsFormTemplate").val("");

        $.ajax({
            type: 'POST',
            url: flexForm.DeleteTemplateUrl,
            data: {
                idfsFormTemplate: idfsCurrentFormTemplate
            },
            dataType: "json",
            success: function (json) {
                $($("[name='" + idfsCurrentFormTemplate + "']").parent().parent().parent().find("img")[0]).attr("loaded", false).click();
                flexForm.selectTreeViewItem();
            },
            complete: function (json) {
                $($("[name='" + idfsCurrentFormTemplate + "']").parent().parent().parent().find("img")[0]).attr("loaded", false).click();
                flexForm.selectTreeViewItem();
            }
        });
    },

    loadTemplate: function (idfsFormTemplate) {
        if (idfsFormTemplate == undefined) {
            idfsFormTemplate = $("#hdnCurrentidfsFormTemplate").val();
        }

        if (idfsFormTemplate != '') {
            $("[idfs]").css("background-color", "");
            $("#fsTemplateContainer").show();

            $("[idfs='" + idfsFormTemplate + "']").css("background-color", "#ffffaa");

            $("#iDeleteTemplate,#iShowTemplateParameters").removeClass("disabled");
            $("#iAddTemplate").addClass("disabled");

            if (flexForm.createWritePermission == 'true') {
                $("#EIDSSBodyCPH_aAddTemplateParameter").show();
            }
            else {
                $("#EIDSSBodyCPH_aAddTemplateParameter").hide();
            }

            if (flexForm.deletePermission == 'true') {
                $("#EIDSSBodyCPH_g9").show();
            }
            else {
                $("#EIDSSBodyCPH_g9").hide();
            }

            $.ajax({
                type: 'POST',
                url: flexForm.GetTemplateDetailsUrl,
                data: {
                    idfsFormTemplate: idfsFormTemplate
                },
                dataType: "json",
                success: function (json) {
                    flexForm.clearTemplateFields();
                    if (json != "") {
                        $("#hdnCurrentidfsFormTemplate").val(idfsFormTemplate);
                        $("#hdnCurrentidfsFormType").val(json.idfsFormType);
                        $("#txtTemplateDefaultName").val(json.formTemplate);
                        $("#txtTemplateNationalName").val(json.nationalName);

                        $("#dDeterminants").hide();

                        if (json.blnUNI) {
                            $("#txtTemplateIsUNITemplate").prop("checked", "checked");
                        }
                        else {
                            $("#txtTemplateIsUNITemplate").prop("checked", "");
                            $("#dDeterminants").show();
                        }

                        $("#txtTemplateNote").val(json.strNote);

                        $.ajax({
                            type: 'POST',
                            url: flexForm.GetTemplateDesignUrl,
                            data: {
                                idfsFormTemplate: idfsFormTemplate
                            },
                            dataType: "html",
                            success: function (html) {
                                $("#dTemplateDesign").html(html);
                                flexForm.GetDiseaseList();
                            },
                            error: function (xml) {
                            }
                        });

                        flexForm.GetTemplateDeterminants(idfsFormTemplate);
                        flexForm.toggleAddDeterminant();
                    }
                    else {
                    }
                },
                error: function (xml) {
                }
            });
        }
    },

    addDeterminant: function () {
        $("#dDeterminantsEditor").modal('show');
    },

    SearchDeterminants: function (reset) {
        var html = "";

        if (reset) {
            $("#tCriteria").val("");
        }

        $("#sDiseaseList").find("option").each(function (i, j) {
            if ($(j).text().toLowerCase().match($("#tCriteria").val().toLowerCase()) != null) {
                $(j).removeAttr("style");
            }
            else {
                $(j).attr("style", "display:none");
            }
        });
        $("#SearchDeterminantsResults").html(html);
    },

    loadTemplateSectionParameters: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.GetTemplateSectionParameterListUrl,
            data: {
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val()
            },
            dataType: "html",
            success: function (html) {
                $("#dSectionParameters").html(html);
            },
            error: function (xml) {
            }
        });
    },

    GetTemplateDeterminants: function (idfsFormTemplate) {
        $.ajax({
            type: 'POST',
            url: flexForm.GetTemplateDeterminantsUrl,
            data: {
                idfsFormTemplate: idfsFormTemplate
            },
            dataType: "json",
            success: function (json) {
                var html = "";

                $(json).each(function (i, j) {
                    html += "<tr role=\"row\" class=\"odd\">"
                    html += "    <td>" + j.determinantNationalName + "</td><td class=\"icon\"><a id=\"btnTrash" + j.determinantValue + "\" class=\"fa fa-trash\"  href=\"#\" onclick=\"flexForm.deleteDeterminant(" + j.determinantValue + ");return false;\"></a></td>"
                    html += "</tr >"
                });
                $("#dDeterminantList").html(html);
            },
            error: function (xml) {
            }
        });
    },

    GetTemplatesByParameter: function (idfsParameter) {
        $.ajax({
            type: 'POST',
            url: flexForm.GetTemplatesByParameterUrl,
            data: {
                idfsParameter: idfsParameter
            },
            dataType: "json",
            success: function (json) {
                var html = "";

                $(json).each(function (i, j) {
                    html += "<tr><td><button class='btn btn-link' onclick=\"flexForm.enableContainer('Template');flexForm.loadTemplate(" + j.idfsFormTemplate + ");\">" + j.nationalName + "</a></td></tr>";
                });
                $("#dTemplatesUsedByParameter").html(html);
            }
        });
    },

    copyParameterTreeView: function () {
        $("#dParametersBackup").html($("#EIDSSBodyCPH_tvParameters").html());
    },

    deleteParameter: function () {
        var idfsParameter = $("#hdnCurrentidfsParameter").val();
        $.ajax({
            type: 'POST',
            url: flexForm.DeleteParameterUrl,
            data: {
                idfsParameter: idfsParameter
            },
            dataType: "json",
            success: function (json) {
            },
            complete: function (response) {
                $("#dWarningModalContainer").modal('hide');

                switch (JSON.parse(response.responseText)[0].returnMessage) {
                    case "ParameterRemove_Has_ffParameterForTemplate_Rows":
                    case "ParameterRemove_Has_tlbActivityParameters_Rows":
                        $("#errorBody").html(JSON.parse(response.responseText)[0].resultMessage);
                        $("#dDeleteError").modal('show');
                        break;
                    default:
                        $("[idfs='" + idfsParameter + "'][type='Parameter']").parent().remove();
                        break;
                }

                if ($("[idfs='" + $("#hdnCurrentidfsSection").val() + "']").parent().find("ul").html() == '') {
                    $("[name='" + $("#hdnCurrentidfsSection").val() + "']").attr("src", flexForm.ImageURL + "/treeViewSection.png");
                }
            }
        });
    },

    deleteSection: function () {
        var idfsSection = $("#hdnCurrentidfsSection").val();

        $.ajax({
            type: 'POST',
            url: flexForm.DeleteSectionUrl,
            data: {
                idfsSection: idfsSection,
                intRowStatus: 1
            },
            dataType: "json",
            success: function (json) {
                $("#dWarningModalContainer").modal('hide');
                $("[idfs='" + idfsSection + "'][type='Section']").parent().remove();
            },
            complete: function (response) {
                $("#dWarningModalContainer").modal('hide');
                $("[idfs='" + idfsSection + "'][type='Section']").parent().remove();
            }
        });
    },

    setDeterminant: function (intRowStatus) {
        if ($("#hdnCurrentidfsFormTemplate").val() != '') {
            $.ajax({
                type: 'POST',
                url: flexForm.SetDeterminantUrl,
                data: {
                    idfsDiagnosisGroupList: $("#sDiseaseList").val(),
                    idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val(),
                    intRowStatus: intRowStatus
                },
                dataType: "json",
                success: function (json) {
                    flexForm.GetTemplateDeterminants($("#hdnCurrentidfsFormTemplate").val());
                    $("#dDeterminantsEditor").modal('hide');
                },
                complete: function (xml) {
                    flexForm.GetTemplateDeterminants($("#hdnCurrentidfsFormTemplate").val());
                    $("#dDeterminantsEditor").modal('hide');
                }
            });
        }
        else {
            $("#hdnSetDeterminant").val("SET");
            flexForm.addTemplate();
            $("#dDeterminantsEditor").modal('hide');
        }
    },

    deleteDeterminant: function (idfsDiagnosisGroup) {
        $.ajax({
            type: 'POST',
            url: flexForm.SetDeterminantUrl,
            data: {
                idfsDiagnosisGroupList: idfsDiagnosisGroup,
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val(),
                intRowStatus: 1
            },
            dataType: "json",
            success: function (json) {
                var test = "";
            },
            complete: function (xml) {
                $("#btnTrash" + idfsDiagnosisGroup).parent().parent().remove();
            }
        });
    },

    closeWarning: function (modalId) {
        $("#" + modalId).modal('hide');
    },

    closeAddSection: function () {
        $("#dAddSection").modal('hide');
    },

    closeAddParameter: function () {
        $("#dAddParameter").modal('hide');
    },

    addSection: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.SetSectionUrl,
            data: {
                idfsParentSection: $("#hdnCurrentidfsSection").val(),
                idfsFormType: $("#hdnCurrentidfsFormType").val(),
                DefaultName: $("#txtSectionDefaultName").val(),
                NationalName: $("#txtSectionNationalName").val(),
                intOrder: 0,
                blnGrid: $("#blnSectionGrid").val(),
                blnFixedRowSet: $("#cbEnableCopyPaste").is(":checked")
            },
            dataType: "json",
            success: function (json) {
                $("#dAddSection").modal('hide');
                flexForm.reloadNode();
            },
            complete: function (xml) {
            }
        });
    },

    updateSection: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.SetSectionUrl,
            data: {
                idfsSection: $("#hdnCurrentidfsSection").val(),
                idfsParentSection: $("#idfsSectionParentSection").val(),
                idfsFormType: $("#hdnCurrentidfsFormType").val(),
                DefaultName: $("#txtDefaultNameSection").val(),
                NationalName: $("#txtNationalNameSection").val(),
                intOrder: $("#intSectionOrder").val(),
                blnGrid: $("#sDisplayType").val() == "10525001" ? false : true,
                blnFixedRowSet: $("#cbEnableCopyPaste").is(":checked"),
                intRowStatus: 0
            },
            dataType: "json",
            success: function (json) {
                flexForm.reloadNode();
            },
            complete: function (xml) {
            }
        });
    },

    updateParameter: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.SetParameterUrl,
            data: {
                idfsFormType: $("#hdnCurrentidfsFormType").val(),
                idfsParameter: $("#hdnCurrentidfsParameter").val(),
                idfsSection: $("#hdnCurrentidfsSection").val(),
                DefaultName: $("#txtDefaultName").val(),
                NationalName: $("#txtNationalName").val(),
                DefaultLongName: $("#txtDefaultLongName").val(),
                NationalLongName: $("#txtNationalLongName").val(),
                idfsEditor: $("#ddlidfsEditor").val(),
                idfsParameterType: $("#ddlidfsParameterType").val(),
                displayType: $("#sDisplayType").val(),
                intRowStatus: 0
            },
            dataType: "json",
            success: function (json) {
                flexForm.reloadNode();
            },
            complete: function (xml) {
            },
            error: function (xml) {
            }
        });
    },

    reloadNode: function () {
        var idfs = $("#hdnCurrentidfsSection").val();

        switch ($("#hdnCurrentItemType").val()) {
            case "Form":
                $("[name=" + $("#hdnCurrentidfsFormType").val() + "]:visible").attr("loaded", false).click();
                break;
            case "Template":
                $("[name=" + $("#hdnCurrentidfsFormType").val() + "]").attr("loaded", false).click();
                break;
            case "Section":
                var idfsParent = $("img[name='" + idfs + "']").parent().parent().attr("name");
                if (flexForm.bParameter) {
                    $("img[name='" + $("#hdnCurrentidfsSection").val() + "']").attr("loaded", false).click();
                    flexForm.bParameter = false;
                }
                else {
                    $("img[name='" + idfsParent + "']").attr("loaded", false).click();
                }
                break;
            case "Parameter":
                $("[name=" + idfs + "]").attr("loaded", false).click();
                break;
        }
    },

    deleteTemplateParameter: function () {
        $("#dWarningDeleteTemplateParameter").modal('show');
    },

    deleteTemplateParameterConfirmed: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.DeleteTemplateParameterUrl,
            data: {
                idfsParameter: $("#hdnCurrentidfsParameter").val(),
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val()
            },
            dataType: "text",
            success: function (json) {
                if (($.parseJSON(json)).used == 0) {
                    flexForm.loadTemplate();
                }
                else {
                    alert("Parameter is in use. Cannot delete.");
                }
            },
            error: function () {
            }
        });

        $("#dWarningDeleteTemplateParameter").modal('hide');
    },

    addTemplateParameter: function () {
        if ($("#iAddTemplateParameter").hasClass("disabled")) { return false; }

        $.ajax({
            type: 'POST',
            url: flexForm.SetTemplateParameterUrl,
            data: {
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val(),
                idfsParameter: $("#hdnCurrentidfsParameter").val(),
                idfsSection: $("#hdnCurrentidfsSection").val()
            },
            dataType: "text",
            success: function (json) {
                flexForm.loadTemplate();
            },
            error: function (xml) {
                flexForm.loadTemplate();
            }
        });

        return false;
    },

    IsParameterAnswered: function (idfsParameter, idfsFormTemplate) {
        $.ajax({
            type: 'POST',
            url: flexForm.IsParameterAnsweredUrl,
            data: {
                idfsParameter: idfsParameter,
                idfsFormTemplate: idfsFormTemplate
            },
            dataType: "text",
            success: function (isUsed) {
                return isUsed;
            },
            error: function () {
                return true;
            }
        });
    },

    GetDeterminants: function (idfsFormType) {
        $.ajax({
            type: 'POST',
            url: flexForm.GetDeterminantsUrl,
            data: {
                idfsFormType: idfsFormType
            },
            dataType: "json",
            success: function (json) {
                var html = "";
                $(json).each(function (i, j) {
                    html += "<a href='#' id='a" + j.idfDeterminantValue + "' idfsDeterminantValue='" + j.idfDeterminantValue + "' onclick='flexForm.setSelectedDeterminant(this);return false;'>" + j.name + "</a><br>";
                });

                $("#dDeterminantsList").html(html);
            },
            complete: function (xml) {
            }
        });
    },

    toggleAddDeterminant: function () {
        if ($("#txtTemplateIsUNITemplate").prop("checked")) {
            $("#dDeterminants").hide();
        }
        else {
            $("#dDeterminants").show();
        }
    },

    setSelectedDeterminant: function (obj) {
        $("#dDeterminantsList a").css("background-color", "");
        $(obj).css("background-color", "lightgrey");
        $("#hdnCurrentidfsDeterminantValue").val($(obj).attr("idfsDeterminantValue"));
    },

    moveTemplateParameter: function (idfsFormTemplate, idfsCurrentParameter, idfsDestinationParameter, direction) {
        $.ajax({
            type: 'POST',
            url: flexForm.MoveTemplateParameterUrl,
            data: {
                idfsFormTemplate: idfsFormTemplate,
                idfsCurrentParameter: idfsCurrentParameter,
                idfsDestinationParameter: idfsDestinationParameter,
                Direction: direction
            },
            dataType: "text",
            success: function (ret) {
                flexForm.loadTemplate();
            },
            complete: function (xml) {
                flexForm.loadTemplate();
            }
        });
    },

    moveTemplateSection: function (idfsFormTemplate, idfsCurrentSection, idfsSectionDestination) {
        $.ajax({
            type: 'POST',
            url: flexForm.MoveTemplateSectionUrl,
            data: {
                idfsFormTemplate: idfsFormTemplate,
                idfsCurrentSection: idfsCurrentSection,
                idfsDestinationSection: idfsSectionDestination
            },
            dataType: "text",
            success: function (ret) {
                flexForm.loadTemplate();
            },
            complete: function (xml) {
            }
        });
    },

    addToOutbreak: function (idfOutbreakSpeciesParameterUID) {
        var idfsFormType = $("#hdnCurrentidfsFormType").val();
        var strFormCategory = "";
        var idfsFormTemplate = $("#hdnCurrentidfsFormTemplate").val();

        switch (parseInt(idfsFormType)) {
            case 10034501:
            case 10034502:
            case 10034503:
                strFormCategory = "Questionnaire";
                break;
            case 10034504:
            case 10034505:
            case 10034506:
                strFormCategory = "Monitoring";
                break;
            case 10034507:
            case 10034508:
            case 10034509:
                strFormCategory = "Tracing";
                break;
        }

        $.ajax({
            type: 'POST',
            url: flexForm.AddToOutbreakUrl,
            data: {
                idfOutbreakSpeciesParameterUID: idfOutbreakSpeciesParameterUID,
                strFormCategory: strFormCategory,
                idfsFormTemplate: idfsFormTemplate
            },
            dataType: "text",
            success: function (ret) {
            },
            complete: function (xml) {
                $('#dSuccessModal').modal('show').show();
            }
        });
    },

    clearRuleForm: function () {
        $("#hdnidfsRule,#hdnidfsRuleMessage").val("-1");
        $("#ddlidfsRule").val(-1);
        $("#ddlidfsRuleAction,#ddlidfsCheckPoint,#ddlidfsRuleFunction").select2("val", -1);
        $("#txtRuleDefaultName,#txtRuleNationalName,#txtRuleMessageText,#txtRuleMessageNationalText,#txtstrFillValue").val("");
        $("#cbRuleNot").prop("checked", "");
        $("[fftype='Parameter'],[fftype='Section']").prop("checked", "");

        $("#trFillWithValue").hide();

        $("#dSectionParameters").parent().attr("style", "");
        $("#ddlidfsCheckPoint,#ddlidfsRuleFunction,#ddlidfsRuleAction,#ddlidfsRuleAction,#txtRuleDefaultName,#txtRuleMessageText").attr("style", "");

        var idfsParameter = $("#hdnidfsFunctionParameter").val();
        var parameterText = ($("#dParameter" + idfsParameter).text()).trim();
        var templateText = ($("#txtTemplateNationalName").val()).trim()
        $("#txtRuleName,#txtRuleNationalName").val(templateText + " - " + parameterText + " 'NewRule1'");
    },

    addRuleParameter: function (idfsParameter) {
        flexForm.clearRuleForm();

        var parameterText = ($("#dParameter" + idfsParameter).text()).trim();
        var templateText = ($("#txtTemplateNationalName").val()).trim()

        $("#hdnidfsFunctionParameter").val(idfsParameter);
        $("#txtRuleDefaultName,#txtRuleNationalName").val(templateText + " - " + parameterText + " 'NewRule1'");

        $("#btnRuleAdd").show();
        $("#btnRuleDelete").hide();

        $("#dRulesEditor").modal("show");
        flexForm.loadTemplateSectionParameters();
        flexForm.getRulesForDropDown(idfsParameter);
    },

    setRequiredParameter: function (idfsParameter, idfsEditMode) {
        $.ajax({
            type: 'POST',
            url: flexForm.SetRequiredParameterUrl,
            data: {
                idfsParameter: idfsParameter,
                idfsEditMode: idfsEditMode,
                idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val()
            },
            dataType: "text",
            success: function (options) {
                flexForm.loadTemplate();
            },
            complete: function (xml) {
                flexForm.loadTemplate();
            }
        });
    },
    getRulesForDropDown: function (idfsParameter) {
        $.ajax({
            type: 'POST',
            url: flexForm.GetRulesForParameterUrl,
            data: {
                idfsFunctionParameter: idfsParameter
            },
            dataType: "text",
            success: function (options) {
                $("#ddlidfsRule").html(options);
            },
            complete: function (xml) {
            }
        });
    },

    showRuleDetails: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.GetRuleDetailsUrl,
            data: {
                idfsRule: $("#ddlidfsRule").val()
            },
            dataType: "json",
            success: function (response) {
                flexForm.clearRuleForm();

                if (response != undefined) {
                    $("#ddlidfsRule").val(response.idfsRule);
                    $("#ddlidfsRuleAction").val(response.idfsRuleAction).select2();
                    $("#ddlidfsCheckPoint").val(response.idfsCheckPoint).select2();
                    $("#ddlidfsRuleFunction").val(response.idfsRuleFunction).select2();
                    $("#txtRuleDefaultName").val(response.defaultRuleName);
                    $("#txtRuleNationalName").val(response.ruleName);
                    $("#txtRuleMessageText").val(response.defaultRuleMessage);
                    $("#txtRuleMessageNationalText").val(response.ruleMessage);
                    $("#hdnidfsRuleMessage").val(response.idfsRuleMessage);
                    $("#txtstrFillValue").val(response.fillValue);

                    if (response.blnNot) {
                        $("#cbRuleNot").prop("checked", "checked");
                    }
                    else {
                        $("#cbRuleNot").prop("checked", "");
                    }

                    if (response.strActionParameters != null) {
                        $(response.strActionParameters.split(',')).each(function (i, j) {
                            $("#cb" + j).prop("checked", "checked");
                        });
                    }

                    flexForm.setActionFields(response.idfsRuleAction);

                    if ($("#ddlidfsRule").val() != "-1") {
                        $("#btnRuleDelete").show();
                        $("#btnRuleAdd").hide();
                    }
                    else {
                        $("#btnRuleDelete").hide();
                        $("#btnRuleAdd").show();
                    }
                }
            },
            complete: function (xml) {
                if ($("#ddlidfsRule").val() != "-1") {
                    $("#btnRuleDelete").show();
                    $("#btnRuleAdd").hide();
                }
                else {
                    $("#btnRuleDelete").hide();
                    $("#btnRuleAdd").show();
                }
            }
        });
    },

    saveRule: function (bDelete) {
        var iRules = 0;
        var iSavedRules = 0;
        var strValidations = "";
        var strAPValidation = "";

        //Reset any validation marks that may exist
        $("#dSectionParameters").parent().attr("style", "");
        $("#ddlidfsCheckPoint,#ddlidfsRuleFunction,#ddlidfsRuleAction,#ddlidfsRuleAction,#txtRuleDefaultName,#txtRuleMessageText,#txtstrFillValue").attr("style", "");

        //Check if anything is selected in the "Action Paramters"
        if (!$("#dRulesEditor [ffType='Parameter']:checked").is(":checked")) {
            strAPValidation = "#dSectionParameters";
        }

        //Check all other fields
        if ($("#ddlidfsCheckPoint").val() == "-1") { strValidations += "#ddlidfsCheckPoint,"; }
        if ($("#ddlidfsRuleFunction").val() == "-1") { strValidations += "#ddlidfsRuleFunction,"; }
        if ($("#ddlidfsRuleAction").val() == "-1") { strValidations += "#ddlidfsRuleAction,"; }
        if ($("#txtRuleDefaultName").val() == "") { strValidations += "#txtRuleDefaultName,"; }
        if ($("#txtRuleMessageText").val() == "" && $("#ddlidfsRuleAction").val() == "10030003") { strValidations += "#txtRuleMessageText,"; }

        if ($("#ddlidfsRuleAction").val() == "10030004") {
            if ($("#txtstrFillValue").val() == "") { strValidations += "#txtstrFillValue,"; }
        }

        if (strValidations != "" || strAPValidation != "") {
            strValidations = (strValidations + ".").replace(",.", "");

            $(strAPValidation).parent().attr("style", "border:solid 2px red");
            $(strValidations).attr("style", "border:solid 2px red");
        }
        else {
            $("#dRulesEditor [ffType='Parameter']:checked").each(function (i, j) {
                iRules++;
                $.ajax({
                    type: 'POST',
                    url: flexForm.SaveRuleUrl,
                    data: {
                        idfsFormTemplate: $("#hdnCurrentidfsFormTemplate").val(),
                        idfsCheckPoint: $("#ddlidfsCheckPoint").val(),
                        idfsRuleFunction: $("#ddlidfsRuleFunction").val(),
                        idfsRuleAction: $("#ddlidfsRuleAction").val(),
                        DefaultName: $("#txtRuleDefaultName").val(),
                        NationalName: $("#txtRuleNationalName").val(),
                        MessageText: $("#txtRuleMessageText").val(),
                        MessageNationalText: $("#txtRuleMessageNationalText").val(),
                        RuleInversion: $("#cbRuleNot").val(),
                        idfsRule: $("#ddlidfsRule").val(),
                        idfsRuleMessage: $("#hdnidfsRuleMessage").val(),
                        idfsActionParameter: ($(j).attr("id")).replace("cb", ""),
                        idfsFunctionParameter: $("#hdnidfsFunctionParameter").val(),
                        strFillValue: $("#txtstrFillValue").val(),
                        FunctionCall: 0,
                        CopyOnly: 0,
                        blnNot: $("#cbRuleNot").is(":checked"),
                        intRowStatus: bDelete == true ? 1 : 0
                    },
                    dataType: "text",
                    success: function (ret) {
                        if (bDelete) {
                            $("#btnRuleDelete").hide();
                            $("#btnRuleAdd").show();
                            $("#divConfirmRuleDeletion").modal('hide');
                        }
                    },
                    complete: function (xml) {
                        if (++iSavedRules == iRules) {
                        }
                    }
                });
            });
            if (bDelete) {
                $("#ddlidfsRule option[value='" + $("#ddlidfsRule").val() + "']").remove();
                flexForm.clearRuleForm();
            }
            else {
                $("#btnRuleCancel").click();
            }
        }
    },

    bringTreeViewIntoView: function (tv, idfs) {
        $(document).ready(function () {
            $("#" + tv)[0].scrollIntoView();
            $("[idfs='" + idfs + "']")[0].scrollIntoView();
            flexForm.loadTemplate();
            flexForm.postReadyActions();
        });
    },

    clearSectionParameter: function () {
        $("#txtSection,#txtParameter").val("");
        location.reload();
    },

    toggleParameters: function (idfsSection) {
        if ($("#cb" + idfsSection).is(":checked")) {
            $("[idfsSection=" + idfsSection + "]").prop("checked", "checked");
        }
        else {
            $("[idfsSection=" + idfsSection + "]").prop("checked", "");
        }
    },

    setSectionSelection: function (idfsSection) {
        var bAllParametersSelected = true;

        $("[idfsSection=" + idfsSection + "]").each(function (i, j) {
            if (!$(j).is(":checked")) {
                bAllParametersSelected = false;
            }
        });

        if (bAllParametersSelected) {
            $("#cb" + idfsSection).prop("checked", "checked");
        }
        else {
            $("#cb" + idfsSection).prop("checked", "");
        }
    },

    setActionFields: function (idfsRuleAction) {
        if (idfsRuleAction == "10030004") {
            $("#trFillWithValue").show();
        }
        else {
            $("#trFillWithValue").hide();
        }
    },

    enableContainer: function (container) {
        $("#fsParameterContainer,#fsSectionContainer,#fsTemplateContainer").css({
            "pointer-events": "none",
            "background-color": "#dddddd"
        });

        $("#fs" + container + "Container").css({
            "pointer-events": "",
            "background-color": ""
        });

        $("#dParameterForm,#dSectionForm,#fsTemplateContainer").hide();
        $("#liParameters,#liTemplates").removeClass("active");

        switch (container) {
            case "Template":
                flexForm.showTemplates();
                $("#fsTemplateContainer").hide();
                $("#liTemplates").addClass('active');
                break;
            case "Parameter":
                $("#hdnEditingMode").val("Parameter");
                $("#dParameterForm").hide();
                $("#divParameterEditor").show();
                $("#liParameters").addClass('active');
                break;
            case "Section":
                break;
        }
    },

    GetDiseaseList: function () {
        var idfsFormType = $("#hdnCurrentidfsFormType").val();
        var idfsFormTemplate = $("#hdnCurrentidfsFormTemplate").val();

        $.ajax({
            type: 'POST',
            url: flexForm.BaseReferenceListUrl,
            data: {
                ReferenceType: 'Flexible Form Type',
                intHACode: 510
            },
            dataType: "json",
            success: function (json) {
                var intHACode = 510;

                $(json).each(function (i, j) {
                    if (j.idfsBaseReference == idfsFormType) {
                        intHACode = j.intHACode;
                        return false;
                    }
                });

                $.ajax({
                    type: 'POST',
                    url: flexForm.GetDeterminantDiseaseListUrl,
                    data: {
                        intHACode: intHACode ?? 510,
                        idfsFormType: idfsFormType,
                        idfsFormTemplate: idfsFormTemplate
                    },
                    dataType: "json",
                    success: function (json) {
                        var options = "";

                        $(json).each(function (i, j) {
                            if (j.idfsVectorType != undefined) {
                                options += "<option value='" + j.idfsDiagnosis + "'>" + j.strName + "</option>";
                            }
                            else {
                                options += "<option value='" + j.idfsDiagnosis + "'>" + j.strName + "</option>";
                            }
                        });

                        $("#sDiseaseList").html(options);
                    }
                });
            },
            complete: function (xml) {
            }
        });
    },

    searchSectionParameter: function () {
        $.ajax({
            type: 'POST',
            url: flexForm.GetSectionsParametersForSearchUrl,
            data: {
                parameterFilter: $("#txtParameter").val(),
                sectionFilter: $("#txtSection").val()
            },
            dataType: "html",
            success: function (html) {
                $("#dParameters").html(html);
            }
        });
    },

    setDisplayType: function (obj) {
        switch ($(obj).val()) {
            case "10525000":
                $("#blnSectionGrid").val(1);
            case "10525001":
                $("#blnSectionGrid").val(0);
        }
    },

    checkDisabled: function (id) {
        if ($("#" + id).hasClass("disabled")) {
            return false;
        }
        return true;
    }
}