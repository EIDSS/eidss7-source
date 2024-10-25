$(function () {
    $.validator.unobtrusive.adapters.add
        ('localizeddatelessthanorequaltotoday', ['language'], function (options) {
            var attribs = {
                firstdate: options.params.inputDate,
                language: options.params.language
            };
            options.rules['datelessthanorequaltotoday'] = attribs;
            if (options.message) {
                $.validator.messages.datelessthanorequaltotoday = options.message;
            }
        });

    $.validator.addMethod(
        'datelessthanorequaltotoday',
        function (value, element, params) {
            var dateFormat = "L";
            moment.locale(params['language']);
            let localeFormat = moment.localeData(params['language']).longDateFormat('L');

            var result = false;
            let sDate = moment(new Date(), localeFormat);

            if (value) {
                sDate = moment(value, localeFormat);
            }

            var today = moment(new Date(), localeFormat);

            if (!sDate.isValid()) {
                result = false;
            } else if (sDate >today) {
                result = false;
            }
            else {
                result = true;
            }
            
            return result;
        }
    );
}());