var VetAggregateActionsReport = (function () {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function () {
    };

    return module;
})();

$(document).ready(VetAggregateActionsReport.init());

var VetAggregateActionsReportInformationSection = {};
VetAggregateActionsReportInformationSection.DotNetReference = null;
VetAggregateActionsReportInformationSection.SetDotNetReference = function (pDotNetReference) {
    VetAggregateActionsReportInformationSection.DotNetReference = pDotNetReference;
};

var VetAggregateActionsReportDiagnosticInvestigationsSection = {};
VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference = null;
VetAggregateActionsReportDiagnosticInvestigationsSection.SetDotNetReference = function (pDotNetReference) {
    VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference = pDotNetReference;
};

var VetAggregateActionsReportTreatmentMeasuresSection = {};
VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference = null;
VetAggregateActionsReportTreatmentMeasuresSection.SetDotNetReference = function (pDotNetReference) {
    VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference = pDotNetReference;
};

var VetAggregateActionsReportSanitaryMeasuresSection = {};
VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference = null;
VetAggregateActionsReportSanitaryMeasuresSection.SetDotNetReference = function (pDotNetReference) {
    VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference = pDotNetReference;
};

function setWizardState(isValid, stringId) {
    if (isValid) {
        $(stringId).find("#erroredStep").hide();
        $(stringId).find("#completedStep").show();
    } else {
        $(stringId).find("#erroredStep").show();
        $(stringId).find("#completedStep").hide();
    }
}

function hideDefaultStepIcons() {
    $("#veterinaryAggregateActionsReportWizard-t-0").find("#step").hide();
    $("#veterinaryAggregateActionsReportWizard-t-1").find("#step").hide();
    $("#veterinaryAggregateActionsReportWizard-t-2").find("#step").hide();
    $("#veterinaryAggregateActionsReportWizard-t-3").find("#step").hide();
}

function initializeSidebar(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, printButtonText, enableDeleteButton, enableSaveButton, loadingMessageText, cancelMessageText) {
    $("#veterinaryAggregateActionsReportWizard").steps({
        headerTag: "h4",
        titleTemplate: '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enablePrintButton: true,
        enableDeleteButton: enableDeleteButton,
        enableFinishButton: enableSaveButton,
        enableKeyNavigation: true,
        enableContentCache: true,
        labels: {
            cancel: cancelButtonText,
            print: printButtonText,
            finish: finishButtonText,
            next: nextButtonText,
            previous: previousButtonText,
            delete: deleteButtonText,
            loading: loadingMessageText
        },
        onInit: function (event) {
            $("#veterinaryAggregateActionsReportWizard .steps ul").append('<li id="saveStep" role="tab"><a href="#" role="menuitem"><span class="fa-stack text-muted"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-save fa-stack-1x fa-inverse"></i></span>  <span class="stepTitleText">' + finishButtonText + '</span></a></li>');

            $(document).on('click', '#saveStep', function (e) {
                e.preventDefault();
                $("#veterinaryAggregateActionsReportWizard").steps("finish");
            });
        },
        onCanceled: function (event) {
            VetAggregateActionsReport.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onPrinting: function (event) {
            VetAggregateActionsReport.DotNetReference.invokeMethodAsync("OnPrint");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                case 0: //Report Information Section
                    validateSessionSection(VetAggregateActionsReportInformationSection.DotNetReference, "veterinaryAggregateActionsReportWizard", currentIndex);
                    break;
                case 1: //Diagnostic Investigations Section
                    validateSessionSection(VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference, "veterinaryAggregateActionsReportWizard", currentIndex);
                    break;
                case 2: //Treatment Measures Section
                    validateSessionSection(VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference, "veterinaryAggregateActionsReportWizard", currentIndex);
                    break;
                case 3: //Sanitary Measures Section
                    validateSessionSection(VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference, "veterinaryAggregateActionsReportWizard", currentIndex);
                    break;
                case 4: //Review
                    return true;
                default:
                    return true;
            }
        },
        onStepChanged: function (event, currentIndex, priorIndex) {
            switch (currentIndex) {
                case 0: //Report Information Section
                    VetAggregateActionsReportInformationSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    break;
                case 1: //Diagnostic Investigations Section
                    VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    break;
                case 2: //Treatment Measures Section
                    VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    break;
                case 3: //Sanitary Measures Section
                    VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    break;
                case 4: //Review
                    VetAggregateActionsReportInformationSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                    break;
                default:
                    return true;
            }
        },
        onDeleting: function (event) {
            VetAggregateActionsReport.DotNetReference.invokeMethodAsync("OnDelete");
        },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");
            validateAggregateActionsReport();
        }
    });
};

function navigateToReviewStep() {
    $("#veterinaryAggregateActionsReportWizard").steps("setStep", 4);
};

function toggleSurveillanceSessionSummary(showOrHide) {
    $("#divSessionHeader").collapse(showOrHide);

    if ($("#divSessionHeader").hasClass("show")) {
        $("#sSessionHeaderToggle").removeClass("fa-caret-down").addClass("fa-caret-up");
    }
    else {
        $("#sSessionHeaderToggle").removeClass("fa-caret-up").addClass("fa-caret-down");
    }
};

function validateSessionSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateSessionSection, reject) {
        validateSessionSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

async function validateAggregateActionsReport() {
    var isVetAggregateActionsReportInformationSectionValid = await VetAggregateActionsReportInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
    var isVetAggregateActionsReportDiagnosticInvestigationsSectionValid = await VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
    var isVetAggregateActionsReportTreatmentMeasuresSectionValid = await VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
    var isVetAggregateActionsReportSanitaryMeasuresSectionValid = await VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");

    hideDefaultStepIcons();
    setWizardState(isVetAggregateActionsReportInformationSectionValid, "#veterinaryAggregateActionsReportWizard-t-0");
    setWizardState(isVetAggregateActionsReportDiagnosticInvestigationsSectionValid, "#veterinaryAggregateActionsReportWizard-t-1");
    setWizardState(isVetAggregateActionsReportTreatmentMeasuresSectionValid, "#veterinaryAggregateActionsReportWizard-t-2");
    setWizardState(isVetAggregateActionsReportSanitaryMeasuresSectionValid, "#veterinaryAggregateActionsReportWizard-t-3");

    if (isVetAggregateActionsReportInformationSectionValid &&
        isVetAggregateActionsReportDiagnosticInvestigationsSectionValid &&
        isVetAggregateActionsReportTreatmentMeasuresSectionValid &&
        isVetAggregateActionsReportSanitaryMeasuresSectionValid
    ) {
        VetAggregateActionsReport.DotNetReference.invokeMethodAsync("OnSubmit");
    } else {
        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
        if (!isVetAggregateActionsReportInformationSectionValid) {
            $("#veterinaryAggregateActionsReportWizard").steps("setStep", 0);
        } else if (!isVetAggregateActionsReportDiagnosticInvestigationsSectionValid) {
            $("#veterinaryAggregateActionsReportWizard").steps("setStep", 1);
        } else if (!isVetAggregateActionsReportTreatmentMeasuresSectionValid) {
            $("#veterinaryAggregateActionsReportWizard").steps("setStep", 2);
        } else if (!isVetAggregateActionsReportSanitaryMeasuresSectionValid) {
            $("#veterinaryAggregateActionsReportWizard").steps("setStep", 3);
        }
    }
};

function reloadSections() {
    VetAggregateActionsReportInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetAggregateActionsReportDiagnosticInvestigationsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetAggregateActionsReportTreatmentMeasuresSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetAggregateActionsReportSanitaryMeasuresSection.DotNetReference.invokeMethodAsync("ReloadSection");
};