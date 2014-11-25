require! <[fs]>

data = JSON.parse(fs.read-file-sync \all-data.json .toString!)

out = []
for i from 0 til data.townmap.length =>
  t = data.townmap[i]
  a = data.data.1995.總計[i]
  b = data.data.2009.總計[i]
  c = data.data.2010.總計[i]
  out.push [t, (parseInt(1000 * b/a ) / 1000) or 0, (parseInt(1000 * c/a ) / 1000) or 0]

out = out.sort((a,b) -> a.1 - b.1)

console.log out
