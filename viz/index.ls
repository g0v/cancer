main = ($scope, $timeout, $interval) ->
  $scope.chosen = "尚未選取"
  (cancer) <- d3.json \all-data.json
  $scope.years = [k for k of cancer.data]
  $scope.curyear = $scope.years.0
  $scope.diseases = []
  $scope.playing = false
  $scope.year-index = 0
  $scope.stop = ->
    if $scope.playing => $interval.cancel $scope.playing
    $scope.playing = false
  $scope.play = ->
    if $scope.playing => return
    for i from 0 til $scope.years.length => if $scope.years[i]==$scope.curyear => 
      $scope.year-index = i
      break
    $scope.playing = $interval ->
      $scope.curyear = $scope.years[$scope.year-index]
      $scope.year-index++
      if $scope.year-index >= $scope.years.length => $scope.year-index = 0
    , 200
  $scope.update-data = ->
    data = $scope.cancer-data $scope.map
    $scope.update-map $scope.map, data
  $scope.$watch 'curyear', ->
    $scope.diseases = [k for k of cancer.data[$scope.curyear]]
    if !$scope.curdis =>
      $scope.curdis = $scope.diseases.0
    else $scope.update-data!
  $scope.$watch 'curdis', -> $scope.update-data!
  (rpi) <- d3.json \rpi.json
  $scope.cancer-data = (map) ->
    d = cancer.data[$scope.curyear][$scope.curdis] or {}
    hash = {}
    for k,v of d => hash[cancer.townmap[parseInt(k)]] = v
    hash
  $scope.random-data = (map) ->
    ret = {}
    for item in map.topo.features
      ret[item.properties.name] = Math.random!*1000
    ret
  $scope.update-map = (map, data) ->
    min = -1
    towns = map.svg.selectAll \path.town
      .each -> 
        v = data[it.properties.name]
        if v and (min == -1 or min > v) => min := v
        it.properties.value = v or 0

    max = d3.max(map.topo.features, (-> it.properties.value))
    map.heatmap = d3.scale.linear!domain [0, min, (min*2 + max)/2, max] .range map.heatrange
    towns.transition!duration 300 .style do
      fill: -> map.heatmap it.properties.value
      stroke: -> map.heatmap it.properties.value
    $scope.make-tick map

  $scope.make-tick = (map) ->
    {svg, heatmap, tickcount} = map
    htick = heatmap.ticks tickcount
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
    /*$interval (-> 
      data = $scope.random-data $scope.map
      $scope.update-map $scope.map, data
    ), 600*/
