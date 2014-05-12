require! <[fs]>
 
town = JSON.parse(fs.read-file-sync \town.json .toString!)
population = JSON.parse(fs.read-file-sync \../population.json .toString!)
townmap = []
count = 0
for k,v of town.town => townmap.push v
for k,v of town.town
  town.town[k] = count
  count++

files = ["json/age/#f" for f in fs.readdir-sync(\json/age)]
data = {}
types = {}
for file in files
  if not /\.json$/exec(file) => continue
  ret = /(CRA_\d+)\.json/g.exec file
  if !ret => continue
  name = town.town[ret.1]
  if isNaN(name) => continue
  json = JSON.parse(fs.read-file-sync file .toString!)
  for year of json
    for type of json[year]
      sum = [v for k,v of json[year][type]]reduce ((a,b) -> a + b), 0
      types[type] = true
      data.{}[year].{}[type][name] = sum

for year of data
  sum = {}
  for type of data[year]
    for name of data[year][type]
      if !sum[name] => sum[name] = 0
      sum[name] += data[year][type][name]
  for name of sum
    [c,t] = townmap[name].split("/")
    data[year].{}["總計"][name] = sum[name]
    p = population[parseInt(year) - 1911]
    #if p => 
    #  data[year].{}["比例"][name] = parseInt(1000 * sum[name] / p[c][t]) / 10

types = [t for t of types] ++ <[總計]>

fs.write-file-sync \all-data.json, JSON.stringify({townmap, data, types})
