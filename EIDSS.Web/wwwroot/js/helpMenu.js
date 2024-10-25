
// initialize
var HelpFilesMenu = (() => {
    debugger;

    var module = this;

    module.init = () => {
    };

    module.DotNetReference = null;
    module.SetDotNetReference = function (pDotNetReference) {
        module.DotNetReference = pDotNetReference;
    };

    return module;
})();

$(document).ready(HelpFilesMenu.init());

function toggleHelp() {
    debugger;

    //var helpData = document.getElementById("ucPageHeader_hdfHelpData");
    //var data = jQuery.parseJSON(helpData.value);
    dotNetObject.invokeMethodAsync('AddText', text.toString());

    $("#ddlHelpLinks").empty();

    $("#ddlHelpLinks").menu();

    for (i = 0; i < data.length; i++) {
        fileType = data[i].FileName.split(".");

        if (fileType[fileType.length - 1] == "pdf")
            $("#ddlHelpLinks").append("<li><a href='https://" + data[i].FileName + "' rel='help' target='_blank'><span class='glyphicon glyphicon-book'></span> " + data[i].DocumentName + "</a></li>");
        else
            $("#ddlHelpLinks").append("<li><a href='https://" + data[i].FileName + "' rel='help' target='_blank'><span class='glyphicon glyphicon-facetime-video'></span> " + data[i].DocumentName + "</a></li>");

        if (i < data.length - 1)
            $("#ddlHelpLinks").append("<li role='separator' class='divider'></li>");
    };
};

function validateForSave(wizard, stepNumber) {
    var result = new Promise(function (validateSection, reject) {
        validateSection(HelpFilesMenu.DotNetReference.invokeMethodAsync("ValidateFarmReviewSection"))
        HelpFilesMenu.DotNetReference.invokeMethodAsync("ShowHelpFiles");
    });
    //result.then(function (value) {
    //    if (value) {
    //        $("#" + wizard + "-t-" + stepNumber).find("#erroredStep").hide();
    //        $("#" + wizard + "-t-" + stepNumber).find("#completedStep").show();
    //    }
    //});
};


