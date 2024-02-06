$(function () {
    $.validator.unobtrusive.adapters.add
        ('localizedstringarraymax', ['maxsize'], function (options) {
            var attribs = {
                maxsize: options.params.maxsize,
            };
            options.rules['stringarraymax'] = attribs;
            if (options.message) {
                $.validator.messages.stringarraymax = options.message;
            }
        });

    $.validator.addMethod(
        'stringarraymax',
        function (value, element, params) {
            var result = false;
            var maxSize = params['maxsize'];
            if (value === undefined || value.length == 0 || value.length > maxSize) {
                result = false;
            }
            else {
                result = true;
            }

            return result;
        }
    );
}());