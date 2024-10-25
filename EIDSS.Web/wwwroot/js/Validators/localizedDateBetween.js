$(function () {
    
    $.validator.unobtrusive.adapters.add
        ('datebetween', ['fromdate', 'todate', 'validationmessage', 'language'], function (options) {
            var attribs = {
                fromdate: options.params['fromdate'],
                todate: options.params.todate,
                language: options.params.language,
                validationmessage: options.params.validationmessage
            };
            options.rules['datebetween'] = attribs;
            if (options.message) {
                $.validator.messages['datebetween'] = options.message;
            }
        });

    $.validator.addMethod(
        'datebetween',
        function (value, element, params) {
            
            var dateFormat = "L";
            var result = false;
            if (value == "") {
                result = true;
            }
            else if (value != null && params['fromdate'] != null && params['todate'] != null) {
                var startdatevalue = $('#' + params['fromdate']).datepicker().val();
                //var startdatevalue = $('input[id="' + params['fromdate'] + '"]').datepicker().val();
               // var enddatevalue = $('input[id="' + params['todate'] + '"]').datepicker().val
                var enddatevalue = $('#' + params['todate']).datepicker().val();
                validationMessage = moment.locale(params['validationmessage']);
                moment.locale(params['language']);

                let localeFormat = moment.localeData(params['language']).longDateFormat('L');
                var date = moment(value, localeFormat);
                var sDate = moment(startdatevalue, localeFormat);
                var eDate = moment(enddatevalue, localeFormat);
              
                if (date.isValid() && sDate.isValid() && eDate.isValid()) {

                    if (date >= sDate && date <= eDate) {
                        result= true;
                    }
                    else {
                        result= false;
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