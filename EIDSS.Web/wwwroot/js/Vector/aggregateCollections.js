var AggregateCollection = (function () {
    var module = this;

    module.init = function () {
    };

    module.shouldValidate = true;

    return module;
})();

$(document).ready(AggregateCollection.init());

var AggregateCollectionMaster = {};
AggregateCollectionMaster.DotNetReference = null;
AggregateCollectionMaster.SetDotNetReference = function (pDotNetReference) {
    AggregateCollectionMaster.DotNetReference = pDotNetReference;
};

var AggregateCollectionDiseaseList = {};
AggregateCollectionDiseaseList.DotNetReference = null;
AggregateCollectionDiseaseList.SetDotNetReference = function (pDotNetReference) {
    AggregateCollectionDiseaseList.DotNetReference = pDotNetReference;
};

function initializeSidebarAggregateCollection(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, enableDeleteButton, loadingMessageText, cancelMessageText) {
    $("#aggregateCollectionWizard").steps({
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
            AggregateCollectionMaster.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                case 0: //aggregate collection info
                   validateAggregateMasterSessionSection(AggregateCollectionMaster.DotNetReference,"aggregateCollectionWizard", currentIndex);
                    break;
                case 1: //aggregate collection location
                    validateAggregateLocationSection(AggregateCollectionMaster.DotNetReference, "aggregateCollectionWizard", currentIndex);
                    break;
                case 2: //disease list
                    validateAggregateDiseaseSessionSection(AggregateCollectionDiseaseList.DotNetReference, "aggregateCollectionWizard", currentIndex);
                    break;
                default:
                    return true;
            }
        },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");
            validateAggregateCollection();
            AggregateCollectionMaster.DotNetReference.invokeMethodAsync("OnSaveAggregateCollection");
        }
    });
};

function navigateToAggregateCollectionReviewStep() {
    $("#aggregateCollectionWizard").steps("setStep", 3);
}

function validateAggregateMasterSessionSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateAggregateMasterSessionSection, reject) {
        validateAggregateMasterSessionSection(
            dotNetReference.invokeMethodAsync("ValidateAggregateMasterSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

function validateAggregateLocationSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateAggregateLocationSection, reject) {
        validateAggregateLocationSection(
            dotNetReference.invokeMethodAsync("ValidateAggregateLocationSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

function validateAggregateDiseaseSessionSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateAggregateDiseaseSessionSection, reject) {
        validateAggregateDiseaseSessionSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

function validateAggregateCollection() {
    var aggregateCollectionIsValid = true;

    AggregateCollectionMaster.DotNetReference.invokeMethodAsync("ValidateAggregateMasterSectionForSidebar").then(valid => { if (!valid) { aggregateCollectionIsValid = false; } });
    AggregateCollectionMaster.DotNetReference.invokeMethodAsync("ValidateAggregateLocationSectionForSidebar").then(valid => { if (!valid) { aggregateCollectionIsValid = false; } });
    AggregateCollectionDiseaseList.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => { if (!valid) { aggregateCollectionIsValid = false; } });

    if (!aggregateCollectionIsValid) {
        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
    }
    
    return aggregateCollectionIsValid;
};