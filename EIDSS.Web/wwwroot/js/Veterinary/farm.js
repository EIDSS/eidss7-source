// initialize
var VeterinaryFarmAddEdit = (() => {
    var module = this;

    module.init = () => {
    };

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    return module;
})();

$(document).ready(VeterinaryFarmAddEdit.init());

var FarmHeaderSection = {};
FarmHeaderSection.DotNetReference = null;
FarmHeaderSection.SetDotNetReference = function (pDotNetReference) {
    FarmHeaderSection.DotNetReference = pDotNetReference;
};

var FarmInformationSection = {};
FarmInformationSection.DotNetReference = null;
FarmInformationSection.SetDotNetReference = function (pDotNetReference) {
    FarmInformationSection.DotNetReference = pDotNetReference;
};

var FarmAddressSection = {};
FarmAddressSection.DotNetReference = null;
FarmAddressSection.SetDotNetReference = function (pDotNetReference) {
    FarmAddressSection.DotNetReference = pDotNetReference;
};

var FarmDetailsSection = {};
FarmDetailsSection.DotNetReference = null;
FarmDetailsSection.SetDotNetReference = function (pDotNetReference) {
    FarmDetailsSection.DotNetReference = pDotNetReference;
};

var FarmReviewSection = {};
FarmReviewSection.DotNetReference = null;
FarmReviewSection.SetDotNetReference = function (pDotNetReference) {
    FarmReviewSection.DotNetReference = pDotNetReference;
};

//
// Initializes the right side wizard, sets the localized values for the navigational buttons, and
// sets the various templates and validation calls.
// https://github.com/rstaib/jquery-steps/wiki/Settings
//
function initializeFarmSidebar(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, printButtonText, enableFinishButton, enableDeleteButton, loadingMessageText, cancelMessage) {
    $("#farmDetailsWizard").steps({
        headerTag: "h4",
        titleTemplate:
            '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enableKeyNavigation: true,
        enableContentCache: false,
        enablePagination: true,
        enableDeleteButton: true,
        enableFinishButton: true,
        labels: {
            cancel: cancelButtonText,
            print: printButtonText,
            finish: finishButtonText,
            next: nextButtonText,
            previous: previousButtonText,
            delete: deleteButtonText,
            loading: loadingMessageText
        },
        data: {
            eventNamespace: "FarmDetails"
        },
        onInit: function (event) { },
        onCanceled: function (event) {
            FarmReviewSection.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onPrint: function (event) {
            FarmReviewSection.DotNetReference.invokeMethodAsync("OnPrint");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                case 0:
                    validateFarmSection(FarmInformationSection.DotNetReference, "farmDetailsWizard", currentIndex, newIndex);
                    break;
                case 1:
                    validateFarmSection(FarmAddressSection.DotNetReference, "farmDetailsWizard", currentIndex, newIndex);
                    break;
                default:
                    FarmReviewSection.DotNetReference.invokeMethodAsync("ValidateFarmReviewSection");
                    return true;
            }
        },
        onDeleting: function (event) { FarmReviewSection.DotNetReference.invokeMethodAsync("OnDelete"); },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");
            validateFarm();
        }
    });
};

function navigateToReviewStep() {
    $("#farmDetailsWizard").steps("setStep", 2);
};

function validateFarmSection(dotNetReference, wizard, stepNumber, newIndex) {
    if (newIndex == 2) {
        var result = new Promise(function (validateFarmSection, reject) {
            validateFarmSection(dotNetReference.invokeMethodAsync("ValidateSection", true));
        });
        result.then(function (value) {
            if (value) {
                $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
            }
        });
    } else {
        var result = new Promise(function (validateFarmSection, reject) {
            validateFarmSection(dotNetReference.invokeMethodAsync("ValidateSection", false));
        });
        result.then(function (value) {
            if (value) {
                $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
            }
        });
    }
};

function validateFarm() {
    FarmInformationSection.DotNetReference.invokeMethodAsync("ValidateSection", true).then(valid => {
        if (valid) {
            FarmAddressSection.DotNetReference.invokeMethodAsync("ValidateSection", true).then(valid => {
                if (valid) {
                    FarmReviewSection.DotNetReference.invokeMethodAsync("OnSubmit");
                }
                else {
                    $("#saveButton").attr("href", "#finish");
                    $("#processing").removeClass("fas fa-sync fa-spin");
                    $("#farmDetailsWizard").steps("setStep", 1);
                }
            });
        }
        else {
            $("#saveButton").attr("href", "#finish");
            $("#processing").removeClass("fas fa-sync fa-spin");
            $("#farmDetailsWizard").steps("setStep", 0);
        }
    });
};

function reloadSections() {
    FarmHeaderSection.DotNetReference.invokeMethodAsync("ReloadSection");
    FarmInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    FarmAddressSection.DotNetReference.invokeMethodAsync("ReloadSection");
    FarmDetailsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
    $("#farmDetailsWizard").steps("setStep", 0);
};

function stopProcessing() {
    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
}