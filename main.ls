require! <[fs request xlsjs]>

root = "http://www.mohw.gov.tw/cht/DOS/"
findyear = /全民健康保險醫療統計<\/a>＞<a href="[^"]+">(\d+)年度全民健康保險醫療統計年報/g
findlink = /<span id="ctl[^"]+"><a target='_self' href='([^']+)' title='' >([^<]+)<\/a><\/span>/g
datasrc = JSON.parse(fs.read-file-sync \datasrc.json .toString!)
total = {}
type = {}

get-file = (files, year, map, count, idx) ->
  if files.length == 0 =>
    console.log "year #year fetched."
    return setTimeout (-> download idx + 1), 10
  file = files.splice(0,1)0
  type.{}[year][count] = file.1
  name = "raw/#year/#count.xls"
  csvname = "raw/#year/#count.csv"
  url = "#{root}#{file.0}"
  console.log "retrieve #{name} from #{url} ... #{files.length} remains"
  map[name] = [url, file.1]
  request url .pipe fs.createWriteStream name .on \finish, ->
    xls = xlsjs.read-file name
    sheet = xls.Sheets[xls.SheetNames.0]
    fs.write-file-sync csvname, (xlsjs.utils.make_csv(sheet, {FS: \,, RS: \\n}))
    data = fs.read-file-sync csvname .toString!
    data = data.replace /"(.+)\n(.+)"/g, '"$1"'
    data = data.replace /\s*- */g, " 0 "
    lines = data.split \\n
    for line in lines
      line = line.split \,
      town = line.0.replace /"/g, ""
      if line.0.index-of(\")==0 => total.{}[year].{}[count][town] = parseInt line.1

    setTimeout (-> get-file files, year, map, count + 1, idx), 10


download = (idx) ->
  if datasrc.length <= idx => 
    console.log "fetch done."
    # deprecated. run total.ls instead
    # fs.write-file-sync \total.json, JSON.stringify({type,total})
    return
  console.log "retrieve year: #{datasrc[idx]0}"
  (e,r,b) <- request datasrc[idx]1
  data = b.split \\n
  year = datasrc[idx]0
  files = ([findlink.exec(line) for line in data]filter (->it) .map -> [it.1, it.2])
  if not (fs.exists-sync "raw/#year") => fs.mkdir-sync "raw/#year"
  get-file files, year, {}, 1, idx

download 0
