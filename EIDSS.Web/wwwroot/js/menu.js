

    $('#languageId').on('change', function () {
        var langId = $("#languageId").val();



        $.ajax({
            
            url: '@Url.Action("SetLanguage", "CultureManagment", new { Area = "CrossCutting", SubArea = "" })' +'? langId=' + langId,
            type: 'POST',
            contentType: 'application/json; charset=utf-8'
        })
            .done(function (data) {

            })

    });

        