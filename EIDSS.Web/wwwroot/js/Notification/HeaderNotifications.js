var notification = {

    notificationUrl: '',

    getNotifications: function () {
        $.ajax({
            url: '../Handlers/NotificationHandler.ashx',
            type: 'POST',
            dataType: 'json',
            data: {
                SiteId: siteId,
                UserID: userId
            },
            async: true,
            success: function (data) {
                // alert(data);
                var notificatonData = data
                BuildNotificationTableWithData(JSON.stringify(notificatonData));
            },
            error: function (request, error) {
                console.log("Request: " + JSON.stringify(error) + " Notifications Error");
            }
        });
    },

    buildNotificationTableWithData: function (data, messageElement, notificationTable) {
        var notificationData = data;
        // alert(data);
        deserializednotificationObj = JSON.parse(notificationData);
        NotificationTableData = [];
        $(messageElement).html(deserializednotificationObj.length);
        for (var i = 0; i < deserializednotificationObj.length; i++) {
            item = [];
            tableRow = new Object();
            item.push(deserializednotificationObj[i].strPayload);
            item.push(deserializednotificationObj[i].AuditCreateDTM);
            item.push(deserializednotificationObj[i].idfsSite);
            item.push(deserializednotificationObj[i].strRegion);
            item.push(deserializednotificationObj[i].strRayon);
            item.push("");// item.push(deserializednotificationObj[i].intProcessed);
            item.push(deserializednotificationObj[i].idfNotification);

            NotificationTableData.push(item);
        }

        if ($.fn.dataTable.isDataTable(notificationTable)) {
            table = $(notificationTable).DataTable();
            table.destroy();
        }

        table = $(notificationTable).DataTable({
            processing: true,
            data: NotificationTableData,
            columns: [
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Message_Type.Text") %>' },
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Date.Text") %>' },
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Site.Text") %>' },
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Region.Text") %>' },
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Rayon.Text") %>' },
                //{ title: '<%= GetLocalResourceObject("Grd_Notifications_List_Disease.Text") %>' },
                //{ title: " " }
                { title: '1' },
                { title: '2' },
                { title: '3' },
                { title: '4' },
                { title: '5' },
                { title: '6' },
                { title: " " }
            ],
            columnDefs: [{
                //Index
                targets: [0], type: "dom-text", render: function (data, type, row, meta) {
                    return data;
                }
            },
            {
                //Sanitary Actions
                targets: [1], type: "dom-text", render: function (data, type, row, meta) {
                    return data;
                }
            },
            {
                //Action Code
                targets: [2], visible: true, type: "dom-text", render: function (data, type, row, meta) {
                    return data;
                }
            },
            {
                //idfAction
                targets: [3],
                visible: true
            },
            {
                //MatrixID
                targets: [4],
                visible: true
            },
            {
                //MatrixID
                targets: [5],
                visible: true
            },
            {
                //MatrixID
                targets: [6], render:
                    function (data, type, row, meta) { return createActions(data, type, row, meta); }
            }
            ],
            deferRender: true,
            order: [],
            // ordering: true,
            searching: false,
            bLengthChange: true,
            select: true,
            rowReorder: true,
            language: { "url": getLanguage() }
        });

    },

    createActions: function (data, type, row, meta) {
        var sel = '';
        sel += "<a href='#' title='' onclick='readUpdateNotifications(" + data + ");'><span class='glyphicon glyphicon-trash'></span></option>";
        return sel;
    },

    showNotifications: function (modelId) {
        $("siteAlertModal").modal({
            show: true,
            backdrop: false
        })
    },

    readUpdateNotifications: function (id,notificationTableElement) {
        notificationId = id;

        // console.log(baseRoute);
        $.ajax({
            url: '../Handlers/ReadUpdateNotificationHandler.ashx',
            type: 'POST',
            dataType: 'json',
            data: {
                NotificationId: notificationId,
                UserId: userId
            },
            success: function (data) {
                GetNotifications();
                table = $(notificationTableElement).DataTable();
                table.draw();
            },
            error: function (request, error) {
                console.log("Request: " + JSON.stringify(request) + " Notifications Error");
            }
        });
    }

}