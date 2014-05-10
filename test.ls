require! <[fs]>

popu = JSON.parse(fs.read-file-sync \population.json .toString!)
json = JSON.parse(fs.read-file-sync \total.json .toString!)
v = json.value.101["13"]
/*
data = []
for county of v
  for town of v[county]
    data.push {name: "#{county}#{town}", patient: v[county][town], population: popu.101[county][town]}

data.sort (a,b) -> b.patient - a.patient
for n in data
  console.log n.name, n.patient, n.population
*/
count = 0
for idx of json.value.101
  for county of json.value.101[idx]
    for town of json.value.101[idx][county]
      if town=="白沙鄉" => 
        console.log idx, json.value.101[idx][county][town]
        count += json.value.101[idx][county][town]
console.log count, popu.101["澎湖縣"]["白沙鄉"]
