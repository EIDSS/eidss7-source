var VeterinaryDiseaseReport = (function() {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function(pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function() {
    };

    return module;
})();

$(document).ready(VeterinaryDiseaseReport.init());

var Case = {};
Case.DotNetReference = null;
Case.SetDotNetReference = function (pDotNetReference) {
    Case.DotNetReference = pDotNetReference;
};

var CaseSummary = {};
CaseSummary.DotNetReference = null;
CaseSummary.SetDotNetReference = function (pDotNetReference) {
    CaseSummary.DotNetReference = pDotNetReference;
};

var DiseaseReportSummary = {};
DiseaseReportSummary.DotNetReference = null;
DiseaseReportSummary.SetDotNetReference = function(pDotNetReference) {
    DiseaseReportSummary.DotNetReference = pDotNetReference;
};

var FarmDetailsSection = {};
FarmDetailsSection.DotNetReference = null;
FarmDetailsSection.SetDotNetReference = function(pDotNetReference) {
    FarmDetailsSection.DotNetReference = pDotNetReference;
};

var CaseLocationSection = {};
CaseLocationSection.DotNetReference = null;
CaseLocationSection.SetDotNetReference = function (pDotNetReference) {
    CaseLocationSection.DotNetReference = pDotNetReference;
};

var ClinicalInformationSection = {};
ClinicalInformationSection.DotNetReference = null;
ClinicalInformationSection.SetDotNetReference = function (pDotNetReference) {
    ClinicalInformationSection.DotNetReference = pDotNetReference;
};

var NotificationSection = {};
NotificationSection.DotNetReference = null;
NotificationSection.SetDotNetReference = function(pDotNetReference) {
    NotificationSection.DotNetReference = pDotNetReference;
};

var OutbreakNotificationSection = {};
OutbreakNotificationSection.DotNetReference = null;
OutbreakNotificationSection.SetDotNetReference = function (pDotNetReference) {
    OutbreakNotificationSection.DotNetReference = pDotNetReference;
};

var FarmInventorySection = {};
FarmInventorySection.DotNetReference = null;
FarmInventorySection.SetDotNetReference = function(pDotNetReference) {
    FarmInventorySection.DotNetReference = pDotNetReference;
};

var FarmEpidemiologicalInformationSection = {};
FarmEpidemiologicalInformationSection.DotNetReference = null;
FarmEpidemiologicalInformationSection.SetDotNetReference = function(pDotNetReference) {
    FarmEpidemiologicalInformationSection.DotNetReference = pDotNetReference;
};

var ClinicalInvestigationSection = {};
ClinicalInvestigationSection.DotNetReference = null;
ClinicalInvestigationSection.SetDotNetReference = function(pDotNetReference) {
    ClinicalInvestigationSection.DotNetReference = pDotNetReference;
};

var VaccinationsSection = {};
VaccinationsSection.DotNetReference = null;
VaccinationsSection.SetDotNetReference = function(pDotNetReference) {
    VaccinationsSection.DotNetReference = pDotNetReference;
};

var AnimalsSection = {};
AnimalsSection.DotNetReference = null;
AnimalsSection.SetDotNetReference = function(pDotNetReference) {
    AnimalsSection.DotNetReference = pDotNetReference;
};

var ControlMeasuresSection = {};
ControlMeasuresSection.DotNetReference = null;
ControlMeasuresSection.SetDotNetReference = function(pDotNetReference) {
    ControlMeasuresSection.DotNetReference = pDotNetReference;
};

var OutbreakInvestigationSection = {};
OutbreakInvestigationSection.DotNetReference = null;
OutbreakInvestigationSection.SetDotNetReference = function (pDotNetReference) {
    OutbreakInvestigationSection.DotNetReference = pDotNetReference;
};

var ContactsSection = {};
ContactsSection.DotNetReference = null;
ContactsSection.SetDotNetReference = function (pDotNetReference) {
    ContactsSection.DotNetReference = pDotNetReference;
};

var CaseMonitoringSection = {};
CaseMonitoringSection.DotNetReference = null;
CaseMonitoringSection.SetDotNetReference = function (pDotNetReference) {
    CaseMonitoringSection.DotNetReference = pDotNetReference;
};

var SamplesSection = {};
SamplesSection.DotNetReference = null;
SamplesSection.SetDotNetReference = function(pDotNetReference) {
    SamplesSection.DotNetReference = pDotNetReference;
};

var PensideTestsSection = {};
PensideTestsSection.DotNetReference = null;
PensideTestsSection.SetDotNetReference = function(pDotNetReference) {
    PensideTestsSection.DotNetReference = pDotNetReference;
};

var LaboratoryTestsAndResultsSummaryAndInterpretationSection = {};
LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference = null;
LaboratoryTestsAndResultsSummaryAndInterpretationSection.SetDotNetReference = function(pDotNetReference) {
    LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference = pDotNetReference;
};

var CaseLogsSection = {};
CaseLogsSection.DotNetReference = null;
CaseLogsSection.SetDotNetReference = function(pDotNetReference) {
    CaseLogsSection.DotNetReference = pDotNetReference;
};

//
// Initializes the right side wizard, sets the localized values for the navigational buttons, and
// sets the various templates and validation calls.
//
function initializeCaseSidebar(cancelButtonText, finishButtonText, nextButtonText, previousButtonText, deleteButtonText, printButtonText, enableDeleteButton, loadingMessageText, cancelMessageText) {
    $("#caseDiseaseReportWizard").steps({
        headerTag: "h4",
        titleTemplate:
            '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enablePrintButton: true,
        enableDeleteButton: enableDeleteButton,
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
        onInit: function (event) {},
        onCanceled: function(event) {
             VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnCancel");
        },
        onPrinting: function(event) {
             VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnPrint");
        },
        onStepChanging: function (event, currentIndex, newIndex) {
            var stepCount = $("#caseDiseaseReportWizard").steps("getStepCount");

            if (newIndex === stepCount - 1) {
                reloadCaseSections(true);
            }
            else {
                reloadCaseSections(false);
            }

            switch (currentIndex) {
                case 0: //Notification Section
                    toggleCaseReportSummary("hide");
                    validateReportSection(OutbreakNotificationSection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                    break;
                case 1: //Case Location Section
                    toggleCaseReportSummary("hide");
                    validateReportSection(CaseLocationSection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                case 2: //Farm Inventory Section
                    toggleCaseReportSummary("hide");
                    validateReportSection(FarmInventorySection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                    break;
                case 3: //Clinical Information Section
                    toggleCaseReportSummary("hide");
                    return true;
                case 4: //Vaccinations Section
                    toggleCaseReportSummary("hide");
                    return true;
                case 5: //Outbreak Investigation Section
                    toggleCaseReportSummary("hide");
                    validateReportSection(OutbreakInvestigationSection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                    break;
                case 6: //Case Monitoring Section
                    toggleCaseReportSummary("hide");
                    return true;
                case 7: //Contacts Section
                    toggleCaseReportSummary("hide");
                    return true;
                case 8: //Samples
                    toggleCaseReportSummary("hide");
                    return true;
                    break;
                case 9: //Penside Tests
                    toggleCaseReportSummary("hide");
                    return true;
                    break;
                case 10: //Laboratory Tests and Results Summary and Interpretations
                    toggleCaseReportSummary("hide");
                    return true;
                    break;
                default:
                    return true;
                    break;
            }
        },
        onDeleting: function (event) { VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnDelete"); },
        onFinished: function (event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");

            validateCase();
        }
    });
};

//
// Initializes the right side wizard, sets the localized values for the navigational buttons, and
// sets the various templates and validation calls.
//
function initializeReportSidebar(cancelButtonText,
    finishButtonText,
    nextButtonText,
    previousButtonText,
    deleteButtonText,
    printButtonText,
    enableFinishButton,
    enableDeleteButton,
    loadingMessageText,
    cancelMessageText) {
    $("#caseDiseaseReportWizard").steps({
        headerTag: "h4",
        titleTemplate:
            '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
        bodyTag: "section",
        isBlazor: true,
        transitionEffect: "none",
        stepsOrientation: "vertical",
        enableAllSteps: true,
        enableCancelButton: true,
        enableDeleteButton: enableDeleteButton,
        enablePrintButton: true,
        enableFinishButton: enableFinishButton,
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
            $("#caseDiseaseReportWizard .steps ul").append('<li id="saveStep" role="tab"><a href="#" role="menuitem"><span class="fa-stack text-muted"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-save fa-stack-1x fa-inverse"></i></span>  <span class="stepTitleText">' + finishButtonText + '</span></a></li>');

            $(document).on('click', '#saveStep', function (e) {
                e.preventDefault();
                $("#caseDiseaseReportWizard").steps("finish");
            });
        },
        onCanceled: function (event) { VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnCancel"); },
        onPrinting: function (event) {
            VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnPrint");
        },
        onStepChanging: async function (event, currentIndex, newIndex) {
            var stepCount = $("#caseDiseaseReportWizard").steps("getStepCount");

            if (newIndex === stepCount - 1) {
                if (stepCount === 11)
                    reloadAvianSections(true, currentIndex);
                else if (stepCount === 13)
                    reloadLivestockSections(true, currentIndex);
            }
            else {
                if (stepCount === 11)
                    reloadAvianSections(false, currentIndex);
                else if (stepCount === 13)
                    reloadLivestockSections(false, currentIndex);
            }

            var isDiseaseReportSummaryValid = await DiseaseReportSummary.DotNetReference.invokeMethodAsync("ValidateSummary");
            setWizardState(!isDiseaseReportSummaryValid , "#caseDiseaseReportWizard-t-0");
            if (!isDiseaseReportSummaryValid) {
                toggleCaseReportSummary("hide");
            }

            switch (currentIndex) {
                case 0: //Farm Details
                    var farmResult = await FarmDetailsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
                    if (farmResult && !isDiseaseReportSummaryValid) {
                        $("#caseDiseaseReportWizard-t-0").find("#erroredStep").hide();
                        $("#caseDiseaseReportWizard-t-0").find("#completedStep").show();
                    }
                    break;
                case 1: //Notification Section
                    validateReportSection(NotificationSection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                    break;
                case 2: //Farm Inventory Section
                    validateReportSection(FarmInventorySection.DotNetReference, "caseDiseaseReportWizard", currentIndex);
                    break;
                case 3: //Farm Epidemiological Info Section
                    return true;
                case 4: //Species/Clinical Investigation Section
                    validateReportSection(ClinicalInvestigationSection.DotNetReference,
                        "caseDiseaseReportWizard",
                        currentIndex);
                    break;
                case 5: //Vaccinations Section
                    return true;
                case 6: //Samples (Avian) or Animals (Livestock) Section
                    return true;
                case 7: //Penside Tests (Avian) or Control Measures (Livestock) Section
                    return true;
                    break;
                case 8: //Laboratory Tests and Results Summary and Interpretations (Avian) or Samples (Livestock) Section
                    return true;
                    break;
                case 9: //Case Logs (Avian) or Penside Tests (Livestock) Section
                    return true;
                    break;
                case 10: //Laboratory Tests and Results Summary and Interpretations (Livestock)
                    return true;
                    break;
                case 11: //Case Logs (Livestock) Section
                    return true;
                    break;
                default:
                    return true;
                    break;
            }
        },
        onDeleting: function(event) {
            var stepCount = $("#caseDiseaseReportWizard").steps("getStepCount");
            if (stepCount === 11)
                validateAvianDiseaseReport(null, "true");
            else
                validateLivestockDiseaseReport(null, "true");
        },
        onFinished: function(event) {
            $("#saveButton").removeAttr("href");
            $("#processing").addClass("fas fa-sync fa-spin");

            var stepCount = $("#caseDiseaseReportWizard").steps("getStepCount");
            if (stepCount === 11)
                validateAvianDiseaseReport(null, "false");
            else
                validateLivestockDiseaseReport(null, "false");
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
    $("#caseDiseaseReportWizard-t-0").find("#step").hide();
    $("#caseDiseaseReportWizard-t-1").find("#step").hide();
    $("#caseDiseaseReportWizard-t-2").find("#step").hide();
    $("#caseDiseaseReportWizard-t-3").find("#step").hide();
    $("#caseDiseaseReportWizard-t-4").find("#step").hide();
    $("#caseDiseaseReportWizard-t-5").find("#step").hide();
    $("#caseDiseaseReportWizard-t-6").find("#step").hide();
    $("#caseDiseaseReportWizard-t-7").find("#step").hide();
    $("#caseDiseaseReportWizard-t-8").find("#step").hide();
    $("#caseDiseaseReportWizard-t-9").find("#step").hide();
    $("#caseDiseaseReportWizard-t-10").find("#step").hide();
    $("#caseDiseaseReportWizard-t-11").find("#step").hide();
}

function navigateToReviewStep(reviewStep) {
    $("#caseDiseaseReportWizard").steps("setStep", reviewStep);
};

function navigateToCaseReviewStep(reviewStep) {
    $("#caseDiseaseReportWizard").steps("setStep", reviewStep);
};

function toggleCaseReportSummary(showOrHide) {
    $("#divCaseReportSummary").collapse(showOrHide);

    if ($("#divCaseReportSummary").hasClass("show")) {
        $("#sCaseReportSummaryToggle").removeClass("fa-caret-down").addClass("fa-caret-up");
    } else {
        $("#sCaseReportSummaryToggle").removeClass("fa-caret-up").addClass("fa-caret-down");
    }
};

function createConnectedDiseaseReport() {
    validateDiseaseReport();
}

function validateReportSection(dotNetReference, wizard, stepNumber) {
    var result = new Promise(function(validateReportSection, reject) {
        if (dotNetReference != null)
            validateReportSection(dotNetReference.invokeMethodAsync("ValidateSectionForSidebar"));
    });
    result.then(function (value) {
        if (value) {
            $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
            $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
        }
    });
};

//
//
//
async function validateAvianDiseaseReport(laboratoryTestInterpretationId, deleteReportIndicator) {
    var isDiseaseReportSummaryValid = await DiseaseReportSummary.DotNetReference.invokeMethodAsync("ValidateSummary");
    var isFarmDetailsSection = await FarmDetailsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
    var isNotificationSectionValid = await NotificationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSubmit");
    var isFarmInventorySectionValid = await FarmInventorySection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isFarmEpidemiologicalInformationSection = await FarmEpidemiologicalInformationSection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isClinicalInvestigationSection = await ClinicalInvestigationSection.DotNetReference.invokeMethodAsync("ValidateSection");

    if (isDiseaseReportSummaryValid)
    {
        $("#caseDiseaseReportWizard").steps("setStep", 0);
        $("#" + isDiseaseReportSummaryValid).focus();
        $("#divCaseReportSummary").one('shown.bs.collapse hidden.bs.collapse', function () {
            toggleCaseReportSummary("show");
        });
    } else if (isNotificationSectionValid)
    {
        $("#caseDiseaseReportWizard").steps("setStep", 1);
        $("#" + isNotificationSectionValid).focus();
        $("#divCaseReportSummary").one('shown.bs.collapse hidden.bs.collapse', function () {
            toggleCaseReportSummary("show");
        });
        return;
    }

    hideDefaultStepIcons();
    setWizardState(!isDiseaseReportSummaryValid && isFarmDetailsSection, "#caseDiseaseReportWizard-t-0");
    setWizardState(!isNotificationSectionValid, "#caseDiseaseReportWizard-t-1");
    setWizardState(isFarmInventorySectionValid, "#caseDiseaseReportWizard-t-2");
    setWizardState(isFarmEpidemiologicalInformationSection, "#caseDiseaseReportWizard-t-3");
    setWizardState(isClinicalInvestigationSection, "#caseDiseaseReportWizard-t-4");

    $("#caseDiseaseReportWizard-t-5").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-6").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-7").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-8").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-9").find("#completedStep").show();

    if (!isDiseaseReportSummaryValid &&
        isFarmDetailsSection &&
        !isNotificationSectionValid &&
        isFarmInventorySectionValid &&
        isFarmEpidemiologicalInformationSection &&
        isClinicalInvestigationSection
    ) {
        if (laboratoryTestInterpretationId) LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference.invokeMethodAsync("OnSubmitConnectedDiseaseReport",laboratoryTestInterpretationId);
        else {
            if (deleteReportIndicator === "true")
                VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnDelete");
            else
                VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnSubmit");
        }
    }
};

//
//
//
async function validateLivestockDiseaseReport(laboratoryTestInterpretationId, deleteReportIndicator) {
    var isDiseaseReportSummaryValid = await DiseaseReportSummary.DotNetReference.invokeMethodAsync("ValidateSummary");
    var isFarmDetailsSection = await FarmDetailsSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar");
    var isNotificationSectionValid = await NotificationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSubmit");
    var isFarmInventorySectionValid = await FarmInventorySection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isFarmEpidemiologicalInformationSectionValid = await FarmEpidemiologicalInformationSection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isClinicalInvestigationSectionValid = await ClinicalInvestigationSection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isAnimalsSectionvalid = await AnimalsSection.DotNetReference.invokeMethodAsync("ValidateSection");
    var isControlMeasuresSectionValid = await ControlMeasuresSection.DotNetReference.invokeMethodAsync("ValidateSection");

    if (isDiseaseReportSummaryValid) {
        $("#caseDiseaseReportWizard").steps("setStep", 0);
        $("#" + isDiseaseReportSummaryValid).focus();
        $("#divCaseReportSummary").one('shown.bs.collapse hidden.bs.collapse', function () {
            toggleCaseReportSummary("show");
        });
    } else if (isNotificationSectionValid) {
        $("#caseDiseaseReportWizard").steps("setStep", 1);
        $("#" + isNotificationSectionValid).focus();
        $("#divCaseReportSummary").one('shown.bs.collapse hidden.bs.collapse', function () {
            toggleCaseReportSummary("show");
        });
        return;
    }

    hideDefaultStepIcons();
    setWizardState(!isDiseaseReportSummaryValid && isFarmDetailsSection, "#caseDiseaseReportWizard-t-0");
    setWizardState(!isNotificationSectionValid, "#caseDiseaseReportWizard-t-1");
    setWizardState(isFarmInventorySectionValid, "#caseDiseaseReportWizard-t-2");
    setWizardState(isFarmEpidemiologicalInformationSectionValid, "#caseDiseaseReportWizard-t-3");
    setWizardState(isClinicalInvestigationSectionValid, "#caseDiseaseReportWizard-t-4");

    $("#caseDiseaseReportWizard-t-5").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-6").find("#completedStep").show();
    setWizardState(isControlMeasuresSectionValid, "#caseDiseaseReportWizard-t-7");
    $("#caseDiseaseReportWizard-t-8").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-9").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-10").find("#completedStep").show();
    $("#caseDiseaseReportWizard-t-11").find("#completedStep").show();

    if (!isDiseaseReportSummaryValid &&
        isFarmDetailsSection &&
        !isNotificationSectionValid &&
        isFarmInventorySectionValid &&
        isFarmEpidemiologicalInformationSectionValid &&
        isClinicalInvestigationSectionValid &&
        isAnimalsSectionvalid &&
        isControlMeasuresSectionValid
    ) {
        if (laboratoryTestInterpretationId) LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference.invokeMethodAsync("OnSubmitConnectedDiseaseReport", laboratoryTestInterpretationId);
        else {
            if (deleteReportIndicator === "true")
                VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnDelete");
            else
                VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnSubmit");
        }
    }
};

//
//
//
function validateCase(laboratoryTestInterpretationId) {
    CaseSummary.DotNetReference.invokeMethodAsync("ValidateSummary").then(valid => {
        if (valid) {
            CaseLocationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSidebar").then(valid => {
                if (valid) {
                    OutbreakNotificationSection.DotNetReference.invokeMethodAsync("ValidateSectionForSubmit").then(valid => {
                        if (valid) {
                            FarmInventorySection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                                if (valid) {
                                    ClinicalInformationSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                                        if (valid) {
                                            OutbreakInvestigationSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                                                if (valid) {
                                                    CaseMonitoringSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                                                        if (valid) {
                                                            ContactsSection.DotNetReference.invokeMethodAsync("ValidateSection").then(valid => {
                                                                if (valid) {
                                                                    VeterinaryDiseaseReport.DotNetReference.invokeMethodAsync("OnSubmit");
                                                                } else {
                                                                    $("#saveButton").attr("href", "#finish");
                                                                    $("#processing").removeClass("fas fa-sync fa-spin");
                                                                    $("#caseDiseaseReportWizard").steps("setStep", 7);
                                                                }
                                                            });
                                                        } else {
                                                            $("#saveButton").attr("href", "#finish");
                                                            $("#processing").removeClass("fas fa-sync fa-spin");
                                                            $("#caseDiseaseReportWizard").steps("setStep", 6);
                                                        }
                                                    });
                                                } else {
                                                    $("#saveButton").attr("href", "#finish");
                                                    $("#processing").removeClass("fas fa-sync fa-spin");
                                                    $("#caseDiseaseReportWizard").steps("setStep", 5);
                                                }
                                            });
                                        } else {
                                            $("#saveButton").attr("href", "#finish");
                                            $("#processing").removeClass("fas fa-sync fa-spin");
                                            $("#caseDiseaseReportWizard").steps("setStep", 3);
                                        }
                                    });
                                } else {
                                    $("#saveButton").attr("href", "#finish");
                                    $("#processing").removeClass("fas fa-sync fa-spin");
                                    $("#caseDiseaseReportWizard").steps("setStep", 2);
                                }
                            });
                        } else {
                            $("#saveButton").attr("href", "#finish");
                            $("#processing").removeClass("fas fa-sync fa-spin");
                            $("#caseDiseaseReportWizard").steps("setStep", 1);
                        }
                    });
                } else {
                    $("#saveButton").attr("href", "#finish");
                    $("#processing").removeClass("fas fa-sync fa-spin");
                    $("#caseDiseaseReportWizard").steps("setStep", 0);
                }
            });
        }
    });
};

