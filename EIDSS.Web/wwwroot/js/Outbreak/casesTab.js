var CasesTab = (function() {
    var module = this;

    module.DotNetReference = null;
    module.SetDotNetReference = function(pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    module.init = function() {
    };

    return module;
})();

$(document).ready(CasesTab.init());

var CasesTab = {};
CasesTab.DotNetReference = null;
CasesTab.SetDotNetReference = function (pDotNetReference) {
    CasesTab.DotNetReference = pDotNetReference;
};

function importCase(module, callbackKey, callbackUrl, cancelUrl, diseaseId) {
    switch (module) {
    case "Human":
        CasesTab.DotNetReference.invokeMethodAsync("OnImportHumanDiseaseReport",
            callbackKey,
            callbackUrl,
            cancelUrl,
            diseaseId);
        break;
    case "Veterinary":
        CasesTab.DotNetReference.invokeMethodAsync("OnImportVeterinaryDiseaseReport",
            callbackKey,
            callbackUrl,
            cancelUrl,
            diseaseId);
        break;
    }
};