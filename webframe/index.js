// Map and Layer
const scoremap = L.map('map').setView([39.9526, -75.1652], 11);
const stationLayer = L.layerGroup().addTo(scoremap);

L.tileLayer('https://api.mapbox.com/styles/v1/hlechuan/ckygb56s41bo614o8h16eyz4m/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGxlY2h1YW4iLCJhIjoiY2t5Z2IyMTl5MHhoYjJ3bWw1c2xvaDEwYyJ9.MHPJtyIHAt7moC3UYhYIjg', {
  attribution: '© <a href="https://www.mapbox.com/feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  ext: 'png',
}).addTo(scoremap);

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
  let MuniFilter;
  if (Muni === '')  {
    MuniFilter = GradeFilter;
  } else {
    if (GradeFilter.length === stations.length) {
      MuniFilter = GradeFilter.features.filter(a => a.properties.mun_type === Muni);
    } else {
      MuniFilter = GradeFilter.filter(a => a.properties.mun_type === Muni);
    }
  }
  let ModeFilter;
  if (Mode === '')  {
    ModeFilter = MuniFilter;
  } else {
    if (MuniFilter.length === stations.length) {
      ModeFilter = MuniFilter.features.filter(a => a.properties.type.replace('_', ' ') === Mode);
    } else {
      ModeFilter = MuniFilter.filter(a => a.properties.type.replace('_', ' ') === Mode);
    }
  }
  L.geoJSON(ModeFilter).bindPopup(function (layer) {
    return layer.feature.properties.station + ": " + layer.feature.properties.sc_aph;
  }).addTo(stationLayer);
};
