require! <[fs xlsjs]>
counties = <[新北市 台北市 台中市 台南市 高雄市 宜蘭縣 台灣省 桃園縣 新竹縣 苗栗縣 彰化縣 南投縣 嘉義縣 屏東縣 台東縣 花蓮縣 澎湖縣 基隆市 新竹市 嘉義市 福建省 金門縣 連江縣 雲林縣]>

convert = (county, town) ->
  county = county.replace /臺/g, "台"
  if town => town = town.replace /臺/g, "台"
  if county in <[台北市 台北縣 台中縣 台南縣 高雄縣]> =>
    if town => town = town.substring(0,town.length - 1) + "區"
    if county == \台北縣 => county = \新北市
    county = county.replace \縣, \市
  if county=="彰化" and town=="溪洲" => town = "溪州"
  if county=="苗栗縣" and town=="通宵鎮" => town = "通霄鎮"
  [county.trim!, (town or "")trim!]

#xls = xlsjs.read-file \population.xls
#sheet = xls.Sheets[xls.SheetNames.0]
#fs.write-file-sync \population.csv, (xlsjs.utils.make_csv(sheet, {FS: \,, RS: \\n}))

[county, town, hash] = ["", "", {}]
lines = fs.read-file-sync \population.csv .toString!replace /"([^"]+)[\n,]([^"]+)"/g, "$1$2" .split \\n

for line in lines
  line = line.split \,
  [a,b] = convert line.0.trim!, null
  if a in counties =>
    county = a
    continue
  if not county or !line.4 or  isNaN(line.4) => continue
  town = line.0
  [county, town] = convert county, town
  for i from 80 to 102 => hash.{}[i].{}[county][town] = parseInt(line[i - 76])
fs.write-file-sync \population.json, JSON.stringify(hash)
