$.validator.unobtrusive.adapters.add("localizedrequiredwhenothervaluenotpresent", ["otherproperty", "otherpropertyelement", "otherpropertyvalue"], function (options) {
    options.rules["localizedrequiredwhenothervaluenotpresent"] = options.params;
    options.messages["localizedrequiredwhenothervaluenotpresent"] = options.message
});

$.validator.addMethod("localizedrequiredwhenothervaluenotpresent", function (value, element, parameters) {
    var targetID = parameters.otherpropertyelement;
    var targetValue = parameters.otherpropertyvalue;
    var otherPropertyValue = (targetValue == null || targetValue == undefined ? "false" : targetValue);
    var otherPropertyElement = $("#" + targetID);

    if (value == undefined && otherPropertyElement.val().toString() != otherPropertyValue.toString() && otherPropertyElement.val() != "") {
        return false;
    }
    else if ((value.trim() == "" || value.trim() == null) && otherPropertyElement.val().toString() != otherPropertyValue.toString() && otherPropertyElement.val() != "") {
        var isValid = $.validator.methods.required.call(this, value, element, parameters);
        return isValid;
    }

    return true;
});