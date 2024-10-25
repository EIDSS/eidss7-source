var Site = (function () {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function () {
    };

    return module;
})();

$(document).ready(Site.init());

var SiteInformationSection = {};
SiteInformationSection.DotNetReference = null;
SiteInformationSection.SetDotNetReference = function (pDotNetReference) {
    SiteInformationSection.DotNetReference = pDotNetReference;
};

var OrganizationsSection = {};
OrganizationsSection.DotNetReference = null;
OrganizationsSection.SetDotNetReference = function (pDotNetReference) {
    OrganizationsSection.DotNetReference = pDotNetReference;
};

var PermissionsSection = {};
PermissionsSection.DotNetReference = null;
PermissionsSection.SetDotNetReference = function (pDotNetReference) {
    PermissionsSection.DotNetReference = pDotNetReference;
};

//
// Initializes the right side wizard, sets the localized values for the navigational buttons, and
// sets the various templates and validation calls.
//
function initializeSidebar(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, enableDeleteButton, loadingMessageText, cancelMessageText) {
    $("#siteWizard").steps({
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
        onInit: function (event) { },
        onCanceled: function (event) { SiteInformationSection.DotNetReference.invokeMethodAsync("OnCancel"); },
        onStepChanging: function (event, currentIndex, newIndex) {
            switch (currentIndex) {
                case 0: //Site Information Section
                    validateSiteSection(SiteInformationSection.DotNetReference, "siteWizard", currentIndex);
                    break;
                case 1: //Organizations Section
                    validateSiteSection(OrganizationsSection.DotNetReference, "siteWizard", currentIndex);
                    break;
                case 2: //Permissions Section
                    validateSiteSection(PermissionsSection.DotNetReference, "siteWizard", currentIndex);
                    break;
                default:
                    return true;
            }
        },
        onDeleting: function (event) { Site.DotNetReference.invokeMethodAsync("OnDelete"); },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");

            validateSite();
        }
    });
};

function navigateToReviewStep(reviewStep) {
    $("#siteWizard").steps("setStep", reviewStep);
};

function validateSiteSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function (validateSiteSection, reject) {
        validateSiteSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"))
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

function showSidebarStepIncompleteIcon(wizard, stepNumber) {
    $("#" + wizard + "-t-" + stepNumber).find("#completedStep").hide();
    $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
    $("#" + wizard + "-t-" + stepNumber).find("#step").show();
}

function validateSite() {
    SiteInformationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSubmit").then(valid => {
        if (valid) {
            OrganizationsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => {
                if (valid) {
                    PermissionsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => {
                        if (valid) {
                            Site.DotNetReference.invokeMethodAsync("OnSubmit");
                        }
                        else
                            $("#siteWizard").steps("setStep", 2);
                    });
                }
                else
                    $("#siteWizard").steps("setStep", 1);
            });
        }
        else
            $("#siteWizard").steps("setStep", 0);
    });
};

function reloadSiteSections() {
    SiteInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    OrganizationsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    PermissionsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
};

//
// Handles the record selected event on the search organization view component.
//
function selectOrganizationRecord(organization) {
    var stepIndex = $("#siteWizard").steps("getCurrentIndex");

    if (stepIndex == 0)
        SiteInformationSection.DotNetReference.invokeMethodAsync("OnOrganizationSelected", organization[0].toString());
    else
        OrganizationsSection.DotNetReference.invokeMethodAsync("OnOrganizationSelected", organization[0], organization[2], organization[4], organization[5]);

    $("#siteWizard").steps("setStep", stepIndex);
};

function hideProcessingIndicator() {
    $("#processing").removeClass("fas fa-sync fa-spin");
};