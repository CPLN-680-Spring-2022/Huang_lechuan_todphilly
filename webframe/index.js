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
const scoremap = L.map('map').setView([39.9526, -75.1652], 13);
const stationLayer = L.layerGroup().addTo(scoremap);

L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.{ext}', {
  attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  ext: 'png',
}).addTo(scoremap);

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
  }).addTo(scoremap);
});

// Stations
styleOptionsstation = {
  fillColor: "#5a8999",
  radius: 10,
  weight: 0,
  opacity: 1,
  fillOpacity: 1
};

var stations = { features: [] };
fetch('stations_final_0426.geojson')
.then(function (response) {
  return response.json();
})
.then(function (datascore) {
  stations = datascore;
  L.geoJSON(datascore/*, { Color TBD
    pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, styleOptionsstation);
    }
  }*/).bindPopup(function (layer) {
    return layer.feature.properties.station + ": " + layer.feature.properties.sc_aph;
  }).addTo(stationLayer);
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
  }).addTo(scoremap);
});


// Select
// const ModeSelect = document.querySelector('#service-select');

let Grade = '';
let Muni = '';
let Mode = '';
function ModeSelect() {
  stationLayer.clearLayers();
  Grade = document.getElementById('score-select').value;
  Muni = document.getElementById('location-select').value;
  Mode = document.getElementById('service-select').value;
  
  let GradeFilter;
  if (Grade === '')  {
    GradeFilter = stations;
  } else {
    GradeFilter = stations.features.filter(a => a.properties.grade === Grade);
  }
  
  // let MuniFilter;
  // if (Muni === '')  {
  //   MuniFilter = stations;
  // } else {
  //   MuniFilter = stations.features.filter(a => a.properties.mun_type === Muni);
  // }
  // let ModeFilter;
  // if (Mode === '')  {
  //   ModeFilter = MuniFilter;
  // } else {
  //   if (MuniFilter.length === stations.length) {
  //     ModeFilter = MuniFilter.features.filter(a => a.properties.type.replace('_', ' ') === Mode);
  //   } else {
  //     ModeFilter = MuniFilter.filter(a => a.properties.type.replace('_', ' ') === Mode);
  //   }
  // }
  L.geoJSON(GradeFilter).bindPopup(function (layer) {
    return layer.feature.properties.station + ": " + layer.feature.properties.sc_aph;
  }).addTo(stationLayer);
};

//  ModeSelect.addEventListener('change', handleSelectChange);

// let updateStationMarkers = (stationsToShow) => {
//   stationLayer.clearLayers();
//   stationsToShow.forEach((station) => {
//     const lat = parseFloat(station['geometry.coordinates'].split(',')[0]);
//     const lng = parseFloat(station['geometry.coordinates'].split(',')[1]);
//     const stationName = station['properties.station'];
//     const marker = L.marker([lat, lng]);
//     marker.bindTooltip(stationName);
//     stationLayer.addLayer(marker);
//   });
// };

// let initializeScoreChoices = () => {
//   let score = stations['features'].map(a => a.properties.sc_aph);
//   if (score > 7) {
//     score.forEach((z) => ScoreSelect.appendChild(htmlToElement(`<option>Larger than 7 (Ideal)</option>`)));
//   }
//   if (score > 4.99 && score < 7.01) {
//     score.forEach((z) => ScoreSelect.appendChild(htmlToElement(`<option>Between 5 and 7 (Mediocre)</option>`)));
//   }
//   if (score < 5) {
//     score.forEach((z) => ScoreSelect.appendChild(htmlToElement(`<option>Lower than 5 (Not ideal)</option>`)));
//   }
//   return score;
// };

// let filteredStations = () => {
//   let stationFilter = [];
//   if (ScoreSelect.value === 'All') {
//     stationFilter = stations.features;
//   }
//   return stationFilter;
// };


// // The code below will be run when this script first loads. Think of it as the
// // initialization step for the web page.
// initializeScoreChoices();
// updateStationMarkers(stations);