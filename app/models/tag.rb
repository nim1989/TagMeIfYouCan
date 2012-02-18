class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks, :foreign_key => "facebook_identifier"
  
  validates :uri, :presence => true

  def retrieve_info
    # Append RDF information to people-movie.nt
    query = <<-QUERY
        CONSTRUCT {
            <#{self.uri}> ?property ?object.
        } WHERE {
            <#{self.uri}> ?property ?object.
        }
      QUERY
    params = {:query => query, 
             :format => "text/plain",
             'default-graph-uri' => "http://dbpedia.org"}

    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)

    begin
      File.open('app/assets/rdf/people-film.nt', 'a') do |file| 
        file.puts postData.body
      end
    rescue
    end
  end
end