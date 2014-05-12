require! <[fs]>

files = ["csv/age/#f" for f in fs.readdir-sync(\csv)]
all = []
for file in files
  if ! /\.csv$/exec(file) => continue
  data = fs.read-file-sync file .toString!
  ret = /\[鄉鎮\]([^\]]+)\[/g.exec data
  if !ret => 
    console.log "#file: no data"
    continue
  console.log "#file: #{ret.1.trim!}"
  if ret.1.split(",").length > 1 => all.push file
console.log "==== csv with multi-town selected ===="
console.log all.join(" ")
