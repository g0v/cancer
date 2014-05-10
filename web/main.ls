require! <[fs]>
population = JSON.parse(fs.read-file-sync \population.json .toString!)
cancer = JSON.parse(fs.read-file-sync \total.json .toString!)value

all = {}
for year from 93 to 101
  for idx from 1 to 15
    for county,towns of cancer[year][idx]
      for town,count of cancer[year][idx][county]
        if !county or !town => continue
        all.{}[year].{}[county][town] ?= 0
        all.{}[year].{}[county][town] += cancer[year][idx][county][town]

for year from 93 to 101
  list = []
  for county,towns of all[year]
    for town,count of all[year][county]
      all[year][county][town] /= population[year][county][town]
      list.push {} <<< {value: all[year][county][town], county, town}
  list.sort (a,b) -> b.value - a.value
  console.log list.slice(0,10)
