// required variables DO NOT REMOVE
var props, header, content, titleName, headerClass;
var map;
//declare boundary of region
var oLat = 39.97, oLng = -75.16, zLevel = 10;  

var stationSearch = [];

$(document).ready(function() {
//hack to resolve layerOrder add after layers added
  $("#disModal").modal("show");
});

function highlightRow(e){
    $("tr").css('background-color', 'white');
    $(this).css('background-color','rgba(0, 255, 255, 0.6)');
}
  

$('#mapdata-btn').click(function (e) {
  e.preventDefault()
  $('.cat-desc').hide();
  $('.btn-group a[href="#mapdata-main"]').tab('show') // Select tab by name
});

$('#mapchart-btn').click(function (e) {
  e.preventDefault()
  $('.cat-desc').show();
  $('.btn-group a[href="#mapchart-main"]').tab('show') // Select tab by name
});

$('#mapdata2-btn').click(function (e) {
  e.preventDefault()
  $('.btn-group a[href="#mapdata2-main"]').tab('show') // Select tab by name
});

$('#mapchart2-btn').click(function (e) {
  e.preventDefault()
  $('.btn-group a[href="#mapchart2-main"]').tab('show') // Select tab by name
});

$('#chart2-btn').click(function (e) {
  e.preventDefault()
  $('.btn-group a[href="#chart-station"]').tab('show') // Select tab by name
});

$('#chart1-btn').click(function (e) {
  e.preventDefault()
  $('.btn-group a[href="#chart-transit"]').tab('show') // Select tab by name
});

$('#radio1').click(function (e) {
  $('.btn-group a[href="#chart-transit"]').tab('show') // Select tab by name
});

$('#radio2').click(function (e) {
  $('.btn-group a[href="#chart-station"]').tab('show') // Select tab by name
});

$('.nav-tabs li a').click( function(e) {
    history.pushState( null, null, $(this).attr('href') );
});

function legendraw(element) {
   //   e.preventDefault()
  // event.preventDefault()
  $("#EXTODModal").modal("show");
} 

function legendraw2(element) {
   //   e.preventDefault()
  // event.preventDefault()
  $("#FTODPModal").modal("show");
} 

function legendraw3(element) {
   //   e.preventDefault()
  // event.preventDefault()
  $("#SATModal").modal("show");
} 

function legendraw4(element) {
   //   e.preventDefault()
  // event.preventDefault()
  $("#PACModal").modal("show");
} 

function legendraw5(element) {
   //   e.preventDefault()
  // event.preventDefault()
  $("#rateModal").modal("show");
} 

//$("#legend-btn").click(function() {
//    $("#legendModal").modal("show");
//    $(".navbar-collapse.in").collapse("hide");
//    return false;
//});
        
//declare basemaps
 $.getJSON('data/tod.js', function(data) {
        stations.addData(data);
        map.addLayer(stationsLayer);
    });

    styleOptions = {
   //   radius: 7,
      weight: 0,
      opacity: 1,
      fillOpacity: 0.8
    };
    var stationsLayer = L.geoJson(null);
    var stations = L.geoJson(null, {
        pointToLayer: function(feature, latlng) {
            return L.circleMarker(latlng, styleOptions);
        },
         style: function(feature){
         switch (feature.properties.QUAD) {
         case 'aboveabove' : return {fillColor: "#124A62",radius:10};
         case 'abovebelow' : return {fillColor: "#1C7AA0",radius:7};
         case 'belowabove' : return {fillColor: "#1C7AA0",radius:7};  
         case 'belowbelow' : return {fillColor: "#28AAE1",radius:5};  
        }
    },
        onEachFeature: function(feature, layer) {
            if (feature.properties) {
                layer.bindLabel('<u>'+feature.properties.Station_Na + '</u><br>Existing TOD Orientation:&nbsp'+ numeral(feature.properties.ExistingOr).format('0.00')+ '<br>Future TOD Potential:&nbsp'+ numeral(feature.properties.FuturePote).format('0.00'), {
                    className: 'leaflet-label'
                });
                layer.on({click: identify});
                layer.on({click: populatebarchart});
        }      
    }
    });

 // Other Stations 
    styleOptions2 = {
    //  color: "#587272",
    color:"#fc8d59",
      radius: 3,
      weight: 0,
      opacity: 1,
      fillOpacity: .8,
      clickable: true
    };
 
    var other = L.geoJson(null, {
        pointToLayer: function(feature, latlng) {
            return L.circleMarker(latlng, styleOptions2);
        },
        onEachFeature: function(feature, layer) {
            if (feature.properties) {
                layer.bindLabel(feature.properties.STATION, {
                    className: 'leaflet-label2'
                });
             //   layer.on({click: identify});
             //   layer.on({click: populatebarchart});
        } 
      }
    });
    $.getJSON('data/other.js', function(data) {
        other.addData(data);
    });


