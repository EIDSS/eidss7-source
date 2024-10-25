var VectorSurveillanceSession = (function () {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.ReportDisabledIndicator = false;

    module.init = function () {
    };

    return module;
})();

$(document).ready(VectorSurveillanceSession.init());

var VectorSurveillanceSessionSummary = {};
VectorSurveillanceSessionSummary.DotNetReference = null;
VectorSurveillanceSessionSummary.SetDotNetReference = function (pDotNetReference) {
    VectorSurveillanceSessionSummary.DotNetReference = pDotNetReference;
};

var VectorSurveillanceSessionLocation = {};
VectorSurveillanceSessionLocation.DotNetReference = null;
VectorSurveillanceSessionLocation.SetDotNetReference = function (pDotNetReference) {
    VectorSurveillanceSessionLocation.DotNetReference = pDotNetReference;
};

var VectorSurveillanceSessionDetailedCollections = {};
VectorSurveillanceSessionDetailedCollections.DotNetReference = null;
VectorSurveillanceSessionDetailedCollections.SetDotNetReference = function (pDotNetReference) {
    VectorSurveillanceSessionDetailedCollections.DotNetReference = pDotNetReference;
};

var VectorSurveillanceSessionAggregateCollections = {};
VectorSurveillanceSessionAggregateCollections.DotNetReference = null;
VectorSurveillanceSessionAggregateCollections.SetDotNetReference = function (pDotNetReference) {
    VectorSurveillanceSessionAggregateCollections.DotNetReference = pDotNetReference;
};

function initializeSidebarVectorSession(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, enableDeleteButton, loadingMessageText, cancelMessageText) {
    $("#vectorWizard").steps({
        headerTag: "h4",
        titleTemplate: '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enableDeleteButton: enableDeleteButton,
        enableKeyNavigation: true,
        enableContentCache: true,
        labels: {
            cancel: cancelButtonText,
            finish: finishButtonText,
            next: nextButtonText,
            previous: previousButtonText,
            delete: deleteButtonText,
            loading: loadingMessageText
        },
        onInit: function (event) {
            $("#vectorWizard .steps ul").append('<li id="saveStep" role="tab"><a href="#" role="menuitem"><span class="fa-stack text-muted"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-save fa-stack-1x fa-inverse"></i></span>  <span class="stepTitleText">' + finishButtonText + '</span></a></li>');

            $(document).on('click', '#saveStep', function (e) {
                e.preventDefault();
                $("#vectorWizard").steps("finish");
            });
},
        onCanceled: function (event) {
            VectorSurveillanceSession.DotNetReference.invokeMethodAsync('OnCancel');
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                // session summary
                case 0:
                    validateVectorSessionSection(VectorSurveillanceSessionSummary.DotNetReference, "vectorWizard", currentIndex);
                    break;
                // session location
                case 1:
                    validateVectorSessionSection(VectorSurveillanceSessionLocation.DotNetReference, "vectorWizard", currentIndex);
                    break;
                // detailed collection list
                case 2:
                    validateVectorSessionSection(VectorSurveillanceSessionDetailedCollections.DotNetReference, "vectorWizard", currentIndex);
                    break;
                // aggregate collection list
                case 3:
                    validateVectorSessionSection(VectorSurveillanceSessionAggregateCollections.DotNetReference, "vectorWizard", currentIndex);
                    break;
                default:
                    return true;
            }
        },
        onDeleting: function (event) {
            VectorSurveillanceSession.DotNetReference.invokeMethodAsync("OnDelete");
        },
        onFinished: async function (event) {
            var isVectorSurveillanceSessionSummaryValid = await VectorSurveillanceSessionSummary.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVectorSurveillanceSessionLocationValid = await VectorSurveillanceSessionLocation.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVectorSurveillanceSessionDetailedCollectionsValid = await VectorSurveillanceSessionDetailedCollections.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVectorSurveillanceSessionAggregateCollectionsValid = await VectorSurveillanceSessionAggregateCollections.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");

            hideDefaultStepIcons();
            setWizardState(isVectorSurveillanceSessionSummaryValid, "#vectorWizard-t-0");
            setWizardState(isVectorSurveillanceSessionLocationValid, "#vectorWizard-t-1");
            setWizardState(isVectorSurveillanceSessionDetailedCollectionsValid, "#vectorWizard-t-2");
            setWizardState(isVectorSurveillanceSessionAggregateCollectionsValid, "#vectorWizard-t-3");

            if (isVectorSurveillanceSessionSummaryValid &&
                isVectorSurveillanceSessionLocationValid &&
                isVectorSurveillanceSessionDetailedCollectionsValid &&
                isVectorSurveillanceSessionAggregateCollectionsValid
            ) {
                VectorSurveillanceSession.DotNetReference.invokeMethodAsync("OnSave");
            } else {
                $("#saveButton").removeAttr("href");
                $("#processing").addClass("fas fa-sync fa-spin");
                if (!isVectorSurveillanceSessionSummaryValid) {
                    $("#vectorWizard").steps("setStep", 0);
                } else if (!isVectorSurveillanceSessionLocationValid) {
                    $("#vectorWizard").steps("setStep", 1);
                } else if (!isVectorSurveillanceSessionDetailedCollectionsValid) {
                    $("#vectorWizard").steps("setStep", 2);
                } else if (!isVectorSurveillanceSessionAggregateCollectionsValid) {
                    $("#vectorWizard").steps("setStep", 3);
                }
            }
            
        }
    });
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
    $("#vectorWizard-t-0").find("#step").hide();
    $("#vectorWizard-t-1").find("#step").hide();
    $("#vectorWizard-t-2").find("#step").hide();
    $("#vectorWizard-t-3").find("#step").hide();
}


function reportIsDisabled(reportDisabledIndicator) {
    VectorSurveillanceSession.ReportDisabledIndicator = reportDisabledIndicator;
};

function navigateToSurveillanceSessionReviewStep() {
    $("#vectorWizard").steps("setStep", 4);
}

function navigateToSurveillanceSessionStep(step) {
    $("#vectorWizard").steps("setStep", step);
};

function validateVectorSessionSection(dotNetReference, wizard, stepNumber) {

    var result = new Promise(function (validateVectorSessionSection, reject) {
        validateVectorSessionSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"));
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

    VectorSurveillanceSessionSummary.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VectorSurveillanceSessionLocation.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VectorSurveillanceSessionDetailedCollections.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });
    VectorSurveillanceSessionAggregateCollections.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { surveillanceSessionIsValid = false; } });

    if (!surveillanceSessionIsValid) {
        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
    }
        
    return surveillanceSessionIsValid;
};