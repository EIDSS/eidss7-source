// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.
var Notification = {};
Notification.DotNetReference = null;
Notification.SetDotNetReference = function (pDotNetReference) {
    Notification.DotNetReference = pDotNetReference;
};

function updateNotificationEnvelopeCount() {
    var messageCount = document.getElementById("messageCount").textContent;
    document.getElementById("messageCount").innerHTML = (+messageCount + 1);
};

function setNotificationEnvelopeCount() {
    document.getElementById("messageCount").innerHTML = 0;
};