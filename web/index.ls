build-taiwan = (cb) ->
  (data) <- d3.json \twTown1982.topo.json

  topo = topojson.feature data, data.objects["twTown1982.geo"]
  topomesh = topojson.mesh data, data.objects["twTown1982.geo"], (a,b) -> a!=b
  color = d3.scale.category20!

  [w,h] = [400 600]
  m = [20 20 20 20]

  # use mercator project (from latlng to point)
  prj = d3.geo.mercator!center [120.979531, 23.978567] .scale 100000

  # given a dataset and projection func, convert to svg path d parameter
  path = d3.geo.path!projection prj

  svg = d3.select \#content .append \svg
    .attr \width w .attr \height h .attr \viewBox "0 0 800 600" .attr \preserveAspectRatio \xMidYMid

  # render by individual blocks
  svg.selectAll \path.county .data topo.features .enter!append \path
    .attr \class, \county
    .attr \d path
    .style \fill -> color Math.random!
    .style \stroke \none
    .style \opacity 0.9

  # render boundary
  svg.append \path .attr \class \boundary .datum topomesh
    .attr \d path
    .style \fill \none
    .style \stroke "rgba(0,0,0,0.5)"
    .style \stroke-width \1px
  cb svg, topo

build-data = (cb) ->
  d3.json \total.json, -> cb it

convert = (county, town) ->
  if county in <[台北市 台北縣 台中縣 台南縣 高雄縣]> => 
    town = town.substring(0,town.length - 1) + "區"
    if county == \台北縣 => county = \新北市
    county = county.replace \縣, \市
  [county, town]

idx = 93
update-value = (svg, topo, data) ->
  [min,max] = [-1,-1]
  for it in topo.features
    [county,town] = convert it.properties.COUNTYNAME, it.properties.TOWNNAME
    it.properties.value = data.value[idx]1[county][town]
    if min == -1 or min > it.properties.value => min = it.properties.value
    if max == -1 or max < it.properties.value => max = it.properties.value
  color = d3.scale.linear!domain [min,max] .range <[#000 #f00]>
  frange = d3.scale.linear!domain [min,max] .range [254,255]
  svg.selectAll \path.county .style \fill, -> 
    "rgba(#{it.properties.value},0,0,1)"

main = ($scope, $interval) ->
  (data) <- build-data
  (svg, topo) <- build-taiwan

  $interval ->
    $scope.idx = idx
    update-value svg, topo, data
    idx := idx + 1
    if idx > 101 => idx := 93
  , 100
