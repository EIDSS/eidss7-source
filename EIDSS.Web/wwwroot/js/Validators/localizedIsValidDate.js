// Custom validation script for the Localized IsValidDate
// Called in the validation scripts partial view.
$(function () {

    $.validator.unobtrusive.adapters.add("isvaliddate", ['language'], function (options) {
        var attribs = {
            language: options.params.language
        };
        options.rules['isvaliddatechk'] = attribs;
        if (options.message) {
            $.validator.messages.isvaliddatechk = options.message;
        }
    });

    $.validator.addMethod("isvaliddatechk",
        function (value, element, params) {
            var result = false;
            var dateFormat = "L";
            moment.locale(params['language']);
            let localeFormat = moment.localeData(params['language']).longDateFormat('L');
            var dateFormat = "M/D/YYYY";
            if (params['language'] == "en") {
                dateFormat = "M/D/YYYY";
            } else if (params['language'] == "az") {
                dateFormat = "D.M.YYYY";
            } else if (params['language'] == "ka") {
                dateFormat = "D.M.YYYY";
            } else if (params['language'] == "ru") {
                dateFormat = "D.M.YYYY";
            }  else {
                dateFormat = moment.localeData(params['language']).longDateFormat('L');
            }
            var date = moment(value,dateFormat,true);
            //var date = moment(value,localeFormat,true);
            //date = moment(date).locale(params['language']);

            if (value == "") {
                result = true;
            }
            else if (moment(date).isValid())
            {
                result = true;
            }
            return result;
        }
    );
}());


