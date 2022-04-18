function initMap() {
  const map = new google.maps.Map(document.getElementById("map"), {
    zoom: 13,
    center: { lat: 39.9526, lng: -75.1652 },
  });
  const transitLayer = new google.maps.TransitLayer();

  transitLayer.setMap(map);
}

window.initMap = initMap;

let p1;
let showpoints;
fetch('data/data.geojson')
  .then(resp => resp.json())
  .then(data => {
    showpoints = data;
    p1 = L.geoJSON(data).
    bindTooltip(l => l.feature.properties.Locations).
    addTo(map);
    showCurrentSlide();
  });

  /* Slides */

let currentSlideIndex = 0;

const slideTitleDiv = document.querySelector('.slide-title');
const slideContentDiv = document.querySelector('.slide-content');
const slidePrevButton = document.querySelector('#prev-slide');
const slideNextButton = document.querySelector('#next-slide');
const slideJumpSelect = document.querySelector('#jump-to-slide');

function updateMap(collection) {
  layerGroup.clearLayers();
  const geoJsonLayer = L.geoJSON(collection, { pointToLayer: (p, latlng) => L.marker(latlng) })
    .bindTooltip(l => l.feature.properties.Locations)
    .addTo(layerGroup);

  return geoJsonLayer;
}

function makeEraCollection(era) {
  return {
    type: 'FeatureCollection',
    features: lifeCollection.features.filter(f => f.properties.era === era),
  };
}

function showSlide(slide) {
  slideTitleDiv.innerHTML = `<h3>${slide.properties.Location}</h3>`;
  slideContentDiv.innerHTML = `<p>${slide.properties.date}</p><br><p>${slide.properties.Event}</p>`
  // slideContentDiv.innerHTML = converter.makeHtml(slide.content);

  map.eachLayer(marker => {
    if (marker.feature && marker.feature.properties.Order === slide.properties.Order) {
      // Center the map on the marker
      map.flyTo(marker.getLatLng(), 12 /* <-- Or some zoom level besides 12 */);
  
      // Open the marker popup
      marker
        .bindPopup(`<h3>${slide.properties.Location}</h3><br><img src="data/${slide.properties.File}" width=220>`)
        .openPopup();
    } else {
      marker.closePopup();
    }
  });

  /*const collection = slide.era ? makeEraCollection(slide.era) : lifeCollection;
  const layer = updateMap(collection);

  function handleFlyEnd() {
    if (slide.showpopups) {
      layer.eachLayer(l => {
        l.bindTooltip(l.feature.properties.label, { permanent: true });
        l.openTooltip();
      });
    }
    map.removeEventListener('moveend', handleFlyEnd);
  }

  map.addEventListener('moveend', handleFlyEnd);
  if (slide.bounds) {
    map.flyToBounds(slide.bounds);
  } else if (slide.era) {
    map.flyToBounds(layer.getBounds());
  }*/
}

function showCurrentSlide() {
  const slide = showpoints.features[currentSlideIndex];
  showSlide(slide);
}

function goNextSlide() {
  currentSlideIndex++;

  if (currentSlideIndex === 23) {
    currentSlideIndex = 0;
  }

  showCurrentSlide();
}

function goPrevSlide() {
  currentSlideIndex--;

  if (currentSlideIndex < 0) {
    currentSlideIndex = slides.length - 1;
  }

  showCurrentSlide();
}

function jumpToSlide() {
  currentSlideIndex = parseInt(slideJumpSelect.value, 10);
  showCurrentSlide();
}

function initSlideSelect() {
  slideJumpSelect.innerHTML = '';
  for (const [index, slide] of slides.entries()) {
    const option = document.createElement('option');
    option.value = index;
    option.innerHTML = slide.title;
    slideJumpSelect.appendChild(option);
  }
}

function loadLifeData() {
  fetch('data/data.geojson')
    .then(resp => resp.json())
    .then(data => {
      lifeCollection = data;
      showCurrentSlide();
    });
}

slidePrevButton.addEventListener('click', goPrevSlide);
slideNextButton.addEventListener('click', goNextSlide);
slideJumpSelect.addEventListener('click', jumpToSlide);

/*initSlideSelect();
showCurrentSlide();
loadLifeData();*/