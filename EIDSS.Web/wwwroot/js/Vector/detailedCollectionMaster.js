var VectorDetailedCollectionMaster = (function () {
    var module = this;

    module.init = function () {
    };

    module.shouldValidate = true;

    return module;
})();

$(document).ready(VectorDetailedCollectionMaster.init());

var DetailedCollectionMaster = {};
DetailedCollectionMaster.DotNetReference = null;
DetailedCollectionMaster.SetDotNetReference = function (pDotNetReference) {
    DetailedCollectionMaster.DotNetReference = pDotNetReference;
};

var DetailedCollectionVectorData = {};
DetailedCollectionVectorData.DotNetReference = null;
DetailedCollectionVectorData.SetDotNetReference = function (pDotNetReference) {
    DetailedCollectionVectorData.DotNetReference = pDotNetReference;
};

var VectorSpecificDataSection = {};
VectorSpecificDataSection.DotNetReference = null;
VectorSpecificDataSection.SetDotNetReference = function (pDotNetReference) {
    VectorSpecificDataSection.DotNetReference = pDotNetReference;
};

var DetailedCollectionFieldTest = {};
DetailedCollectionFieldTest.DotNetReference = null;
DetailedCollectionFieldTest.SetDotNetReference = function (pDotNetReference) {
    DetailedCollectionFieldTest.DotNetReference = pDotNetReference;
};

var DetailedCollectionSamples = {};
DetailedCollectionSamples.DotNetReference = null;
DetailedCollectionSamples.SetDotNetReference = function (pDotNetReference) {
    DetailedCollectionSamples.DotNetReference = pDotNetReference;
};

var DetailedCollectionLaboratoryTests = {};
DetailedCollectionLaboratoryTests.DotNetReference = null;
DetailedCollectionLaboratoryTests.SetDotNetReference = function (pDotNetReference) {
    DetailedCollectionLaboratoryTests.DotNetReference = pDotNetReference;
};

function initializeSidebarDetailedCollection(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, loadingMessageText, cancelMessageText) {
    $("#detailedCollectionWizard").steps({
        headerTag: "h4",
        titleTemplate: '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enableKeyNavigation: true,
        enableContentCache: true,
        labels: {
            cancel: cancelButtonText,
            finish: finishButtonText,
            next: nextButtonText,
            previous: previousButtonText,
            loading: loadingMessageText
        },
        onInit: function (event) { },
        onCanceled: function (event) {
            DetailedCollectionMaster.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                // collection data
                case 0:
                    validateDetailedSessionSection(DetailedCollectionMaster.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                // vector data
                case 1:
                    validateDetailedSessionSection(DetailedCollectionVectorData.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                // vector specific data
                case 2:
                    validateDetailedSessionSection(VectorSpecificDataSection.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                // samples
                case 3:
                    validateDetailedSessionSection(DetailedCollectionSamples.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                // field tests
                case 4:
                    validateDetailedSessionSection(DetailedCollectionFieldTest.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                // laboratory tests
                case 5:
                    validateDetailedSessionSection(DetailedCollectionLaboratoryTests.DotNetReference, "detailedCollectionWizard", currentIndex);
                    break;
                default:
                    return true;
            }
        },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");
            validateDetailedCollection();
            DetailedCollectionMaster.DotNetReference.invokeMethodAsync("OnSaveDetailedCollection");
        }
    });
};

function navigateToDetailCollectionReviewStep() {
    $("#detailedCollectionWizard").steps("setStep", 6);
};

function validateDetailedSessionSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateDetailedSessionSection, reject) {
        validateDetailedSessionSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

function validateDetailedCollection() {
    var detailedCollectionIsValid = true;

    DetailedCollectionMaster.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => {
        if (!valid) { detailedCollectionIsValid = false; }
    });
    DetailedCollectionVectorData.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { detailedCollectionIsValid = false; } });
    VectorSpecificDataSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { detailedCollectionIsValid = false; } });
    DetailedCollectionSamples.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { detailedCollectionIsValid = false; } });
    DetailedCollectionFieldTest.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { detailedCollectionIsValid = false; } });
    DetailedCollectionLaboratoryTests.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { detailedCollectionIsValid = false; } });

    if (!detailedCollectionIsValid) {
        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
    }
    
    return detailedCollectionIsValid;
};