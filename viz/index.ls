main = ($scope, $timeout, $interval) ->
  $scope.chosen = "點地圖看值"
  (popu) <- d3.json \population-ad.json
  (cancer) <- d3.json \all-data.json
  $scope.years = [k for k of cancer.data]
  $scope.diseases = cancer.types
  $scope.curyear = $scope.years.0
  $scope.curdis = $scope.diseases.0
  $scope.playing = false
  $scope.year-index = 0

  _ratio = (v, year, d) -> 
    [c,t] = cancer.townmap[d]split \/
    if !popu[year] => return 0
    if !popu[year][c][t] => return 0
    return parseInt(10000 * v / popu[year][c][t]) / 100
  $scope.get-data-boundary = (cancer-type) !->
    $scope.max-bound = d3.max [d3.max [d3.max [v for d,v of ts[cancer-type]] for year, ts of cancer.data]]
    $scope.max-bound-ratio = d3.max [d3.max [d3.max [_ratio(v,year,d) for d,v of ts[cancer-type]] for year, ts of cancer.data]]
    $scope.min-bound = 0
  $scope.stop = ->
    if $scope.playing => $interval.cancel $scope.playing
    $scope.playing = false
  $scope.$watch 'normalize' -> $scope.update-data!
  $scope.$watch 'slower' ->
    if $scope.playing =>
      $scope.stop!
      $scope.play!

  $scope.play = ->
    if $scope.playing => return
    for i from 0 til $scope.years.length => if $scope.years[i]==$scope.curyear => 
      $scope.year-index = i
      break
    $scope.playing = $interval ->
      do =>
        $scope.curyear = $scope.years[$scope.year-index]
        $scope.year-index++
        if $scope.year-index >= $scope.years.length => $scope.year-index = 0
      while $scope.curyear <1991 and $scope.normalize
    , if $scope.slower => 600 else 200
  $scope.update-data = ->
    data = $scope.cancer-data $scope.map
    $scope.update-map $scope.map, data
  $scope.$watch 'curyear', -> $scope.update-data!
  $scope.$watch 'curdis', -> 
    $scope.get-data-boundary $scope.curdis
    $scope.update-data!
  (rpi) <- d3.json \rpi.json
  $scope.$watch 'chosen' -> $scope.chosen-value = $scope.hash[$scope.chosen]
  $scope.$watch 'chosen' -> $scope.chosen-value = $scope.hash[$scope.chosen]
  $scope.cancer-data = (map) ->
    d = cancer.data[$scope.curyear][$scope.curdis] or {}
    $scope.hash = {}
    for k,v of d => $scope.hash[cancer.townmap[parseInt(k)]] = v
    $scope.chosen-value = $scope.hash[$scope.chosen]
    $scope.hash
  $scope.random-data = (map) ->
    ret = {}
    for item in map.topo.features
      ret[item.properties.name] = Math.random!*1000
    ret
  $scope.update-map = (map, data) ->
    bound = min: 9007199254740992, max: 0
    towns = map.svg.selectAll \path.town
      .each ({properties: p}) -> 
        [c,t] = p.name.split \/
        p.value = data[p.name] or 0
        p.population = if popu[parseInt($scope.curyear)] => that[c][t] else 0
        p.ratio = if p.population => parseInt(10000 * p.value / p.population)/100 else 0
        v = if $scope.normalize => p.ratio else p.value
        bound.max >?= v
        bound.min <?= v
    if bound.max == 0 => bound.max = 1
    if $scope.fixlegend => max = ( if $scope.normalize => $scope.max-bound-ratio else $scope.max-bound )
    else max = bound.max
    map.heatmap = d3.scale.linear!domain [0, max/3, max/2, max] .range map.heatrange
    map.heatcolor = ({properties: p}) -> map.heatmap if $scope.normalize => p.ratio else p.value
    towns.transition!duration 300 .style do
      fill: -> map.heatcolor it
      stroke: -> map.heatcolor it
    $scope.make-tick map

  $scope.make-tick = (map) ->
    {svg, heatmap, tickcount} = map
    htick = heatmap.ticks tickcount
    domain = heatmap.domain!
    htick = [parseInt(i*1000)/1000 for i from 0 to domain[* - 1] by domain[* - 1]/10]
    svg.selectAll \rect.tick .data htick 
      ..exit!remove!
      ..enter!append \rect
        .attr \class, \tick
    svg.selectAll \rect.tick
      .attr do
        width: 20
        height: 15
        x: 150
        y: (d,i) -> 50 + i * 15
        fill: -> heatmap it
    svg.selectAll \text.tick .data htick 
      ..exit!remove!
      ..enter!append \text .attr \class, \tick
    svg.selectAll \text.tick
      .attr do
        class: \tick
        x: 175
        y: (d,i) -> 63 + i * 15
      .text -> it

  $scope.init-map = (node, cb) ->
    (data) <- d3.json \twTown1982.topo.json
    ret = {}
    topo = topojson.feature data, data.objects["twTown1982.geo"]
    topo.features.map ->
      it.properties.TOWNNAME = it.properties.TOWNNAME.replace /\(.+\)?\s*$/g, ""
      it.properties.name = it.properties.name.replace /\s*\(.+\)?\s*$/g, ""
    prj2 = d3.geo.mercator!center [120.979531, 23.978567] .scale 50000
    prj = ([x,y]) ->
      if x<119 => x += 1
      prj2 [x,y]
    path = d3.geo.path!projection prj
    svg = d3.select node
    color = {}
    town = {}
    [r,g,b] = [5,5,5]
    for item in topo.features =>
      c = "rgb(#r,#g,#b)"
      color[c] = item.properties.TOWNNAME
      item.properties.c = c
      town[item.properties.TOWNNAME] = item
      r += 10
      if r > 255 =>
        r = 5
        g += 10
      if g > 255 =>
        g = 5
        b += 10
    svg.selectAll \path.town .data topo.features .enter!append \path
      .attr \class \town
      .attr \d path
      .style \fill -> it.properties.c
      .style \stroke -> it.properties.c
      .style \stroke-width \0.5px
      .style \opacity 1.0
      .on \mouseover (d) -> $scope.$apply -> $scope.chosen = d.properties.name
      .on \click (d) -> $scope.$apply -> $scope.chosen = d.properties.name
    heatrange = <[#494 #6c0 #ff0 #f00]>
    heatmap = d3.scale.linear!domain [0,1,2,5] .range heatrange
    tickcount = 10
    ret <<< {svg, prj, path, heatmap, heatrange, topo, tickcount}
    $scope.make-tick ret
    cb ret

  $scope.init-map \#svg, -> 
    $scope.map = it
    $timeout (->
      data = $scope.cancer-data $scope.map
      $scope.update-map $scope.map, data
    ), 1000
