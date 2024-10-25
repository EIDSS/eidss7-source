$(function () {
    $.validator.unobtrusive.adapters.add
        ("integercomparer", ["from", "to", "compare", "message"], function (options) {
            var attribs = {
                from: options.params.from,
                to: options.params.to,
                compare: options.params.compare,
                message: options.params.message
            };
            options.rules["integercomparercheck"] = attribs;

            if (options.message) {
                $.validator.messages.integercomparercheck = options.message;
            }
        });

    $.validator.addMethod(
        "integercomparercheck",
        function (value, element, params) {
            var result = false
            if (value == "") {
                result = true;
            }
            else if (value && (params["from"] != null && params["to"] != null)) {
                var fromValue = $('select[id="' + params['from'] + '"]').val();
                var toValue = $('select[id="' + params['to'] + '"]').val();

                if (fromValue == "" || toValue == "") {
                    result = true;
                }
                else {
                    if (params["compare"] == "GreaterThan") {
                        result = fromValue > toValue;
                    }
                    if (params["compare"] == "GreaterThanOrEqualTo") {
                        result = fromValue >= toValue;
                    }
                    else if (params["compare"] == "LessThan") {
                        result = fromValue < toValue;
                    }
                    else if (params["compare"] == "LessThanOrEqualTo") {
                        result = fromValue <= toValue;
                    }
                    else if (params["compare"] == "Equals") {
                        result = fromValue == toValue;
                    }
                }
            }

            return result;
        }
    );
}());