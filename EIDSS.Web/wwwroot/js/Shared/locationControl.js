
function addInputElement(elementId) {

    $(".inner").append("<p>Test</p>");

    var element = "#" + elementId;

    $(element).append("<input type = 'text' ></text >");



}

function clearSearchText(elementId) {

    //var element = "#" + elementId;
    //$(element).find('label').val('');

    //var searchText = $('input[id^="search"]').val();

    $('input[id^="search"]').val('')

    return elementId;
    

}



//var LocationControl = (function () {
//    var module = this;

//    module.init = function () {
//    };

//    function addInputElement(elementId) {

//        $(".inner").append("<p>Test</p>");

//        var element = "#" + elementId;

//        $(element).append("<input type = 'text' ></text >");



//    }

//    return module;
//}) ();

//$(document).ready(LocationControl.init());