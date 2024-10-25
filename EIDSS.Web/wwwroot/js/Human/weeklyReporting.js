var WeeklyReporting = (function () {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function () {
    };

    return module;
})();

$(document).ready(WeeklyReporting.init());

function getDomElementValue(elementId) {

    var element = "#" + elementId;
    var idValue = $(element).val();
    return idValue;

}
