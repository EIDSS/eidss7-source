// Custom validation script for the Localized Required-If True validator.
// Called in the validation scripts partial view.
//
// Note that, jQuery validation registers its rules before the DOM is loaded. 
// If it is registered after the DOM is loaded, the rules will not be processed.
$.validator.unobtrusive.adapters.add("localizedrequirediftrue", ["required"], function (options) {
    options.rules["localizedrequirediftrue"] = {
        required: options.params["required"]
    };
    options.messages["localizedrequirediftrue"] = options.message;
});

$.validator.addMethod("localizedrequirediftrue", function (value, element, parameters) {
    return $.validator.methods.required.call(this, value, element, parameters);
});