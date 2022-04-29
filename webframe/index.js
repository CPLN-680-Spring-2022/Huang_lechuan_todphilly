// Map and Layer
const scoremap = L.map('map').setView([40.0388, -75.1447], 11);
const stationLayer = L.layerGroup().addTo(scoremap);

L.tileLayer('https://api.mapbox.com/styles/v1/hlechuan/ckygb56s41bo614o8h16eyz4m/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGxlY2h1YW4iLCJhIjoiY2t5Z2IyMTl5MHhoYjJ3bWw1c2xvaDEwYyJ9.MHPJtyIHAt7moC3UYhYIjg', {
  attribution: '©<a href="https://www.mapbox.com/feedback/">Mapbox</a>©<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  ext: 'png',
}).addTo(scoremap);

// Stations
styleOptionsstation = {
  fillColor: "#7bcbe8",
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
  var layer = L.geoJSON(datascore, {
    pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, styleOptionsstation);
    }
  }).addTo(stationLayer);
  layer.eachLayer(marker => {
    marker.on({click: identify});
    marker.on({click: populatebarchart});
  })
  
});


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
  var layerfilter = L.geoJSON(ModeFilter, {
    pointToLayer: function(feature, latlng) {
        return L.circleMarker(latlng, styleOptionsstation);
    }
  }).addTo(stationLayer);
  layerfilter.eachLayer(marker => {
    marker.on({click: identify});
    marker.on({click: populatebarchart});
  })
};

//Barchart

function identify(e) {
  var layer = e.target;
  var props = layer.feature.properties;
  var Information =  "<divstyle='margin-left: 10px;'><b>"+(props.station)+"</b> - "+(props.line)+" ("+(props.operator)+")</div>";
  var stationinfo = "<div style='margin-left: 25px;'> Grade: <b>"+(props.grade)+"</b></div>"
                     +"<div style='margin-left: 25px;'> Location: <b>"+(props.mun_name)+"</b></div>"
                     +"<div style='margin-left: 25px;'>"+(props.co_name)+", "+(props.state_name)+"</b></div>";
  var Scoreinfo =  "<div><b>TODPhilly Score:</b>&nbsp;&nbsp; <h2 style='display: inline; color: #24abe2;'>"+(props.sc_aph)+" / 10</h2></div>";
  var MCDAinfo ="<div style='margin-left: 15px;margin-top: 10px;'><b style='font-size: 18px'><u>Score Breakdown:</u></b></div>"
                +"<div style='margin-left: 15px;'><b>Accessibility Score:</b>&nbsp; "+(props.ac_score)+" out of 10</div>" 
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Ideal maximum ridership of the station</i></div>"
                +"<div style='margin-left: 15px;'><b>Job Score:</b>&nbsp;" +(props.job_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'> Job Density </i></div>"
                +"<div style='margin-left: 15px;'><b>Employment Gap Score:</b>&nbsp;" +(props.em_surp_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Gap between amount of jobs and residents </i></div>"
                +"<div style='margin-left: 15px;'><b>Poverty Score:</b>&nbsp;" +(props.pvt_qn)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Quantiled Poverty Rate </i></div>"
                +"<div style='margin-left: 15px;'><b>Median Income Score:</b>&nbsp;" +(props.MdInm_qn)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Quantiled Median Income </i></div>"
                +"<div style='margin-left: 15px;'><b>Non-Gentrification Score:</b>&nbsp;" +(props.not_gen)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Likelihood of not being gentrified </i></div>"
                +"<div style='margin-left: 15px;'><b>Location Score:</b>&nbsp;" +(props.loc_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Level of Municipality the station is located </i></div>"
                +"<div style='margin-left: 15px;'><b>Terrain Score:</b>&nbsp;" +(props.slo_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>How un-steep it is around the station </i></div>"
                +"<div style='margin-left: 15px;'><b>Under-utilized Land Score:</b>&nbsp;" +(props.duti_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>Size of under-utilized land around the station </i></div>"
                +"<div style='margin-left: 15px;'><b>Attractive Score:</b>&nbsp;" +(props.attr_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>How attractive area around the station is. </i></div>"
                +"<div style='margin-left: 15px;'><b>Unattractive Score:</b>&nbsp;" +(props.unattr_sc)+" out of 10</div>"
                +"<div style='margin-left: 15px;'><i style='font-size: 10px;'>How little unattractive area around the station is. </i></div>";
 
        document.getElementById('Information').innerHTML = Information;
        document.getElementById('stationinfo_all').innerHTML = stationinfo;  
        document.getElementById('Scoreinfo').innerHTML = Scoreinfo;  
        document.getElementById('MCDAinfo').innerHTML = MCDAinfo;   

        $('#cardbikepanel').show();
        $('#cardpedpanel').show();
        $('#Information').show();
        $('#scorebox').show();
        $('#cardclick').hide();
      
         
};

function populatebarchart(e) {
    var layer = e.target;
    var props = layer.feature.properties,

    MCDAchart = [props.ac_score,props.job_sc,props.em_surp_sc,props.pvt_qn,props.MdInm_qn,props.not_gen,props.loc_sc,
    props.slo_sc,props.duti_sc,props.attr_sc,props.unattr_sc];
    updatebarchart(MCDAchart);

}

function updatebarchart(Values) {
var options = {
    chart: {
        renderTo: 'existing',
        type:'bar',
        plotBackgroundColor: null,
        plotBorderWidth: 0,//null,
        plotShadow: false,
        height:200,
        spacingLeft: 25,
        spacingRight: 60,
        backgroundColor: '#EFEFEF'
    },
     colors: ['#77c9ed']
   ,
    credits: {
        enabled: false
    },
    title: {
      //  text: 'Bicycle Volume by Month',
      text:null,
        x: -20 //center
    },
    xAxis: {
        categories: [ 'Accessibility Score','Job Score','Employment Gap Score','Poverty Score','Median Income Score','Non-Gentrification Score','Location Score','Terrain Score','Under-utilized Land','Attractive Score','Unattractive Score'],
        tickColor: 'transparent',
        lineColor: 'transparent',
        labels: {useHTML: true}
    },
    yAxis: {
        min: 0,
        max:4,
        tickInterval: 1,
        height: 150,
        gridLineColor: "#046f9e",
        title: {
            text: ''
        }
    },
    legend: {
        enabled: false
    },
/*      credits: {
        position: {
            align: 'left',
            x: 5,
            y: -5 // position of credits
        },
        text: 'click category name for description',
        href: null

    },
*/      tooltip: {
        enabled: false
    },

    series: [{
           name:'Total',
           id: 'Values',
           data: []
        }]
};

var Labels = [],
counData = [];
for (var i = 0; i < Values.length; i++){
counData.push({
name: Labels[i],
y: Values[i]})
}
options.series[0].data = counData;
chart = new Highcharts.Chart(options)

$('.highcharts-xaxis-labels text, .highcharts-xaxis-labels span').click(function () {
   // console.log(this.textContent.split(' ')[0]);
     EXTODdraw(this.textContent.split(' ')[0]);
});
//    console.log(bikeindata);
}

// Typeahead search functionality
// $(document).one("ajaxStop", function() {
// $("#loading").hide();
//   stations.bringToFront();
// });
