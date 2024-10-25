


$(function () {
    jQuery.validator.addMethod('rulename',

        function (value, element, params) {

            var name = params[1];
            if (value == name)
                {
                return false;
            }
             

            return true;
        });

    jQuery.validator.unobtrusive.adapters.add('rulename', ['userName'], function (options) {
        var element = $(options.form).find('#userName');

        options.rules['rulename'] = [element, options.params['userName']];
        options.messages['rulename'] = options.message;
    });
}(jQuery));