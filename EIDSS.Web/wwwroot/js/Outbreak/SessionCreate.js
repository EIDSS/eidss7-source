var outbreakCreate = {
    diseaseEnableURL: '',
    saveUpdateURL: '',
    getUpdateURL: '',
    getUpdatesURL: '',
    humanCaseUrl: '',
    cancelAdvancedSearchUrl: '',

    init: function () {
        $("#btnSaveNote").click(function (e) {
            if (!$("#fUpdateEntry").valid()) {
                return true;
            }

            var formData = new FormData();

            var idfOutbreak =  $("#btnSaveNote").attr("idfOutbreak");
            var idfOutbreakNote =  $("#idfOutbreakNote").val();
            var UserName =  $("#UserName").val();
            var Organization =  $("#Organization").val();
            var UpdatePriorityID =  $("#UpdatePriorityID").val();
            var datNoteDate =  $("#datNoteDate").val();
            var UpdateRecordTitle =  $("#UpdateRecordTitle").val();
            var strNote =  $("#strNote").val();
            var UploadFileObject =  $("#UploadFileObject").val();
            var UploadFileDescription =  $("#UploadFileDescription").val();
            var fileInput = $('#FileUpload')[0];
            var file = fileInput.files[0];

            formData.append("idfOutbreak", idfOutbreak);
            formData.append("idfOutbreakNote", idfOutbreakNote);
            formData.append("UserName", UserName);
            formData.append("Organization", Organization);
            formData.append("UpdatePriorityID", UpdatePriorityID);
            formData.append("datNoteDate", datNoteDate);
            formData.append("UpdateRecordTitle", UpdateRecordTitle);
            formData.append("strNote", strNote);
            formData.append("UploadFileObject", UploadFileObject);
            formData.append("UploadFileDescription", UploadFileDescription);
            formData.append("FileUpload", file);


            $("#dOutbreakNoteForm").modal("hide");
            $.ajax({
                type: 'POST',
                url: outbreakCreate.saveUpdateURL,
                data: formData,
                processData: false,
                contentType: false,
                success: function (response) {
                    $("#liUpdates").click();
                }
            });

            e.preventDefault();
        });
    },

    DiseaseEnable: function () {
        if ($("#OutbreakTypeId").val() != "") {
            $("#idfsDiagnosisOrDiagnosisGroup").removeAttr("disabled");

            var intHACode = -1;

            $('#idfsDiagnosisOrDiagnosisGroup').select2().val("");

            switch ($("#OutbreakTypeId").val()) {
                case "10513001": intHACode = 2; break;
                case "10513002": intHACode = 96; break;
                case "10513003": intHACode = 98; break;
                default: intHACode = 510; break;
            }

            $('#idfsDiagnosisOrDiagnosisGroup').select2({
                ajax: {
                    url: outbreakCreate.diseaseEnableURL + '?intHACode=' + intHACode + '&idfsUsingType=10020001',
                    data: function (params) {
                        var query = {
                            term: params.term, page: params.page || 1
                        }
                        return query
                    }
                },
                width: '75%',
                theme: 'bootstrap',
                tags: false,
                closeOnSelect: true,
                allowClear: true,
                minimumInputLength: 0,
                multiple: false,
                placeholder: ' '
            });
        }
        else {
            $("#idfsDiagnosisOrDiagnosisGroup").attr("disabled", "disabled");
            outbreakCreate.showParameters();
        }

        outbreakCreate.showSpeciesAffected();
    },

    EndDateEnable: function () {
        if ($("#idfsOutbreakStatus").val() != "10063501") {
            $("#dDatCloseDate").show();
            if ($("#SessionDetails_datCloseDate").val() == "") {
                $("#SessionDetails_datCloseDate").datepicker('setDate', new Date($("#hdnToday").val()));
            }
        }
        else {
            $("#dDatCloseDate").hide();
            //$("#datCloseDate").val("");
            $("#SessionDetails_datCloseDate").datepicker('setDate', "");
        }
    },

    showSpeciesAffected: function () {
        $("#dSpeciesAffected").show();
        $("#idfscbHuman,#idfscbAvian,#idfscbLivestock,#idfscbVector").prop("checked", "");
        $("#idfscbHuman,#idfscbAvian,#idfscbLivestock,#idfscbVector").prop("disabled", "true");

        switch ($("#OutbreakTypeId").val()) {
            case "10513001": //Human
                $("#idfscbHuman").prop("checked", "true");
                $("#idfscbVector").prop("disabled", "");
                break;
            case "10513002": //Veterinary
                $("#idfscbAvian,#idfscbLivestock,#idfscbVector").prop("checked", "").prop("disabled", "");
                break;
            case "10513003": //Zoonotic
                $("#idfscbHuman").prop("checked", "true");
                $("#idfscbAvian,#idfscbLivestock,#idfscbVector").prop("disabled", "");
                break;
            default:
                $("#dSpeciesAffected").hide();
                break;
        }

        outbreakCreate.showParameters();
    },

    showParameters: function (obj, species) {
        $("[id^='dParametersidfscb'],#dParameters").hide();

        if (species != undefined) {
            //$("[Parameter]").val("");

            $("[type='number'][species='" + species + "']").each(function (i, j) {
                $(j).val("");
                if (($("#txt" + species + "CaseMonitoringDuration").val() != "" && $("#txt" + species + "CaseMonitoringDuration").val() != undefined) ||
                    $("#txt" + species + "ContactTracinDuration").val() != "" && $("#txt" + species + "ContactTracinDuration").val() != undefined) {
                    $("#idfscb" + species).removeAttr("disabled");
                    $("#idfscb" + species).prop("checked", true);
                }
            });
        }

        var bHuman = $("#idfscbHuman").is(":checked");
        var bAvian = $("#idfscbAvian").is(":checked");
        var bLivestock = $("#idfscbLivestock").is(":checked");
        var bVector = $("#idfscbVector").is(":checked");

        if (bHuman || bAvian || bLivestock) {
            $("#dParameters,#bSessionSaveButton").show();
        }
        else {
            $("#dParameters,#bSessionSaveButton").hide();
        }

        $("#bHuman,#bAvian,#bLivestock,#bVector").val(false);

        if (bHuman) { $("#dParametersidfscbHuman").show(); $("#bHuman").val(true); }
        if (bAvian) { $("#dParametersidfscbAvian").show(); $("#bAvian").val(true); }
        if (bLivestock) { $("#dParametersidfscbLivestock").show(); $("#bLivestock").val(true); }
        if (bVector) { $("#dParametersidfscbVector").show(); $("#bVector").val(true); }

        if (bHuman || bAvian || bLivestock) { $("#dParameters").show(); }

        outbreakCreate.checkVector();
    },

    checkVector: function () {
        if ($("#idfscbVector").is(":checked")) {
            var bHuman = false;
            var bAvian = false;
            var bLivestock = false;

            if ($("#idfscbHuman").is(":checked")) { bHuman = true; }
            if ($("#idfscbAvian").is(":checked")) { bAvian = true; }
            if ($("#idfscbLivestock").is(":checked")) { bLivestock = true; }

            if (!(bHuman || bAvian || bLivestock)) {
                $("#dSpeciesAffectedError").show();
            }
            else {
                $("#dSpeciesAffectedError").hide();
            }
        }
    },

    setFrequency: function (obj) {
        var selector = "#txt" + $(obj).attr("species") + $(obj).attr("parameter") + "Frequency";

        if ($(obj).val() != "") {
            if ($(selector).val() == "" || $(selector).val() == undefined) {
                $(selector).val(1);
            }
            else {
                if (parseInt($(selector).val()) > parseInt($(obj).val())) {
                    $(selector).val($(obj).val());
                    $("#dWarningModal").modal({ show: true, backdrop: 'static' });
                }
            }
        }
        else {
            $(selector).val("");
        }
    },

    checkFrequency: function (obj) {
        var selector = "#txt" + $(obj).attr("species") + $(obj).attr("parameter") + "Duration";

        if ($(obj).val() != "") {
            if (parseInt($(obj).val()) > parseInt($(selector).val())) {
                $(obj).val($(selector).val());
                $("#dWarningModal").modal({ show: true, backdrop: 'static' });
            }
        }
    },

    cancelAdvancedSearch: function () {
        location.href = outbreakCreate.cancelAdvancedSearchUrl;
    },

    getFilterSession: function () {
        $("#fAdvancedOutbreakSearch").validate();
        if ($("#fAdvancedOutbreakSearch").valid()) {
            $("#toggleOutbreakSearchIcon").removeClass("fas fa-caret-up align-bottom fa-2x").addClass("fas fa-caret-down align-bottom fa-2x");
            $("#dSessionSearchCriteria").collapse("hide");
            $("#dSessionResults").collapse("show");
            $("#gOutbreaks").DataTable().draw();
        }
    },

    toggleOutbreakSearchCriteria: function () {
        if ($("#dSessionSearchCriteria").hasClass("show")) {
            $("#toggleOutbreakSearchIcon").removeClass("fa-caret-up").addClass("fa-caret-down");
        }
        else {
            $("#toggleOutbreakSearchIcon").removeClass("fa-caret-down").addClass("fa-caret-up");
        }
    },

    toggleOutbreakSummary: function () {
        if ($("#dOutbreakSummary").hasClass("show")) {
            $("#toggleOutbreakSummaryIcon").removeClass("fas fa-2x e-dark-blue fa-caret-up").addClass("fas fa-2x e-dark-blue fa-caret-down");
        }
        else {
            $("#toggleOutbreakSummaryIcon").removeClass("fas fa-2x e-dark-blue fa-caret-down").addClass("fas fa-2x e-dark-blue fa-caret-up");
        }
    },

    clearSearchFields: function () {
        $("#OutbreakId,#OutbreakTypeId,#idfsDiagnosisOrDiagnosisGroup,#SearchCriteria_StartDateFrom,#SearchCriteria_StartDateTo,#AdminLevel1Value,#AdminLevel2Value,#Settlement,#SearchBox").val("");
        $("#idfsOutbreakStatus").val("10063501");

        $("#OutbreakTypeId,#idfsDiagnosisOrDiagnosisGroup,#idfsOutbreakStatus,#AdminLevel1Value").trigger("change");

        $("#toggleOutbreakSearchIcon").removeClass("fas fa-caret-down align-bottom fa-2x").addClass("fas fa-caret-up align-bottom fa-2x");
        $("#dSessionSearchCriteria").collapse("show");
        $("#dSessionResults").collapse("hide");
    },

    showDecision: function (obj, OutbreakType) {
        if (obj != undefined) {
            obj = $("#" + obj);
        }

        if (obj == undefined) {
            var mode = $("[class='outbreakDecision']:visible").attr("mode");
            obj = $("#b" + mode + "Case");
            if (obj.length == 0) {
                return false;
            }
            else {
                $(".outbreakDecision").hide();
            }
        }

        var offsetPadding = $(obj).width() / 2;

        //Continue on as normal, since obj should be established by now.
        var objAbsoluteRight = $(obj).offset().left;
        var objAbsoluteTop = $(obj).offset().top - $(obj).height() / 2;
        var action = $(obj).attr("action");

        var type = $("#EIDSSBodyCPH_hdnOutbreakTypeId").val();

        switch (parseInt(type)) {
            case 10513001:
                $("#rbl" + action + "Case [value='Human']").click();
                return true;
                break;
            case 10513002:
                $("#rbl" + action + "Case [value='Veterinary']").click();
                return true;
                break;
        }

        switch (OutbreakType) {
            case "Human":
                if (action == "Import") {
                    ImportCase("Human");
                }
                else {
                    outbreakCreate.createCase('Human');
                }
                break;
            case "Veterinary":
                if (action == "Import") {
                    ImportCase("Veterinary");
                }
                else {
                    createVeterinaryCase();
                }
                break;
            default:
                if ($("#dOutbreakDecision" + action).is(":visible")) {
                    $("#dOutbreakDecision" + action).hide();
                }
                else {
                    $(".outbreakDecision").hide();
                    $("#dOutbreakDecision" + action).css({
                        position: "absolute",
                        left: objAbsoluteRight,
                        top: objAbsoluteTop,
                        'padding-left': offsetPadding + 'px'
                    }).show();
                }
        }
    },

    getSessionNote: function (idfOutbreakNote) {
        $.ajax({
            type: 'POST',
            url: outbreakCreate.getUpdateURL,
            data: {
                idfOutbreakNote: idfOutbreakNote
            },
            dataType: 'json',

            success: function (json) {
                outbreakCreate.showUpdateEntry(false);

                var note = json[0];
                $("#idfOutbreakNote").val(note.idfOutbreakNote);
                $("#NoteRecordUID").val(note.noteRecordUID);
                $("#UserName").val(note.userName);
                $("#Organization").val(note.organization);
                $("#datNoteDate").val(note.datNoteDate);
                $("#UpdateRecordTitle").val(note.updateRecordTitle);
                $("#strNote").val(note.strNote);
                $("#UploadFileDescription").val(note.uploadFileDescription);

                var newOption = new Option(note.strPriority, note.updatePriorityID, true, true);
                $('#UpdatePriorityID').append(newOption).trigger('change');

            }
        })
    },

    getSessionNotes: function (idfOutbreak) {
        $.ajax({
            type: 'POST',
            url: outbreakCreate.getUpdatesURL,
            data: {
                idfOutbreak: idfOutbreak
            },
            dataType: 'html',

            success: function (html) {
                $("#dUpdates").html(html);
            }
        });
    },

    showUpdateEntry: function (newEntry) {
        $("#hNewRecord,#hEditRecord").hide();

        if (newEntry) {
            $("#NoteRecordUID").val("");
            $("#UserName").val($("#UserName").attr("initValue"));
            $("#Organization").val($("#Organization").attr("initValue"));
            $("#hNewRecord").show();
        }
        else {
            $("#hEditRecord").show();
            $("#UserName,#Organization").val("");
        }
        
        $("#FileUpload,#idfOutbreakNote,#datNoteDate,#UpdateRecordTitle,#strNote,#UploadFileObject,#UploadFileDescription").val("");

        var newOption = new Option("", "", true, true);
        $('#UpdatePriorityID').append(newOption).trigger('change');


        $("#dOutbreakNoteForm").modal("show");
    },

    createCase: function (type) {
        $("#dOutbreakDecisionImport").hide();
        switch (type) {
            case "Human":
                location.href = outbreakCreate.humanCaseUrl;
                break;
            case "Veterinary":
                break;
        }
    }
}

$(document).ready(outbreakCreate.init);

