

var GLOBAL = {};


GLOBAL.DotNetReference = null;
GLOBAL.SetDotnetReference = function (pDotNetReference) {
    GLOBAL.DotNetReference = pDotNetReference;
};


function getDomElementValue(elementId) {

    var element = "#" + elementId;
    var idValue = $(element).val();
    return idValue;
   
}

function blazorGetTimezoneOffset() {
    return new Date().getTimezoneOffset();
}