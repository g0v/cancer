require! <[fs]>

title-beautify = -> it.replace /十五大癌症第.+位([^-]+)-+按戶籍縣市別統計/g, "$1"
json = {title:{}, value: {}}
dirs = fs.readdirSync(\raw/)

convert = (county, town) ->
  if county in <[台北市 台北縣 台中縣 台南縣 高雄縣]> =>
    town = town.substring(0,town.length - 1) + "區"
    if county == \台北縣 => county = \新北市
    county = county.replace \縣, \市
  if county=="彰化縣" and town=="溪洲鄉" => town = "溪州鄉"
  if county=="苗栗縣" and town=="通宵鎮" => town = "通霄鎮"
  if county=="新竹縣" and town=="峨嵋鄉" => town = "峨眉鄉"
  town = town.replace /\(.+$/g, ""
  [county, town]

for dir in dirs
  year = parseInt(dir)
  for i from 1 to 15 =>
    data = fs.read-file-sync "raw/#dir/#i.csv" .toString!
    data = data.replace /"(.+)\n(.+)"/g, '"$1"'
    data = data.replace /\s+- /g, " 0 "
    lines = data.split \\n
    title = title-beautify(lines.0.split \, .0)
    json.title.{}[year][i] = title
    start = 0
    for line in lines
      if start!=2 =>
        if line.index-of("總計")==0 and start == 1 => 
          start = 2
          continue
        else if line.index-of("鄉鎮別")==0 and start==0 => 
          start = 1
          continue
        continue
      line = line.split \,
      [region, count] = [line.0.replace(/"/g,""), parseInt(line.1)]
      region = region.replace /臺/g, "台"
      county = region.substring(0,3)
      town = region.substring(3)
      town = town.replace /[a-zA-Z. ]+/g, ""
      [county, town] = convert county, town
      json.value.{}[year].{}[i].{}[county][town] = count

fs.write-file-sync \total.json, JSON.stringify(json)
