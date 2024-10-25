var Laboratory = {
    init: function () {
        document.querySelectorAll("#divSearch input").forEach(function (oInput) {
            if (oInput.type == "button" || oInput.readonly) {
                return;
            }

            oInput.addEventListener("change", function () {
                console.log("onScan configuration updated");
                onScan.detachFrom(document);
                scanSampleID();
            });
        });
    },

    // Customization for the accession and add group result Bootstrap popover controls.
    addPopover: function () {
        $(".popover-window").popover({
            container: "body",
            html: true,
            sanitize: false,
            trigger: "manual",
            content: function () {
                return $(this).next(".popover-content").html();
            }
        }).click(function (e) {
            $(this).popover("toggle");
            $(".popover-window").not(this).popover("hide");

            e.stopPropagation();
        });
    },

    hideMyFavoritesPopover: function () {
        $("#myFavoritesTabAccessionButton").popover("hide");
    },

    hideSamplesPopover: function () {
        $("#samplesTabAccessionButton").popover("hide");
    },

    showMyFavoritesPopover: function () {
        $("#myFavoritesTabAccessionButton").popover("show");
    },

    showSamplesPopover: function () {
        $("#samplesTabAccessionButton").popover("show");
    },

    // Barcode scanning of local/field or laboratory sample identifiers into the simple search box.
    scanSampleID: function () {
        onScan.attachTo(document, {
            suffixKeyCodes: [13], // enter-key expected at the end of a scan
            reactToPaste: false, // Compatibility to built-in scanners in paste-mode (as opposed to keyboard-mode)
            onScan: function (sCode) { // Alternative to document.addEventListener('scan')
                $("#simpleSearchString").val(sCode);

                setTimeout(function () {
                    $("#simpleSearch").focus();
                });
            },
            onKeyDetect: function (iKeyCode) { // output all potentially relevant key events - great for debugging!
                console.log("Pressed: " + iKeyCode);
            }
        });
    }
}

var LaboratoryActions = {};
LaboratoryActions.DotNetReference = null;
LaboratoryActions.SetDotNetReference = function (pDotNetReference) {
    LaboratoryActions.DotNetReference = pDotNetReference;
};

var LaboratoryCreateSampleDivision = {};
LaboratoryCreateSampleDivision.DotNetReference = null;
LaboratoryCreateSampleDivision.SetDotNetReference = function (pDotNetReference) {
    LaboratoryCreateSampleDivision.DotNetReference = pDotNetReference;
};

function showProcessingIndicator() {
    $("#processing").addClass("fas fa-sync fa-spin");

    LaboratoryActions.DotNetReference.invokeMethodAsync("OnSaveClick");
};

function hideProcessingIndicator() {
    $("#processing").removeClass("fas fa-sync fa-spin");
};

function showApproveProcessingIndicator() {
    $("#approveProcessing").addClass("fas fa-sync fa-spin");

    LaboratoryActions.DotNetReference.invokeMethodAsync("OnApproveClick");
};

function hideApproveProcessingIndicator() {
    $("#approveProcessing").removeClass("fas fa-sync fa-spin");
};

function showRejectProcessingIndicator() {
    $("#rejectProcessing").addClass("fas fa-sync fa-spin");

    LaboratoryActions.DotNetReference.invokeMethodAsync("OnRejectClick");
};

function hideRejectProcessingIndicator() {
    $("#rejectProcessing").removeClass("fas fa-sync fa-spin");
};

function showSampleDivisionProcessingIndicator() {
    $("#sampleDivisionProcessing").addClass("fas fa-sync fa-spin");

    LaboratoryCreateSampleDivision.DotNetReference.invokeMethodAsync("OnSaveClick");
};

function hideSampleDivisionProcessingIndicator() {
    $("#sampleDivisionProcessing").removeClass("fas fa-sync fa-spin");
};

function closeMenu() {
    $("#laboratoryMenu").dropdown("toggle");
};

function scrollToTop() {
    try {
        var elem = document.getElementsByClassName("rz-data-grid-data")[0];
        elem.scrollTop = 0;
    }
    catch (ex) {
        console.log(ex);
    }
};

$(document).ready(
    Laboratory.init
);