var rail = L.geoJson(null, {
style: {
    color: '#fdbb84',
    weight: 5,
    fill: false,
    clickable: false
}
});
$.getJSON("Passenger_Rail.geojson", function(data) {
rail.addData(data);
});

var DVRPC = L.geoJson(null, {
    style: {
        color: 'rgb(140,140,140)',
        weight: 3,
        fill: false,
        clickable: false
    }
});
$.getJSON("data/cnty.js", function(data) {
    DVRPC.addData(data);
});        

     // Basemap Layers
     //   var mapquestOSM =  L.tileLayer.provider('MapBox.crvanpollard.heonp4ob');
        var CartoDB_Positron = L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
        maxZoom: 18, attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, &copy; <a href="https://carto.com/attribution">CARTO</a>'
      });
    

var Mapbox_Imagery = L.tileLayer(
    'https://api.mapbox.com/styles/v1/crvanpollard/cimpi6q3l00geahm71yhzxjek/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiY3J2YW5wb2xsYXJkIiwiYSI6Ii00ZklVS28ifQ.Ht4KwAM3ZUjo1dT2Erskgg', {
    tileSize: 512,
    zoomOffset: -1,
    attribution: 'Â© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> Â© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    });

//create map instance
var map = L.map("mapDIV", {
    minZoom: zLevel,
    zoomControl: false,
    layers: [CartoDB_Positron,other, rail, DVRPC,stations]
}).setView([oLat, oLng],zLevel);


//add Layer Control to map
var baseLayers = {
    "Satellite": Mapbox_Imagery, 
    "Street Map": CartoDB_Positron
  //  "Street Map (Dark)": mapbox
};
 L.control.layers(baseLayers).addTo(map);

    L.Control.MapLegend = L.Control.extend({
        options: {
            position: 'bottomleft',
        },
        onAdd: function (map) {
            //TODO: Probably should throw all this data in a class and just loop through it all
            var legendDiv = L.DomUtil.create('div', 'map-legend legend-control leaflet-bar');

            legendDiv.innerHTML += '<div id="legend-icon" title="Toggle Legend"><i class="glyphicon glyphicon-minus"></i><span class="legend-label" style="display:none;">&nbsp;&nbsp;Legend</span></div>';
        
            var legend_top = L.DomUtil.create('div', 'map-legend-items legend-top', legendDiv),
                legend_body = L.DomUtil.create('div', 'map-legend-items legend-body', legendDiv),
                legend_bottom = L.DomUtil.create('div', 'map-legend-items legend-bottom', legendDiv);
     
            legend_body.innerHTML += '<div id="legend-content" class="row">'+
            '<div class="col-xs-1 col-sm-1">'+
            '<div class="row" id="legend-row"><i class="fa fa-circle ct-existing fa-3"></i></div>'+
            '<div class="row" id="legend-row"><i class="fa fa-circle ct-inprogress"></i></div>'+
            '<div class="row"id="legend-row"><i class="fa fa-circle ct-planned"></i></div>'+
            '<div class="row"id="legend-row"><i class="fa fa-circle other"></i></div>'+
            '</div>'+
            '<div class="col-xs-11 col-sm-11">'+
            '<div class="row" id="legend-row"><span class="nav-text"> Strong Existing Orientation <i><B>and</B></i> Strong Future Potential</span></div>'+
            '<div class="row" id="legend-row"><span class="nav-text">Strong Existing Orientation <i><b>or</b></i> Future Potential</span></div>'+
            '<div class="row" id="legend-row"><span class="nav-text">Moderate Existing Orientation and Moderate Future Potential</span></div>'+
            '<div class="row" id="legend-row"><span class="nav-text">Other passenger rail stations</span></div></div>';
          
           legend_top.innerHTML += '<p><b>Rating TOD Opportunities</b><span id="legend-definition" class="nav-item" data-modal="#rateModal" onclick="legendraw5()"><i class="glyphicon glyphicon-info-sign"></i>&nbsp;&nbsp;data definitions</span></p>'
            
           legendDiv.setAttribute('data-status', 'open');

            return legendDiv;
        }
    });

var mapLegend = new L.Control.MapLegend();
map.addControl(mapLegend);

    function identify(e) {
        var layer = e.target;
        var props = layer.feature.properties;

        if (props.OPERATOR==='PATCO'){ var Information = "<div>"+(props.MAP_NAME)+" - "+(props.LINE)+"</div>"  ;}
        else { var Information =  "<div>"+(props.MAP_NAME)+" - "+(props.LINE)+" ("+(props.OPERATOR)+")</div>";}

        var content = Information
                     //   "<div>"+(props.Station_Na)+" - "+(props.LINE)+" ("+(props.OPERATOR)+")</div>" 


        var stationinfo = "<div style='margin-left: 25px;'> Location: <b>"+(props.LOC)+", "+(props.CNTY)+" County</b></div>"
                         +"<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw3()'></i> Station Area Type: <b>"+(props.Type_1)+"</b></div>"
                         +"<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw4()'></i> Planning Area Context: <b>"+(props.LUContext)+"</b></div>"

        var existingOVinfo = "<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw()'></i><b>Existing TOD Orientation:</b>&nbsp;&nbsp; <h2 style='display: inline'>"+numeral(props.ExistingOr).format('0.00')+" / 4</h2></div>"
          
        var words = (props.Time_Data).split(' ')[0];  
            console.log(words);
        if ( words === 'Philly:'){ var TRAVEL = "<div><b>Travel Time to NYC:</b>&nbsp;"+(props.Time_Data).split(' ')[3]+"<i> transit to auto travel time ratio</i></div>"  ;}
        else { var TRAVEL =  "<div><b>Travel Time to Philly:</b>&nbsp;" + numeral(props.Time_Data).format('0.00') +" <i> transit to auto travel time ratio</i></div>";}

        var existinginfo ="<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw()'></i><b <b style='font-size: 14px;'>Existing TOD Orientation Category</b></div>"
                         +"<br><div><b>Transit Service Quality:</b>&nbsp; "+(props.TCI_Data)+" <i>TCI Score</i></div>"
                         +"<div><b>Job Access:</b>&nbsp;" + numeral(props.Job_Data).format('0,0') +" <i> jobs accessible within 30 minute transit ride</i></div>"
                       //  +"<div><b>Travel Time:</b>&nbsp;" + numeral(props.Time_Data).format('0.00') +" <i>transit to auto travel time ratio</i></div>"
                         + TRAVEL
                         +"<div><b>Intensity:</b>&nbsp; "+ numeral(props.Int_Data).format('0,0')+" <i> residents and workers within a half-mile of the station</i></div>"
                         +"<div><b>Car Ownership:</b>&nbsp; "+(props.Car_Data)+"% <i>housing units with zero or one vehicle</i></div>"
                         +"<div><b>Non-Car Commuters:</b>&nbsp; "+(props.Com_Data)+"%<i> residents who commute to work by public transportation, bicycle, or walking</i></div>"
                         +"<div><b>Walk ScoreÂ®:</b>&nbsp; "+(props.Walk_data)+"</div>"
 
        var futureOVinfo = "<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw2()'></i><b>Future TOD Potential: </b> &nbsp;&nbsp; <h2 style='display: inline'>"+(props.FuturePote)+" / 4</h2></div>"

        var futureinfo ="<div><i class='glyphicon glyphicon-info-sign' id='info-icon' onclick='legendraw2()'></i><b style='font-size: 14px;'>Future TOD Potential Categories</b></div>"
                         +"<br><div><b>Development Activity:</b>&nbsp; "+(props.Dev_Data)+" <i>multifamily units recently built, under construction, or proposed</i></div>"
                         +"<div><b>Commercial Market:</b>&nbsp;$"+(props.CommRent_D)+" <i>5-year average rent per square foot for office space</i></div>"
                         +"<div><b>Residential Market:</b>&nbsp;$"+(props.ResRent_Da)+" <i>average asking rent per square foot for multifamily units</i></div>"
                         +"<div><b>Available Land:</b>&nbsp; <i>qualitative assessment</i></div>"
                         +"<div><b>Planning Context:</b>&nbsp; <i>qualitative assessment</i></div>"
                 

        document.getElementById('mapcard').innerHTML = content;
        document.getElementById('stationinfo_all').innerHTML = stationinfo;  
        document.getElementById('existingOV-data').innerHTML = existingOVinfo;  
        document.getElementById('existing-data').innerHTML = existinginfo;  
        document.getElementById('futureOV-data').innerHTML = futureOVinfo;  
        document.getElementById('future-data').innerHTML = futureinfo;  

        $('#cardbikepanel').show();
        $('#cardpedpanel').show();
        $('#mapcard').show();
        $('#stationinfo_all').show();
        $('#MapButtons').show();
        $('#MapButtons-title').show();
        $('#cardclick').hide();
        
        highlightRow.call(document.getElementById(L.stamp(layer)))
         
    //    $('#myTab a[href="#station_stats"]').tab('show');        
    //    document.getElementById('table_data').innerHTML = content;
    };



   function FTODPdraw(value) {
        $('#FTODPModal').one('shown.bs.modal', function() {
        $('#FTODPTabs a[data-target="#' + value + '"]').tab('show'); }).modal('show');

    }
    
  function EXTODdraw(value) {
        $('#EXTODModal').one('shown.bs.modal', function() {
        $('#EXTODTabs a[data-target="#' + value + '"]').tab('show'); }).modal('show');
        $('#FTODPModal').modal('close');
    } 

    function populatebarchart(e) {
        var layer = e.target;
        var props = layer.feature.properties,

        ExistingTOD = [props.TCI_Score,props.Job_Score,props.Time_Score,props.Int_Score,props.Car_Score,props.Com_Score,props.Walk_Score];
        updatebarchart(ExistingTOD);

        FutureTOD = [props.Dev_Score,props.CommRent_S,props.ResRent_Sc,props.Land_Score,props.Planning_S];
        updatebarchart2(FutureTOD);
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
            categories: [ 'Transit Service Quality','Job Access','Travel Time','Intensity','Car Ownership','Non-Car Commuters','Walk ScoreÂ®'],
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

    function updatebarchart2(Values) {
        var options = {
            chart: {
                renderTo: 'future',
                type:'bar',
                plotBackgroundColor: null,
                plotBorderWidth: 0,//null,
                plotShadow: false,
                height:200,
                spacingleft: 10,
                spacingRight:45,
                backgroundColor: '#EFEFEF'
            },
            colors: 
                ['#77c9ed']
            ,
            credits: {
                enabled: false
            },
            title: {
              text:null,
                x: -20 //center
            },
            xAxis: {
                categories: [ 'Development Activity','Commercial Market','Residential Market','Available Land','Planning Context'],
                tickColor: 'transparent',
                lineColor: 'transparent',
                labels: {useHTML: true}
            },
            plotOptions: {
                column: {
                    colorByPoint: true,
                    colors: ['red','red','grey','blue','green'],
                    stacking: 'normal',
                    dataLabels: {
                        enabled: false,
                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
                        style: {
                            textShadow: '0 0 3px black'
                        }
                    }
                }
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
   /*         credits: {
            position: {
                align: 'left',
                x: 5,
                y: -5 // position of credits
            },
            text: 'click category name for description',
            href: null

     },
   */       tooltip: {
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
         FTODPdraw(this.textContent.split(' ')[0]);
    });
     //    console.log(bikeindata);
    }

 // Typeahead search functionality
$(document).one("ajaxStop", function() {
    $("#loading").hide();
      stations.bringToFront();
    });
