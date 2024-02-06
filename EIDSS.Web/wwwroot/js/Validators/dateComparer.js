$(function () {
    $.validator.unobtrusive.adapters.add
        ("datecomparer", ["firstdate", "seconddate", "compare", "language"], function (options) {

            options.rules['datecomparer'] = options.params;
            options.messages['datecomparer'] = options.message;
        });

    $.validator.addMethod("datecomparer",
        function (value, element, params) {
            var result = false
            if (value == "") {
                result = true;
            }
            else if (value && (params["firstdate"] != null && params["seconddate"] != null)) {
                var startdatevalue = $('input[id="' + params["firstdate"] + '"]').datepicker().val();
                var enddatevalue = $('input[id="' + params["seconddate"] + '"]').datepicker().val();
                moment.locale(params["language"]);

                let localeFormat = moment.localeData(params["language"]).longDateFormat("L");

                var sDate = moment(startdatevalue, localeFormat);
                var eDate = moment(enddatevalue, localeFormat);

                if (startdatevalue == "" || enddatevalue == "") {
                    result = true;
                }
                else if (sDate.isValid() && eDate.isValid()) {
                    if (params["compare"] == "GreaterThan") {
                        result = sDate > eDate;
                    }
                    if (params["compare"] == "GreaterThanOrEqualTo") {
                        result = sDate >= eDate;
                    }
                    else if (params["compare"] == "LessThan") {
                        result = sDate < eDate;
                    }
                    else if (params["compare"] == "LessThanOrEqualTo") {
                        result = sDate <= eDate;
                    }
                    else if (params["compare"] == "Equals") {
                        result = sDate == eDate;
                    }
                }
                else {
                    result = false;
                }
            }

            return result;
        }
    );
}());