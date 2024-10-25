window.GetLatLongForLeaflet = (photonUrl,defaultUrl, lat, lan, jsInstance) => {
    var latLongData = null
    $.ajax({
        url: photonUrl,
        type: 'GET',
        dataType: 'json',
        success: function (data2) {
            if (data2.features[0] != undefined) {
                defaultLat = data2.features[0].geometry.coordinates[1];
                defaultLong = data2.features[0].geometry.coordinates[0];
                let latLongData = {
                    "lat": defaultLat,
                    "lon": defaultLong
                }
                if (lat != null && lat != 0  ) {
                    latLongData.lat = lat;

                }
                if (lan != null && lat != 0 ) {
                    latLongData.lon = lan;
                }

                jsInstance.invokeMethodAsync("SetMessage",
                    JSON.stringify(latLongData))
                    .then((result) => {
                        console.log(result);
                    });
            }
            else {

                $.ajax({
                    url: defaultUrl,
                    type: 'GET',
                    dataType: 'json',
                    success: function (data3) {
                        if (data3.features[0] != undefined) {
                            defaultLat = data3.features[0].geometry.coordinates[1];
                            defaultLong = data3.features[0].geometry.coordinates[0];
                            let latLongData1 = {
                                "lat": defaultLat,
                                "lon": defaultLong
                            }

                            if (lat != null && lat != 0 ) {
                                latLongData1.lat = lat;

                            }

                            if (lan != null && lan != 0) {
                                latLongData1.lon = lan;
                            }


                            jsInstance.invokeMethodAsync("SetMessage",
                                JSON.stringify(latLongData1))
                                .then((result1) => {
                                    console.log(result1);
                                });
                        }
                       
                    },
                    headers: {
                        //'Access-Control-Allow-Origin': '*',
                        'Access-Control-Allow-Credentials': true,
                    },
                    error: function (request, error) {
                        alert("Request: " + JSON.stringify(request) + '.' + ' Error: ' + JSON.stringify(error));
                    }
                });



            }
        },
        headers: {
            //'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': true,
        },
        error: function (request, error) {
            alert("Request: " + JSON.stringify(request) + '.' + ' Error: ' + JSON.stringify(error));
        }
    });
    return true;
};
