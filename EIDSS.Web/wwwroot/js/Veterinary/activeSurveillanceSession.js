var VeterinaryActiveSurveillanceSession = (function () {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function () {
    };

    return module;
})();

$(document).ready(VeterinaryActiveSurveillanceSession.init());

var VetSurveillanceSessionSummary = {};
VetSurveillanceSessionSummary.DotNetReference = null;
VetSurveillanceSessionSummary.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceSessionSummary.DotNetReference = pDotNetReference;
};

var VetSurveillanceSessionInformationSection = {};
VetSurveillanceSessionInformationSection.DotNetReference = null;
VetSurveillanceSessionInformationSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceSessionInformationSection.DotNetReference = pDotNetReference;
};

var VetSurveillanceDetailedInformationSection = {};
VetSurveillanceDetailedInformationSection.DotNetReference = null;
VetSurveillanceDetailedInformationSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceDetailedInformationSection.DotNetReference = pDotNetReference;
};

var VetSurveillanceTestsSection = {};
VetSurveillanceTestsSection.DotNetReference = null;
VetSurveillanceTestsSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceTestsSection.DotNetReference = pDotNetReference;
};

var VetSurveillanceActionsSection = {};
VetSurveillanceActionsSection.DotNetReference = null;
VetSurveillanceActionsSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceActionsSection.DotNetReference = pDotNetReference;
};

var VetSurveillanceAggregateInformationSection = {};
VetSurveillanceAggregateInformationSection.DotNetReference = null;
VetSurveillanceAggregateInformationSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceAggregateInformationSection.DotNetReference = pDotNetReference;
};

var VetSurveillanceDiseaseReportsSection = {};
VetSurveillanceDiseaseReportsSection.DotNetReference = null;
VetSurveillanceDiseaseReportsSection.SetDotNetReference = function (pDotNetReference) {
    VetSurveillanceDiseaseReportsSection.DotNetReference = pDotNetReference;
};

function initializeVetSurveillanceSidebar(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, printButtonText, enableDeleteButton, loadingMessageText, cancelMessageText, deleteButtonEnable) {
    $("#veterinaryActiveSurveillanceSessionWizard").steps({
        headerTag: "h4",
        titleTemplate: '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        //enablePrintButton: true,
        enableDeleteButton: deleteButtonEnable,
        enableKeyNavigation: true,
        enableContentCache: true,
        labels: {
            cancel: cancelButtonText,
            //print: printButtonText,
            finish: finishButtonText,
            next: nextButtonText,
            previous: previousButtonText,
            delete: deleteButtonText,
            loading: loadingMessageText
        },
        onInit: function (event) { },
        onCanceled: function (event) {
            VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                case 0: //Session Information Section
                    validateSessionSection(VetSurveillanceSessionInformationSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                case 1: //Detailed Information Section
                    validateSessionSection(VetSurveillanceDetailedInformationSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                case 2: //Tests Section
                    validateSessionSection(VetSurveillanceTestsSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                case 3: //Actions Section
                    validateSessionSection(VetSurveillanceActionsSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                case 4: //Aggregate Info Section
                    validateSessionSection(VetSurveillanceAggregateInformationSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                case 5: //Surveillance Disease Report Section
                    validateSessionSection(VetSurveillanceDiseaseReportsSection.DotNetReference, "veterinaryActiveSurveillanceSessionWizard", currentIndex);
                    break;
                default:
                    return true;
                    break;
            }
            if (newIndex == 6) {
                VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("HideSurveillanceSessionHeader");
            }
            else {
                VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("ShowSurveillanceSessionHeader");
            }
        },
        onDeleting: function (event) {
            VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("OnDelete");
        },
        //onPrinting: function (event) {
        //    VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync('OnPrint');
        //},
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");
            validateSurveillanceSession();
            VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("OnSubmit");
        }
    });
};

function navigateToVeterinarySurveillanceSessionReviewStep(reviewStep) {
    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", reviewStep);
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

function clearProcessingStatus() {
    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
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

function validateSurveillanceSession() {
    var surveillanceSessionIsValid = true;

    VetSurveillanceSessionInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VetSurveillanceDetailedInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VetSurveillanceTestsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VetSurveillanceActionsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VetSurveillanceDiseaseReportsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VetSurveillanceAggregateInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });

    return surveillanceSessionIsValid;
};

function reloadSections() {
    VetSurveillanceSessionInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceDetailedInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceTestsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceActionsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceDiseaseReportsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceAggregateInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
};