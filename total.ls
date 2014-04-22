require! <[fs]>

title-beautify = -> it.replace /十五大癌症第.+位([^-]+)-+按戶籍縣市別統計/g, "$1"
json = {title:{}, value: {}}
dirs = fs.readdirSync(\raw/)
for dir in dirs
  year = parseInt(dir)
  for i from 1 to 15 =>
    data = fs.read-file-sync "raw/#dir/#i.csv" .toString!
    data = data.replace /"(.+)\n(.+)"/g, '"$1"'
    data = data.replace /\s+- /g, " 0 "
    lines = data.split \\n
    title = title-beautify(lines.0.split \, .0)
    json.title.{}[year][i] = title
    for line in lines
      if line.index-of(\")!=0 => continue
      line = line.split \,
      [region, count] = [line.0.replace(/"/g,""), parseInt(line.1)]
      region = region.replace /臺/g, "台"
      county = region.substring(0,3)
      town = region.substring(3)
      json.value.{}[year].{}[i].{}[county][town] = count

fs.write-file-sync \total.json, JSON.stringify(json)
