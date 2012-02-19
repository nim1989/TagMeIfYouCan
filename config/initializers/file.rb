if !FileTest.exists?('app/assets/rdf/people-film.nt') 
  File.open('app/assets/rdf/people-film.nt', 'a')
end