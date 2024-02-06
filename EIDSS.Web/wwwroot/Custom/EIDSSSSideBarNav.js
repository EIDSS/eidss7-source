function ShowPreview() {

    var IDs = [];
    $("#nav-tabContent").find("div").each(function () { IDs.push(this.id); });
   
    //alert(JSON.stringify(IDs));
    for (var i = 0; i < IDs.length; i++) {
        $("#" + IDs).addClass("active show");

    }
}