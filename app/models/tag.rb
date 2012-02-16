class Tag < ActiveRecord::Base
  has_many :tags_facebooks
  has_many :facebooks, :through => :tags_facebooks, :foreign_key => "facebook_identifier"
  
  validates :uri, :presence => true

  def retrieve_info    
    tag.retrieve_thumbnail if self.thumbnail.empty?    
    tag.retrieve_wikipedia_url if self.wikipedia_url.empty?

    # Append RDF information to people-movie.nt
    query = <<-QUERY
        CONSTRUCT {
            <#{self.uri}> ?property ?object.
        } WHERE {
            <#{self.uri}> ?property ?object.
        }
      QUERY
    params = {:query => query, 
             :format => "application/sparql-results+json",
             'default-graph-uri' => "http://dbpedia.org"}

    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)

    begin  
        graph = RDF::Graph.load('app/assets/rdf/people-film.nt', :format => :ntriples)
        triple_writer = RDF::NTriples::Writer.new
        triple = [RDF::URI.new("http://www.facebook.com/" + identifier), node, tag_uri]
        RDF::Writer.open('app/assets/rdf/people-film.nt') do |writer|
            if !graph.has_triple?(triple)
                graph << triple
            end
            writer << graph
        end
    rescue
        puts "An error occured - No such file" 
    end
  end
  
  def generate_director
    query = <<-QUERY
        SELECT DISTINCT ?director, str(?nname) as ?name WHERE {
          <#{self.uri}> dbpprop:director ?director.
          ?director foaf:name ?nname.
        }
      QUERY
    params = {:query => query, 
             :format => "application/sparql-results+json",
             'default-graph-uri' => "http://dbpedia.org"}
    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)
    begin
      @results = JSON.parse(postData.body)["results"]["bindings"]
      if @results.length > 0
        if Director.where(:uri => results[0]['director']['value']).empty?
          Director.create(:uri => results[0]['director']['value'], :name => results[0]['name']['value'])
        end
      end
    rescue
    end
  end

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
