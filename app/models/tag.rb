class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks, :foreign_key => "facebook_identifier"
  before_create :generate_wiki_url_and_thumb
  validates :uri, :presence => true
  
  before_create :generate_wiki_url_and_thumb

  def generate_wiki_url_and_thumb
    movie = Movie.where(:uri => self.uri).first
   self.wikipedia_url = movie.wikipedia_url
   puts(movie.thumbnail)
   self.thumbnail = movie.thumbnail.gsub!('commons/thumb','en').gsub!(/\/200px.*/, '')
   puts(self.thumbnail)
  end
 
  def retrieve_info
    # Append RDF information to people-movie.nt
    query = <<-QUERY
        CONSTRUCT {
            <#{self.uri}> dbpprop:starring ?star.
            <#{self.uri}> dbpedia-owl:director ?director.
        } WHERE {
            <#{self.uri}> dbpprop:starring ?star.
            <#{self.uri}> dbpedia-owl:director ?director.
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

  def generate_wiki_url_and_thumb
    movie = Movie.where(:uri => self.uri).first
    self.wikipedia_url = movie.wikipedia_url
    self.thumbnail = movie.thumbnail
  end
end