function reloadClinicalInvestigationSection(currentStepNumber) {
    ClinicalInvestigationSection.DotNetReference.invokeMethodAsync("ReloadSection", false, currentStepNumber);
};

function reloadClinicalInformationSection() {
    ClinicalInformationSection.DotNetReference.invokeMethodAsync("ReloadSection", false);
};

function reloadOnTypeOfCaseChange() {
    ClinicalInformationSection.DotNetReference.invokeMethodAsync("ReloadSection", true);

    if (CaseMonitoringSection.DotNetReference != null)
        CaseMonitoringSection.DotNetReference.invokeMethodAsync("ReloadSection", true);

    OutbreakInvestigationSection.DotNetReference.invokeMethodAsync("ReloadSection", true);
};

function reloadAvianSections(isReview, currentStepNumber) {
    if (DiseaseReportSummary != null)
        if (DiseaseReportSummary.DotNetReference != null)
            DiseaseReportSummary.DotNetReference.invokeMethodAsync("RefreshSummary", isReview);

    if (FarmDetailsSection != null)
        if (FarmDetailsSection.DotNetReference != null)
            FarmDetailsSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);

    if (NotificationSection != null)
        if (NotificationSection.DotNetReference != null)
            NotificationSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (FarmInventorySection != null)
        if (FarmInventorySection.DotNetReference != null)
            FarmInventorySection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (FarmEpidemiologicalInformationSection != null)
        if (FarmEpidemiologicalInformationSection.DotNetReference != null)
            FarmEpidemiologicalInformationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);
    
    if (ClinicalInvestigationSection != null)
        if (ClinicalInvestigationSection.DotNetReference != null)
            ClinicalInvestigationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview, currentStepNumber);

    if (VaccinationsSection != null)
        if (VaccinationsSection.DotNetReference != null)
            VaccinationsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (SamplesSection != null)
        if (SamplesSection.DotNetReference != null)
            SamplesSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (PensideTestsSection != null)
        if (PensideTestsSection.DotNetReference != null)
            PensideTestsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (LaboratoryTestsAndResultsSummaryAndInterpretationSection != null)
        if (LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference != null)
            LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (CaseLogsSection != null)
        if (CaseLogsSection.DotNetReference != null)
            CaseLogsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
};

