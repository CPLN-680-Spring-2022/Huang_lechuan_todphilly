# Huang_lechuan_todphilly

<h2><b>MUSA Capstone/CPLN680</b></h2>
<p>by Lechuan Huang</p>

<h2><b>Project:</b></h2>
<p>Develop a method to analyze the existence or potential of TOD in Philadelphia Area.</p>

<h3><b>Background</b></h3>
<p>Philadelphia has its own subway and regional rail systems built over a century ago. However, according to <a href="https://urbanspatial.github.io/PublicPolicyAnalytics/TOD.html">an analysis from MUSA509</a>, only certain parts of the city served by rail transit had a positive impact brought by TOD. Other parts of the city served by subways, like West and North Philly remains unchanged compared to non-TOD communities.</p>

<p>
<a href="https://www.dvrpc.org/webmaps/TOD/">DVRPC did produce a map showing the TOD indexes for all major rail transit stations</a> in the Philadelphia MSA. Factors includes: Transit Service Quality: in TCI Score, Job Access: number of jobs accessible within 30-minute transit ride, Travel Time to Philly: transit time to auto travel time ratio, Population density in half-mile radius, Car Ownership, Non-Car Commuters, and Walk Score.
</p>
<p>
However, it does not include the factors like safety, existing demography that will affect the feasibility of transition and may cause gentrification.
</p>

![arch.diagram](https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/raw_data/DVRPC_Rail_stations.png)
![arch.diagram](https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/cleaned_data/vacant_lots+todbuffer.png)

<h3><b>Scopes and Goals</b></h3>
<p>Thus, in this project I decide to produce a memo/report for local government to identify possible TOD locations and their feasibility to be redeveloped and renewed based on more comprehensive factors including possibility of gentrification.</p>

<p>
I may narrow my scope to one specific area in Greater Philadelphia (TBD): places like KOP, Conshohocken in Montgomery County, or Camden, NJ are close to central PHL with decent transit access).
</p>

![arch.diagram](https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/cleaned_data/TODtracs.png)

<h2><b>Folder Organization</b></h2>
<p>

<li>Folder <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/raw_data"><code>/raw_data</code></a>: with raw data.</li>
    <ul>
      <li>Tidycensus map (png) and shapefile of the DVRPC area</li>
      <li><a href="https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/greater-philadelphia-2015-land-use/explore?location=39.977361%2C-75.184975%2C10.68">Greater PHL land use 2015</a> from DVRPC (shp and dbf are too large to be uploaded, but I saved them locally). Other Land Use/Parcel data may be used (not downloaded):</li>
      <li><a href="https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/greater-philadelphia-passenger-rail-stations/explore?location=40.082286%2C-74.972245%2C10.63">Greater PHL Rail stations</a> from DVRPC</li>
      <li>Shapefile of <a href="https://www.dvrpc.org/webmaps/TOD/#map">DVRPC's existing TOD index</a>: obtained by email</li>
      <li>Other data may be used (not used/downloaded yet):</li>
        <ul>
            <li><a href="https://www.opendataphilly.org/dataset/land-use">OpenDataPhilly PHL Land Use</a>: API available</li>
            <li><a href="https://data-montcopa.opendata.arcgis.com/datasets/montgomery-county-parcels-1">Montgomery County Land Use</a>: API not available</li>
            <li><a href="https://www.opendataphilly.org/dataset/walk-score-phila-only">PHL Walk/Transit Score</a>: Free API available</li>
            <li><a href="https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/dvrpc-long-range-plan-2045-land-use-vision/explore?location=40.056487%2C-75.245250%2C9.88">DVRPC 2045 Land Use Vision</a>: API not available</li>
        </ul>      
    </ul>
<li>Folder with <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/cleaned_data"><code>/cleaned_data</code></a>: future R coding will be based on files here</li>
    <ul>
      <li>Tidycensus tract map with certain variables</li>
      <li>Transit stations with type and symbological marks</li>
      <li>Parcel data (converted to point data to save energy) within TOD buffers</li>
      <li>Exploratory analysis results (csv and png)</li>
    </ul>
<li>Folder <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/scripts"><code>/scripts</code></a>: with initial code to explore the data.</li>
    <ul>
      <li>R script to clean and explore the data.</li>
    </ul>
<li><a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/Captsone%20Presentation.pdf"><code>/Captsone Presentation.pdf</code></a>: Presentation slides for the Feb 10 Class.</li>
<li><a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/README.md"><code>/README.md</code></a> file describing the project and folder organization. (THIS FILE)</li>

</p>
