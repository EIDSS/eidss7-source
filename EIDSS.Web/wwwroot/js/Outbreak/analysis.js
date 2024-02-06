var outbreakAnalysis = {
    showHeatMap: function () {
        $(document).ready(function () {
            var lat = $("#hdnHeatMap_Lat").val();
            var long = $("#hdnHeatMap_Long").val();
            var zoom = $("#hdnHeatMap_Zoom").val();
            var data = $("#hdnHeatMap_Data").val();
            var addressPoints = eval('[' + data + ']');

            if (addressPoints.length > 0) {
                lat = addressPoints[0][0];
                long = addressPoints[0][1];

                map = new L.map('map').setView([lat, long], zoom);

                tiles = new L.tileLayer('https://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors',
                }).addTo(map);

                addressPoints = addressPoints.map(function (p) { return [p[0], p[1]]; });

                heat = new L.heatLayer(addressPoints).addTo(map);
            }
            else {
                photonUrl = 'https://photon.komoot.io/api/?q=Georgia&osm_tag=place:country';

                $.ajax({
                    url: photonUrl,
                    type: 'GET',
                    dataType: 'json',
                    success: function (data2) {
                        if (data2.features[0] != undefined) {
                            defaultLat = data2.features[0].geometry.coordinates[1];
                            defaultLong = data2.features[0].geometry.coordinates[0];

                            map = new L.map('map').setView([defaultLat, defaultLong], zoom);

                            tiles = new L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                                attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors',
                            }).addTo(map);
                        }
                    },
                    headers: {
                        /*'Access-Control-Allow-Origin': '*',*/
                        'Access-Control-Allow-Credentials': true,
                    },
                    error: function (request, error) {
                        alert("Request: " + JSON.stringify(request) + '.' + ' Error: ' + JSON.stringify(error));
                    }
                });
            }
        });
    },

    redrawHeatMap: function () {
        var data = $("#hdnHeatMap_Data").val();
        var addressPoints_unfiltered = eval('[' + data + ']');
        var addressPoints = [];

        if (!$("#EIDSSBodyCPH_chkHeatMapHuman").is(":checked") &&
            !$("#EIDSSBodyCPH_chkHeatMapAvian").is(":checked") &&
            !$("#EIDSSBodyCPH_chkHeatMapLivestock").is(":checked") &&
            !$("#EIDSSBodyCPH_chkHeatMapVector").is(":checked")) {
            addressPoints = addressPoints_unfiltered;
        }
        else {
            $(addressPoints_unfiltered).each(function (i, j) {
                if (($("#EIDSSBodyCPH_chkHeatMapHuman").is(":checked") && j[2] == "Hum") ||
                    (($("#EIDSSBodyCPH_chkHeatMapAvian").is(":checked") || $("#EIDSSBodyCPH_chkHeatMapLivestock").is(":checked")) && j[2] == "Vet") ||
                    ($("#EIDSSBodyCPH_chkHeatMapVector").is(":checked") && j[2] == "Vec")) {
                    addressPoints.push(j);
                }
            });
        }

        addressPoints = addressPoints.map(function (p) { return [p[0], p[1]]; });
        heat.setLatLngs(addressPoints);
    },

    showEpiCurve: function () {
        var epiCurveImage = $("[aria-label='Report chart'");

        $(epiCurveImage).attr("width", "115%").removeAttr("style");

        if ($("#lOutbreakEpiCurveError").text() != "") {
            $("#dEpiCurve").html($("#lOutbreakEpiCurveError").Text());
        }
        else {
            $("#dEpiCurve").html($("[aria-label='Report chart'").html());
        }
    }
}