function reloadLivestockSections(isReview, currentStepNumber) {
    if (DiseaseReportSummary != null)
        if (DiseaseReportSummary.DotNetReference != null)
            DiseaseReportSummary.DotNetReference.invokeMethodAsync("RefreshSummary", isReview);

    if (FarmDetailsSection != null)
        if (FarmDetailsSection.DotNetReference != null)
            FarmDetailsSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);

    if (NotificationSection != null)
        if (NotificationSection.DotNetReference != null)
            NotificationSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (FarmInventorySection != null)
        if (FarmInventorySection.DotNetReference != null)
            FarmInventorySection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (FarmEpidemiologicalInformationSection != null)
        if (FarmEpidemiologicalInformationSection.DotNetReference != null)
            FarmEpidemiologicalInformationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);

    if (ClinicalInvestigationSection != null)
        if (ClinicalInvestigationSection.DotNetReference != null)
            ClinicalInvestigationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview, currentStepNumber);

    if (VaccinationsSection != null)
        if (VaccinationsSection.DotNetReference != null)
            VaccinationsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (AnimalsSection != null)
        if (AnimalsSection.DotNetReference != null)
            AnimalsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (ControlMeasuresSection != null)
        if (ControlMeasuresSection.DotNetReference != null)
            ControlMeasuresSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);

    if (SamplesSection != null)
        if (SamplesSection.DotNetReference != null)
            SamplesSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (PensideTestsSection != null)
        if (PensideTestsSection.DotNetReference != null)
            PensideTestsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (LaboratoryTestsAndResultsSummaryAndInterpretationSection != null)
        if (LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference != null)
            LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (CaseLogsSection != null)
        if (CaseLogsSection.DotNetReference != null)
            CaseLogsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
};

