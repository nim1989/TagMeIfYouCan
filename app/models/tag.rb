require 'net/http'

class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks, :foreign_key => "facebook_identifier"
  before_create :generate_wiki_url_and_thumb
  validates :uri, :presence => true
  
  def generate_wiki_url_and_thumb
    movie = Movie.where(:uri => self.uri).first
    self.wikipedia_url = movie.wikipedia_url
    self.thumbnail = movie.thumbnail
    uri = URI(self.thumbnail)
    result = Net::HTTP.get_response(uri)
    if !result.is_a?(Net::HTTPSuccess) 
      uri = URI(URI.escape('http://www.freebase.com/api/service/search?query=' + movie.label + '&type=/film/film'))
      result = Net::HTTP.get(uri)
      result = JSON.parse(result)
      gui = result['result'][0]['guid']
      gui.slice!(0)
      self.thumbnail = 'http://api.freebase.com/api/trans/image_thumb/guid/' + gui + '?maxwidth=100'  
    end
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
      File.open(RDF_FILE_PATH, 'a') do |file| 
        file.puts postData.body
      end
    rescue
    end
  end
end