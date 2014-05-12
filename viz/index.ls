main = ($scope, $timeout, $interval) ->
  $scope.chosen = "點地圖看值"
  (popu) <- d3.json \population.json
  (cancer) <- d3.json \all-data.json
  $scope.years = [k for k of cancer.data]
  $scope.diseases = cancer.types
  $scope.curyear = $scope.years.0
  $scope.curdis = $scope.diseases.0
  $scope.playing = false
  $scope.year-index = 0
  $scope.stop = ->
    if $scope.playing => $interval.cancel $scope.playing
    $scope.playing = false
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
  $scope.$watch 'curdis', -> $scope.update-data!
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
    min = -1
    towns = map.svg.selectAll \path.town
      .each -> 
        v = data[it.properties.name] or 0
        it.properties.value = v
        [c,t] = it.properties.name.split \/
        mgyear = parseInt($scope.curyear) - 1911
        p = if popu[mgyear] => popu[mgyear][c][t] else 0
        if t == "中西區" and !p and popu[mgyear] => p = popu[mgyear][c]["中區"] + popu[mgyear][c]["西區"]
        it.properties.nvalue = if p => parseInt(100000 * v / p)/1000 else 0
        v = if $scope.normalize =>  it.properties.nvalue else it.properties.value
        if v and (min == -1 or min > v) => min := v
        #if popu[mgyear] => console.log popu[mgyear][c][t], v, p, it.properties.nvalue
    max = d3.max(map.topo.features, (-> if $scope.normalize => it.properties.nvalue else it.properties.value)) #>? 0.2
    #min = min >? 0.2 <?max - 0.1
    if min <=0 => min = 0.0001
    if max <=0 => max = 0.2
    map.heatmap = d3.scale.linear!domain [0, min, (min*2 + max)/2, max] .range map.heatrange
    towns.transition!duration 300 .style do
      fill: -> map.heatmap if $scope.normalize => it.properties.nvalue else it.properties.value
      stroke: -> map.heatmap if $scope.normalize => it.properties.nvalue else it.properties.value
    $scope.make-tick map

  $scope.make-tick = (map) ->
    {svg, heatmap, tickcount} = map
    htick = heatmap.ticks tickcount
    domain = heatmap.domain!
    htick = [parseInt(i*1000)/1000 for i from 0 to domain[* - 1] by domain[* - 1]/10]
    #htick = [parseInt(i*10)/10 for i from 0 to domain[* - 1] by domain[* - 1]/10]
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
