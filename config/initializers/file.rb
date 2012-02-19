if ! File.directory? "app/assets/rdf"
  Dir.mkdir('app/assets/rdf')
end

if !FileTest.exists?('app/assets/rdf/people-film.nt') 
  File.open('app/assets/rdf/people-film.nt', 'a')
end