
var VeterinaryAggregateDiseaseReport = (function () {

    var module = {};

    module.init = () => {
    };

    function cancelAggregateDiseaseReportDetails(message, event) {
        event.preventDefault();

        showWarningModal(message).then(response => {
            if (response) {
                if ('@Model.ShowInModalIndicator' == "True") {
                    $("#warningModal").modal("hide");
                    $(".modal-backdrop").remove();
                    return true;
                }
                else
                    location.href = '@Url.Action("Index", "VeterinaryAggregateDiseaseReport")';
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
        $("#aggregateReportWizard-t-0").find("#step").hide();
        $("#aggregateReportWizard-t-1").find("#step").hide();
    }

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.ReportDetailsSection = {};
    module.ReportDetailsSection.DotNetReference = null;
    module.ReportDetailsSection.SetDotNetReference = function (pDotNetReference) {
        module.ReportDetailsSection.DotNetReference = pDotNetReference;
    };

    module.DiseaseMatrixSection = {};
    module.DiseaseMatrixSection.DotNetReference = null;
    module.DiseaseMatrixSection.SetDotNetReference = function (pDotNetReference) {
        module.DiseaseMatrixSection.DotNetReference = pDotNetReference;
    };

    module.destroySidebar = function () {
        $("#aggregateReportWizard").steps("destroy");
    };

    module.initializeSidebar = function (cancelButtonText, finishButtonText, nextButtonText, previousButtonText, loadingMessageText, cancelMessageText, deleteButtonText, printButtonText, deleteMessageText, enableDeleteButton, enableSaveButton, startIndex) {
        $("#aggregateReportWizard").steps({
            headerTag: "h4",
            titleTemplate: '<span id="erroredStep" class="fa-stack text-danger" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-times fa-stack-1x fa-inverse"></i></span><span id="step" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="completedStep" class="fa-stack text-success" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-check fa-stack-1x fa-inverse"></i></span><span id="reviewStep" class="fa-stack text-muted" title="#title#"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-clipboard-list fa-stack-1x fa-inverse"></i></span> <span class="stepTitleText">#title#</span>',
            bodyTag: "section",
            isBlazor: true,
            transitionEffect: "none",
            stepsOrientation: "vertical",
            enableAllSteps: true,
            enableCancelButton: true,
            enablePrintButton: true,
            enableKeyNavigation: true,
            enableContentCache: true,
            enableDeleteButton: enableDeleteButton,
            enableFinishButton: enableSaveButton,
            labels: {
                cancel: cancelButtonText,
                print: printButtonText,
                delete: deleteButtonText,
                finish: finishButtonText,
                next: nextButtonText,
                previous: previousButtonText,
                loading: loadingMessageText
            },
            onInit: function (event) {
                $("#aggregateReportWizard .steps ul").append('<li id="saveStep" role="tab"><a href="#" role="menuitem"><span class="fa-stack text-muted"><i class="fas fa-circle fa-stack-2x"></i><i class="fas fa-save fa-stack-1x fa-inverse"></i></span>  <span class="stepTitleText">' + finishButtonText +'</span></a></li>');

                $(document).on('click', '#saveStep', function (e) {
                    e.preventDefault();
                    $("#aggregateReportWizard").steps("finish");
                });
            },
            onCanceled: function (event) {
                VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync('OnCancel');
            },
            onDeleting: function (event) {
                console.log("delete called");
                VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync('OnDelete');
            },
            onPrinting: function (event) {
                console.log("print called");
                VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync('OnPrint');
            },
            onStepChanging: function (event, currentIndex, newIndex) {
                switch (currentIndex) {
                    case 0:
                        VeterinaryAggregateDiseaseReport.validateVetAggregateDiseaseReportSection(VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference, "aggregateReportWizard", currentIndex, newIndex);
                        break;
                    case 1:
                        VeterinaryAggregateDiseaseReport.validateVetAggregateDiseaseReportSection(VeterinaryAggregateDiseaseReport.DiseaseMatrixSection.DotNetReference, "aggregateReportWizard", currentIndex, newIndex);
                        break;
                    default:
                        return true;
                }
            },
            onStepChanged: function (event, currentIndex, priorIndex) {
                switch (currentIndex) {
                    case 0: //Report Information Section
                        VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                        break;
                    case 1: //Diagnostic Investigations Section
                        VeterinaryAggregateDiseaseReport.DiseaseMatrixSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                        break;
                    case 2: //Review Section
                        VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                        VeterinaryAggregateDiseaseReport.DiseaseMatrixSection.DotNetReference.invokeMethodAsync("SetReportDisabledIndicator", currentIndex);
                        break;
                    default:
                        return true;
                }
            },
            onFinished: async function (event) {
                var isReportDetailsSectionValid = await VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync("ValidateSection");
                var isDiseaseMatrixSectionValid = await VeterinaryAggregateDiseaseReport.DiseaseMatrixSection.DotNetReference.invokeMethodAsync("ValidateSection");
                var valid = isReportDetailsSectionValid && isDiseaseMatrixSectionValid;

                hideDefaultStepIcons();
                setWizardState(valid, "#aggregateReportWizard-t-0");
                $("#aggregateReportWizard-t-1").find("#completedStep").show();

                if (valid) {
                    VeterinaryAggregateDiseaseReport.ReportDetailsSection.DotNetReference.invokeMethodAsync('OnSubmit');
                }
            }
        });

    };

    module.navigateToReviewStep = function () {
        $("#aggregateReportWizard").steps("setStep", 2);
    };

    module.validateVetAggregateDiseaseReportSection = function (dotNetReference, wizard, stepNumber, newIndex) {

        if (newIndex == 2) {

            var result = new Promise(function (validateVetAggregateDiseaseReportSection, reject) {
                validateVetAggregateDiseaseReportSection(dotNetReference.invokeMethodAsync("ValidateSection"));
            });

            result.then(function (value) {
                if (value) {

                    console.log("value: " + value);

                    $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                    $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
                }
            });
        } else {

            var result = new Promise(function (validateVetAggregateDiseaseReportSection, reject) {
                validateVetAggregateDiseaseReportSection(dotNetReference.invokeMethodAsync("ValidateSection"));
            });

            result.then(function (value) {
                if (value) {
                    $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
                    $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
                }
            });
        }
    };

    return module;

}());

$(document).ready(VeterinaryAggregateDiseaseReport.init());




