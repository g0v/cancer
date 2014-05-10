require! <[fs]>
 
town = JSON.parse(fs.read-file-sync \town.json .toString!)
townmap = []
count = 0
for k,v of town.town => townmap.push v
for k,v of town.town
  town.town[k] = count
  count++

files = ["json/#f" for f in fs.readdir-sync(\json)]
data = {}
types = {}
for file in files
  if not /\.json$/exec(file) => continue
  ret = /(CRA_\d+)\.json/g.exec file
  if !ret => continue
  name = town.town[ret.1]
  if !name => continue
  json = JSON.parse(fs.read-file-sync file .toString!)
  for year of json
    for type of json[year]
      sum = [v for k,v of json[year][type]]reduce ((a,b) -> a + b), 0
      types[type] = true
      data.{}[year].{}[type][name] = sum

types = [t for t of types]
console.log types.join("\n")
fs.write-file-sync \all-data.json, JSON.stringify({townmap, data, types})