function reloadCaseSections(isReview) {
    if (CaseSummary != null)
        if (CaseSummary.DotNetReference != null)
            CaseSummary.DotNetReference.invokeMethodAsync("RefreshSummary", isReview);

    if (CaseLocationSection != null)
        if (CaseLocationSection.DotNetReference != null)
            CaseLocationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);

    if (NotificationSection != null)
        if (NotificationSection.DotNetReference != null)
            NotificationSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (FarmInventorySection != null)
        if (FarmInventorySection.DotNetReference != null)
            FarmInventorySection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (ClinicalInformationSection != null)
        if (ClinicalInformationSection.DotNetReference != null) {
            ClinicalInformationSection.DotNetReference.invokeMethodAsync("ReloadSection", isReview);
        }

    if (OutbreakInvestigationSection != null)
        if (OutbreakInvestigationSection.DotNetReference != null)
            OutbreakInvestigationSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (CaseMonitoringSection != null)
        if (CaseMonitoringSection.DotNetReference != null)
            CaseMonitoringSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (VaccinationsSection != null)
        if (VaccinationsSection.DotNetReference != null)
            VaccinationsSection.DotNetReference.invokeMethodAsync("ReloadSection");

    if (SamplesSection != null)
        if (SamplesSection.DotNetReference != null)
            SamplesSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (PensideTestsSection != null)
        if (PensideTestsSection.DotNetReference != null)
            PensideTestsSection.DotNetReference.invokeMethodAsync("ReloadSection");
    
    if (LaboratoryTestsAndResultsSummaryAndInterpretationSection != null)
        if (LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference != null)
            LaboratoryTestsAndResultsSummaryAndInterpretationSection.DotNetReference.invokeMethodAsync("ReloadSection");

    $("#saveButton").attr("href", "#finish");
    $("#processing").removeClass("fas fa-sync fa-spin");
};

function hideCaseDiseaseReportStep(stepNumber) {
    $("#caseDiseaseReportWizard").steps("hide", stepNumber);
};

function showCaseDiseaseReportStep(stepNumber) {
    $("#caseDiseaseReportWizard").steps("show", stepNumber);
    $("#caseDiseaseReportWizard").steps("setStep", 2);
};