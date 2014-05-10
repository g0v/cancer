require! <[fs]>
lines = fs.read-file-sync \town.raw .toString!split \\n
map = county: {}, town: {}

patch = <[台北市 新北市 台中市 高雄市 臺南市]>
counties = {}
for line in lines
  line = line.replace(/\(.+?\)/g, "")split " "
  if line.0.length < 7 => 
    map.county[line.0] = line.1
    counties{line.1} = 1
  else
    name = line.1
    if name.substring(0,3) of counties => name = name.substring(3)
    if map.county[line.0.substring(0,6)] in patch => 
      name = name.substring(0,name.length - 1) + "區"
    name = map.county[line.0.substring(0,6)] + "/" + name
    map.town[line.0] = name
fs.write-file-sync \town.json, JSON.stringify(map)
