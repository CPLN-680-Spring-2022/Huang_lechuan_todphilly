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
However, all of the factors it used are not weighted; also, it does not include social factors about the neighborhoods stations are located.
</p>

<h3><b>Scopes and Goals</b></h3>
<p>Thus, in this project I decide to produce a dashboard to identify possible TOD locations and their feasibility to be redeveloped and renewed based on more comprehensive factors.</p>

![arch.diagram](https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/Final_TOD.png)

<h2><b>Folder Organization</b></h2>
<p>

<li>Folder <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/raw_data"><code>/raw_data</code></a>: with raw data.</li>
    <ul>
      <li>Tidycensus map (png) and shapefile of the DVRPC area</li>
      <li><a href="https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/greater-philadelphia-2015-land-use/explore?location=39.977361%2C-75.184975%2C10.68">Greater PHL land use 2015</a> from DVRPC (shp and dbf are too large to be uploaded, but I saved them locally). Other Land Use/Parcel data may be used (not downloaded):</li>
      <li><a href="https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/greater-philadelphia-passenger-rail-stations/explore?location=40.082286%2C-74.972245%2C10.63">Greater PHL Rail stations</a> from DVRPC</li>
      <li>Shapefile of <a href="https://www.dvrpc.org/webmaps/TOD/#map">DVRPC's existing TOD index</a>: obtained by email</li>
    </ul>
<li>Folder with <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/cleaned_data"><code>/cleaned_data</code></a>: future R coding will be based on files here</li>
    <ul>
      <li><a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/cleaned_data/final_mat"><code>/final_mat:</code></a> Final station data with TOD index data (shp and geojson)</li>
      <li><a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/cleaned_data/Parcel_analysis"><code>/Parcel_analysis:</code></a> Exploratory Analysis of parcels within the TOD buffers</li>
      <li>Exploratory analysis results (csv and png)</li>
    </ul>
<li>Folder <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/Scripts"><code>/Scripts</code></a>: with R codes to explore the data.</li>
<li>Folder <a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/tree/main/webframe"><code>/webframe</code></a>: files required to create dashboard.</li>
<li><a href="https://github.com/CPLN-680-Spring-2022/Huang_lechuan_todphilly/blob/main/Metadata.xlsx"><code>/Metadata.xlsx</code></a>: Metadata for the MCDA Model.</li>

</p>
