/*
 * PersonAddEdit Module
 *
 * Description:  Used for sidebar and validation on person details screens.
 * Changes:
 * Author           Date        Comment
 * Mike Kornegay    07/14/2022  Converted to module pattern so functions do not corrupt global namespace.
 *
 */
var PersonAddEdit = (function () {

    var module = {};

    module.init = () => {
    };

    /*
    * Private Members
    *
    */

    function validatePerson() {
        PersonAddEdit.PersonInformationSection.DotNetReference.invokeMethodAsync("ValidateSection", true).then(valid => {
            if (valid) {
                PersonAddEdit.PersonAddressSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                    if (valid) {
                        PersonAddEdit.PersonEmploymentSchoolSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                            if (valid) {
                                PersonAddEdit.DotNetReference.invokeMethodAsync("OnSubmit");
                            }
                            else {
                                $("#saveButton").attr("href", "#finish");
                                $("#processing").removeClass("fas fa-sync fa-spin");
                                $("#personDetailsWizard").steps("setStep", 2);
                            }
                        });
                    }
                    else {
                        $("#saveButton").attr("href", "#finish");
                        $("#processing").removeClass("fas fa-sync fa-spin");
                        $("#personDetailsWizard").steps("setStep", 1);
                    }
                });
            }
            else {
                $("#saveButton").attr("href", "#finish");
                $("#processing").removeClass("fas fa-sync fa-spin");
                $("#personDetailsWizard").steps("setStep", 0);
            }
        });
    };

    /*
    * Public Members
    *
    */

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.PersonHeaderSection = {};
    module.PersonHeaderSection.DotNetReference = null;
    module.PersonHeaderSection.SetDotNetReference = function (pDotNetReference) {
        module.PersonHeaderSection.DotNetReference = pDotNetReference;
    };

    module.PersonInformationSection = {};
    module.PersonInformationSection.DotNetReference = null;
    module.PersonInformationSection.SetDotNetReference = function (pDotNetReference) {
        module.PersonInformationSection.DotNetReference = pDotNetReference;
    };

    module.PersonAddressSection = {};
    module.PersonAddressSection.DotNetReference = null;
    module.PersonAddressSection.SetDotNetReference = function (pDotNetReference) {
        module.PersonAddressSection.DotNetReference = pDotNetReference;
    };

    module.PersonEmploymentSchoolSection = {};
    module.PersonEmploymentSchoolSection.DotNetReference = null;
    module.PersonEmploymentSchoolSection.SetDotNetReference = function (pDotNetReference) {
        module.PersonEmploymentSchoolSection.DotNetReference = pDotNetReference;
    };

    module.PersonReviewSection = {};
    module.PersonReviewSection.DotNetReference = null;
    module.PersonReviewSection.SetDotNetReference = function (pDotNetReference) {
        module.PersonReviewSection.DotNetReference = pDotNetReference;
    };

    module.destroySidebar = function () {
        $("#personDetailsWizard").steps("destroy");
    };

    module.initializePersonSidebar = function (cancelButtonText, finishButtonText, nextButtonText, previousButtonText, loadingMessageText, cancelMessage) {
        $("#personDetailsWizard").steps({
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
            enableDeleteButton: false,
            enableFinishButton: true,
            labels: {
                cancel: cancelButtonText,
                finish: finishButtonText,
                next: nextButtonText,
                previous: previousButtonText,
                //delete: deleteButtonText,
                loading: loadingMessageText
            },
            data: {
                eventNamespace: "PersonDetails"
            },
            onInit: function (event) { },
            onCanceled: function (event) {
                PersonAddEdit.DotNetReference.invokeMethodAsync("OnCancel");
            },
            onStepChanging: function (event, currentIndex, newIndex) {
                switch (currentIndex) {
                    case 0:
                        PersonAddEdit.validatePersonSection(PersonAddEdit.PersonInformationSection.DotNetReference, "personDetailsWizard", currentIndex, newIndex);
                        break;
                    case 1:
                        PersonAddEdit.validatePersonSection(PersonAddEdit.PersonAddressSection.DotNetReference, "personDetailsWizard", currentIndex, newIndex);
                        break;
                    case 2:
                        PersonAddEdit.validatePersonSection(PersonAddEdit.PersonEmploymentSchoolSection.DotNetReference, "personDetailsWizard", currentIndex, newIndex);
                        break;
                    default:
                        return true;
                }
            },
            onStepChanged: function (event, currentIndex, priorIndex) {
                switch (currentIndex) {
                    case 0: //Person Information Section
                        PersonAddEdit.PersonInformationSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        break;
                    case 1: //Person Address Section
                        PersonAddEdit.PersonAddressSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        break;
                    case 2: //Person Employment School Section
                        PersonAddEdit.PersonEmploymentSchoolSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        break;
                    case 3: //Review Section
                        PersonAddEdit.PersonInformationSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        PersonAddEdit.PersonAddressSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        PersonAddEdit.PersonEmploymentSchoolSection.DotNetReference.invokeMethodAsync("SetPersonDisabledIndicator", currentIndex);
                        break;
                    default:
                        return true;
                }
            },
            onDeleting: function (event) { PersonAddEdit.DotNetReference.invokeMethodAsync("OnDelete"); },
            onFinished: function (event) {
                $("#saveButton").removeAttr("href");
                $("#processing").addClass("fas fa-sync fa-spin");
                validatePerson();
            }
        });
    };

    module.navigateToReviewStep = function () {
        $("#personDetailsWizard").steps("setStep", 3);
    };

    module.validatePersonSection = function (dotNetReference, wizard, stepNumber, newIndex) {
        if (newIndex == 3) {
            var result = new Promise(function (validatePersonSection, reject) {
                validatePersonSection(dotNetReference.invokeMethodAsync("ValidateSection", true));
            });
            result.then(function (value) {
                if (value) {
                    $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                    $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
                }
            });
        } else {
            var result = new Promise(function (validatePersonSection, reject) {
                validatePersonSection(dotNetReference.invokeMethodAsync("ValidateSection", false));
            });
            result.then(function (value) {
                if (value) {
                    $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                    $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
                }
            });
        }
    };

    module.showReview = function () {
        $("#personDetailsWizard").steps("showReview");
    };

    module.reloadSections = function () {
        if (PersonAddEdit.PersonHeaderSection.DotNetReference)
            PersonAddEdit.PersonHeaderSection.DotNetReference.invokeMethodAsync("ReloadSection");
        PersonAddEdit.PersonInformationSection.DotNetReference.invokeMethodAsync("ReloadSection");
        PersonAddEdit.PersonAddressSection.DotNetReference.invokeMethodAsync("ReloadSection");
        PersonAddEdit.PersonEmploymentSchoolSection.DotNetReference.invokeMethodAsync("ReloadSection");

        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
    };

    module.stopProcessing = function () {
        $("#saveButton").attr("href", "#finish");
        $("#processing").removeClass("fas fa-sync fa-spin");
    }

    return module;


}());

$(document).ready(PersonAddEdit.init());
