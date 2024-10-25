$(document).ready(function () {
    var CaseMonitoringSection = {};
    CaseMonitoringSection.DotNetReference = null;
    CaseMonitoringSection.SetDotNetReference = function (pDotNetReference) {
        CaseMonitoringSection.DotNetReference = pDotNetReference;
    };
});

var humanCase = {
    humanCaseURL: '',
    init: function () {
    },

    createCase: function() {
        location.href = '@Url.Action("Index","OutbreakSession", new { Area = "Outbreak" })';
    }
}

function toggleCaseSummary() {
        if ($("#dOutbreakCaseSummary").hasClass("show")) {
            $("#toggleCaseSummaryIcon").removeClass("fas fa-2x e-dark-blue fa-caret-up").addClass("fas fa-2x e-dark-blue fa-caret-down");
        }
        else {
            $("#toggleCaseSummaryIcon").removeClass("fas fa-2x e-dark-blue fa-caret-down").addClass("fas fa-2x e-dark-blue fa-caret-up");
        }
    };