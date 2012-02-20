if ! File.directory? Rails.root.join('app', 'assets')
  Dir.mkdir(Rails.root.join('app', 'assets'))
end

if ! File.directory? Rails.root.join('app', 'assets', 'rdf')
  Dir.mkdir(Rails.root.join('app', 'assets', 'rdf'))
end

if !FileTest.exists?(Rails.root.join('app', 'assets', 'rdf', 'people-film.nt'))
  File.open(Rails.root.join('app', 'assets', 'rdf', 'people-film.nt'), 'a')
end