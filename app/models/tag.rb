class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks, :foreign_key => "facebook_identifier"
  
  validates :uri, :presence => true
  
  def retrieve_thumbnail
    query = <<-QUERY
        SELECT DISTINCT ?thumbnail WHERE {
          <#{self.uri}> dbpedia-owl:thumbnail ?thumbnail.
        }
      QUERY
    params = {:query => query, 
             :format => "application/sparql-results+json",
             'default-graph-uri' => "http://dbpedia.org"}
    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)
    begin
      @results = JSON.parse(postData.body)["results"]["bindings"]
      if @results.length > 0
        self.thumbnail = @results[0]['thumbnail']['value'].gsub(/\.jpg.*/, ".jpg").gsub('/commons/thumb/', '/en/')
      end
    rescue
    end
    self.save
  end

  def retrieve_wikipedia_url
    query = <<-QUERY
        SELECT DISTINCT ?wikipedia_url WHERE {
          <#{self.uri}> foaf:page ?wikipedia_url.
        }
      QUERY
    params = {:query => query, 
             :format => "application/sparql-results+json",
             'default-graph-uri' => "http://dbpedia.org"}
    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)
    begin
      @results = JSON.parse(postData.body)["results"]["bindings"]
      if @results.length > 0
        self.wikipedia_url = @results[0]['wikipedia_url']['value']
      end
    rescue
    end
    self.save
  end
end
