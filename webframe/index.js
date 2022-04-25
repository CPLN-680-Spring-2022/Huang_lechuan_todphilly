/*function initMap() {
  const map = new google.maps.Map(document.getElementById("map"), {
    zoom: 13,
    center: { lat: 39.9526, lng: -75.1652 },
  });
  const transitLayer = new google.maps.TransitLayer();

  transitLayer.setMap(map);
}

window.initMap = initMap;
*/
const map = L.map('map').setView([39.9526, -75.1652], 13);

L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.{ext}', {
  attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  ext: 'png',
}).addTo(map);

// let p1;
// let showpoints;
// fetch('station_final_0421_2.geojson')
//   .then(resp => resp.json())
//   .then(data => {
//     showpoints = data;
//     p1 = L.geoJSON(data).
//     bindTooltip(l => l.features.properties.station).
//     addTo(map);
//   });



// Lines
fetch('https://arcgis.dvrpc.org/portal/rest/services/Transportation/PassengerRail/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson')
.then(function (response) {
  return response.json();
})
.then(function (dataline) {
  L.geoJSON(dataline, {
    style: function (feature) {
        return {color: '#fdbb84',
                weight: 5,
                opacity: 0.7};
    }
  }).addTo(map);
});

// Stations
styleOptionsstation = {
  fillColor: "#5a8999",
  radius: 10,
  weight: 0,
  opacity: 1,
  fillOpacity: 1
};

fetch('station_final_score.geojson')
.then(function (response) {
  return response.json();
})
.then(function (datascore) {
  L.geoJSON(datascore/*, { Color TBD
    pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, styleOptionsstation);
    }
  }*/).bindPopup(function (layer) {
    return layer.feature.properties.station + ": " + layer.feature.properties.sc_aph;
  }).addTo(map);
});

// Parcels
styleOptionsparcel = {
  fillColor: "#4a6157",
  radius: 5,
  weight: 0,
  opacity: 1,
  fillOpacity: 0.9
};


fetch('parcel_data.geojson')
.then(function (response) {
  return response.json();
})
.then(function (parcel) {
  L.geoJSON(parcel, {
    pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, styleOptionsparcel);
    }
  }).bindPopup(function (layer) {
    return layer.feature.properties.lu15subn;
  }).addTo(map);
});