require! <[fs xlsjs]>

convert-json = (infile, outfile) ->
  csv = fs.read-file-sync infile .toString!
  lines = csv.replace(/"(.+)\n(.+)"/g, '"$1$2"')split(\\n)filter(-> it.replace(/,/g, "")trim!)
  year = 0
  for line in lines
    ret = /(\d+)年,/exec line
    if ret => 
      year = parseInt ret.1
      continue
    ret = /診斷年齡,/exec line
    if ret =>
      cells = line.split \,
      dis-idx = q: {}, p: {}
      dis-list = []
      start = false
      for i from 0 til cells.length => 
        if !cells[i] => continue
        if cells[i]==\診斷年齡 => 
          start = true
          continue
        if !start => continue
        dis-idx.q[cells[i]] = i
        dis-idx.p[i] = cells[i]
        dis-list.push cells[i]
      console.log dis-list
convert-csv = (infile, outfile) ->
  xls = xlsjs.read-file infile
  sheet = xls.Sheets[xls.SheetNames.0]
  fs.write-file-sync outfile, (xlsjs.utils.make_csv(sheet, {FS: \,, RS: \\n}))

batch-convert = ->
  files = [ ["xls/#f", "csv/#{f.replace(/\.xls$/g, ".csv")}", "json/#{f.replace(/\.xls$/g, ".json")}"] for f in fs.readdir-sync(\xls/) ]filter(->/\.xls$/exec it.0)
  for file in files
    if !fs.exists-sync(file.1) =>
      console.log "converting #{file.0} to csv"
      convert-csv file.0, file.1
    if !fs.exists-sync(file.2) =>
      console.log "converting #{file.1} to json"
      convert-json file.1, file.2

batch-convert!
