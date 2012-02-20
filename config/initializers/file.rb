# If in development 
if Rails.env.development?
  RDF_FILE_PATH = Rails.root.join('app', 'assets', 'rdf', 'people-film.nt')

  if ! File.directory? Rails.root.join('app', 'assets')
    Dir.mkdir(Rails.root.join('app', 'assets'))
  end
  
  if ! File.directory? Rails.root.join('app', 'assets', 'rdf')
    Dir.mkdir(Rails.root.join('app', 'assets', 'rdf'))
  end
  
  if !FileTest.exists?(RDF_FILE_PATH)
    File.open(RDF_FILE_PATH, 'a')
  end
  

# In production
elsif  Rails.env.production?
  RDF_FILE_PATH = '/data/assets/rdf/people-film.nt'

  if ! File.directory? '/data/assets'
    Dir.mkdir('/data/assets')
  end
  if ! File.directory? '/data/assets/rdf'
    Dir.mkdir('/data/assets/rdf')
  end
  
  if !FileTest.exists?(RDF_FILE_PATH)
    File.open(RDF_FILE_PATH, 'a')
  end
end
