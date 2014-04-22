require! <[fs]>
counties = <[新北市 臺北市 臺中市 臺南市 高雄市 宜蘭縣 臺灣省 桃園縣 新竹縣 苗栗縣 彰化縣 南投縣 嘉義縣 屏東縣 臺東縣 花蓮縣 澎湖縣 基隆市 新竹市 嘉義市 福建省 金門縣 連江縣]>

lines = fs.read-file-sync \population.csv .toString!split \\n
lines.splice(0,1)
county = ""
for line in lines
  line = line.split \,

