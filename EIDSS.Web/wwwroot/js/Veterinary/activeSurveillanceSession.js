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
        onInit: function (event) {
            $("#veterinaryActiveSurveillanceSessionWizard .steps ul").append('<li id="saveStep" role="tab"><a href="#" role="menuitem"><span class="fa-stack text-muted"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-save fa-stack-1x fa-inverse"></i></span>  <span class="stepTitleText">' + finishButtonText +'</span></a></li>');

            $(document).on('click', '#saveStep', function (e) {
                e.preventDefault();
                $("#veterinaryActiveSurveillanceSessionWizard").steps("finish");
            });
        },
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
        onFinished: async function (event) {
            var isVetSurveillanceSessionInformationSectionValid = await VetSurveillanceSessionInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVetSurveillanceDetailedInformationSectionValid = await VetSurveillanceDetailedInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVetSurveillanceTestsSectionValid = await VetSurveillanceTestsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVetSurveillanceActionsSectionValid = await VetSurveillanceActionsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVetSurveillanceAggregateInformationSectionValid = await VetSurveillanceAggregateInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
            var isVetSurveillanceDiseaseReportsSectionValid = await VetSurveillanceDiseaseReportsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");

            hideDefaultStepIcons();
            setWizardState(isVetSurveillanceSessionInformationSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-0");
            setWizardState(isVetSurveillanceDetailedInformationSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-1");
            setWizardState(isVetSurveillanceTestsSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-2");
            setWizardState(isVetSurveillanceActionsSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-3");
            setWizardState(isVetSurveillanceAggregateInformationSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-4");
            setWizardState(isVetSurveillanceDiseaseReportsSectionValid, "#veterinaryActiveSurveillanceSessionWizard-t-5");

            if (isVetSurveillanceSessionInformationSectionValid &&
                isVetSurveillanceDetailedInformationSectionValid &&
                isVetSurveillanceTestsSectionValid &&
                isVetSurveillanceActionsSectionValid &&
                isVetSurveillanceAggregateInformationSectionValid &&
                isVetSurveillanceDiseaseReportsSectionValid
            ) {
                VeterinaryActiveSurveillanceSession.DotNetReference.invokeMethodAsync("OnSubmit");
            } else {
                $("#saveButton").removeAttr("href");
                $("#processing").addClass("fas fa-sync fa-spin");
                if (!isVetSurveillanceSessionInformationSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 0);
                } else if (!isVetSurveillanceDetailedInformationSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 1);
                } else if (!isVetSurveillanceTestsSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 2);
                } else if (!isVetSurveillanceActionsSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 3);
                } else if (!isVetSurveillanceAggregateInformationSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 4);
                } else if (!isVetSurveillanceDiseaseReportsSectionValid) {
                    $("#veterinaryActiveSurveillanceSessionWizard").steps("setStep", 5);
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
    $("#veterinaryActiveSurveillanceSessionWizard-t-0").find("#step").hide();
    $("#veterinaryActiveSurveillanceSessionWizard-t-1").find("#step").hide();
    $("#veterinaryActiveSurveillanceSessionWizard-t-2").find("#step").hide();
    $("#veterinaryActiveSurveillanceSessionWizard-t-3").find("#step").hide();
    $("#veterinaryActiveSurveillanceSessionWizard-t-4").find("#step").hide();
    $("#veterinaryActiveSurveillanceSessionWizard-t-5").find("#step").hide();
}

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

function reloadSections() {
    VetSurveillanceSessionInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceDetailedInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceTestsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceActionsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceDiseaseReportsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    VetSurveillanceAggregateInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
};