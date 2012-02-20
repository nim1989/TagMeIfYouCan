require 'net/http'
require 'uri'
require 'json'
require 'rdf'
require 'rdf/raptor'  # for RDF/XML support
require 'rdf/ntriples'

include RDF
class HomeController < ApplicationController
  
  def index
    if current_user.nil?
      respond_to do |format|
        format.html{ redirect_to new_facebook_path }
      end
    else
        @pending_tags   = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.pending.id).order("created_at DESC")
        @validated_tags = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.validated.id).order("created_at DESC")
        @rejected_tags  = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.rejected.id).order("created_at DESC")
    
        # Remove duplicate tags
        @validated_tags.uniq!{ |tag_facebook| tag_facebook.tag.uri }
        @rejected_tags.uniq!{ |tag_facebook| tag_facebook.tag.uri }
        
        graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
        query = RDF::Query.new do
            pattern [:l, RDF::URI.new("http://dbpedia.org/ontology/director"), :director]
        end
        @directors = []
        query.execute(graph).each do |solution|
            @directors << solution.director
        end
        @directors = @directors.collect{ |director| [URI.unescape(director.to_s.gsub('http://dbpedia.org/resource/','').gsub('_', ' ')), director.to_s]} || []
        current_user_uri = current_user.uri
        query2 = RDF::Query.new do
            pattern [RDF::URI.new(current_user_uri), RDF::FOAF.like, :film]
            pattern [:film, RDF::URI.new("http://dbpedia.org/property/starring"), :actor]
        end
        @actors = []
        query2.execute(graph).each do |solution|
            @actors << solution.actor
        end
        @actors = @actors.collect{ |actor| [URI.unescape(actor.to_s.gsub('http://dbpedia.org/resource/','').gsub('_', ' ')), actor.to_s]}
    end
  end
  
  def get_infos
    graph = RDF::Graph.load(RDF_FILE_PATH)
    director = params[:directors]
    if params[:like] == 'false'
        foaf = RDF::FOAF.dislike
    else 
        foaf = RDF::FOAF.like    
    end
    query = RDF::Query.new do
        pattern [:movie, RDF::URI.new("http://dbpedia.org/ontology/director"), RDF::URI.new(director)]
        pattern [:pers, foaf, :movie]
    end
    @pers = {}

    query.execute(graph).each do |solution|
        @pers[solution.pers.to_s.gsub('http://www.facebook.com/', '')] = [] if @pers[solution.pers.to_s.gsub('http://www.facebook.com/', '')].nil?
        @pers[solution.pers.to_s.gsub('http://www.facebook.com/', '')] << Movie.where(:uri => solution.movie.to_s).first
    end

    respond_to do |format|
        format.json { render :json => @pers.to_json }
    end

  end
  
  def get_infos_actors
    graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
    actors = params[:actors]
    if params[:like] == 'false'
        foaf = RDF::FOAF.dislike
    else 
        foaf = RDF::FOAF.like    
    end
    query = RDF::Query.new do
        actors.each_with_index do |actor, idx|
            pattern [:movie, RDF::URI.new("http://dbpedia.org/ontology/starring"), RDF::URI.new(actor)]
        end
    end
    
    @movies = []
    query.execute(graph).each do |solution|
        @movies << solution.movie
    end
    
    @pers = []
    query.execute(graph).each do |solution|
        @pers << solution.pers.to_s.gsub('http://www.facebook.com/', '')
    end
    respond_to do |format|
        format.json { render :json => @pers.uniq!.to_json }
    end

  end

  def search_movie
    movies = Movie.where("lower(label) LIKE '%#{params[:query_string].downcase}%'")
    respond_to do |format|
      format.json{ render :json => movies.to_json }
    end
  end

  def search
    query_string = params[:query_string]
    query_string = query_string.downcase
    query = <<-QUERY
        SELECT DISTINCT ?uri, ?page, ?thumbnail WHERE {
          ?uri rdf:type <http://dbpedia.org/ontology/Sport>.
          ?uri rdfs:label ?label.
          ?uri foaf:page ?page.
          ?uri dbpedia-owl:thumbnail ?thumbnail.
          FILTER(regex(fn:lower-case(?label), "#{query_string}"))
        } LIMIT 20
      QUERY
    params = {:query => query, 
             :format => "application/sparql-results+json",
             'default-graph-uri' => "http://dbpedia.org"}
    postData = Net::HTTP.post_form(URI.parse('http://dbpedia.org/sparql'), params)
    begin
      @results = JSON.parse(postData.body)["results"]["bindings"]
    rescue
      @results = []
    end
    respond_to do |format|
      format.html{ @results }
      format.json{ render :json => @results.to_json }
    end
  end

  ######## Suggestion from ntriple file
  def movies_you_might_like
    graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
    ## Same director
    current_user_uri = current_user.uri
    query = RDF::Query.new do
        pattern [RDF::URI.new(current_user_uri), RDF::FOAF.like, :film]
        pattern [:film, RDF::URI.new('http://dbpedia.org/ontology/director'), :director]
        pattern [RDF::URI.new(current_user_uri), RDF::FOAF.knows, :friend]
        pattern [:friend, RDF::FOAF.like, :inferenced_film]
        pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/ontology/director'), :director]
    end
    movies = []
    solutions = query.execute(graph)
    solutions.distinct # Remove duplicates entries
    solutions.filter{|solution| solution.film != solution.inferenced_film } # Remove movies that user already likes
    solutions.each do |solution|
      movies << solution.inferenced_film.to_s
    end

    m = movies.collect{|movie| Movie.where(:uri => movie).first }
    m.uniq!
    m.each do |movie|
      uri = URI(movie.thumbnail)
      result = Net::HTTP.get_response(uri)    
      if !result.is_a?(Net::HTTPSuccess) 
        uri = URI('http://www.freebase.com/api/service/search?query=' + movie.label + '&type=/film/film')
        result = Net::HTTP.get(uri)
        result = JSON.parse(result)
        gui = result['result'][0]['guid']
        gui.slice!(0)
        self.thumbnail = 'http://api.freebase.com/api/trans/image_thumb/guid/' + gui + '?maxwidth=100'  
      end
    end    
    respond_to do |format|
      format.json{ render :json => m }
    end
  end

  def movies_you_might_like_from_actors
    graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
    actor = params[:actors]

    current_user_uri = current_user.uri
    ## Same actors
    query = RDF::Query.new do
        pattern [RDF::URI.new(current_user_uri), RDF::FOAF.like, :film]

        pattern [:film, RDF::URI.new('http://dbpedia.org/property/starring'), RDF::URI.new(actor)]
        pattern [RDF::URI.new(current_user_uri), RDF::FOAF.knows, :friend]

        pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/property/starring'), RDF::URI.new(actor)]
        pattern [:friend, RDF::FOAF.knows, :friend_of_friend]
        pattern [:friend_of_friend, RDF::FOAF.like, :inferenced_film]
    end
    friends = []
    solutions = query.execute(graph)

    solutions.filter{|solution| solution.film != solution.inferenced_film } # Remove movies that user already likes
    solutions.each do |solution|
      friends << solution.friend_of_friend.to_s
    end

    user = FbGraph::User.me(current_user.access_token).fetch
    friends_identifier = user.friends.collect{|friend| friend.identifier}

    f = friends.collect{|friend| friend.gsub('http://www.facebook.com/', '') }
    f.reject!{ |friend| friend == current_user.identifier }
    f.reject!{ |friend| friends_identifier.include?(friend) }
    f.uniq!
    
    respond_to do |format|
      format.json{ render :json => f }
    end
  end


  def friends_you_might_like
    graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
    ## Same director
    current_user_uri = current_user.uri
    query = RDF::Query.new do
      pattern [RDF::URI.new(current_user_uri), RDF::FOAF.like, :film]
      pattern [:film, RDF::URI.new('http://dbpedia.org/ontology/director'), :director]
      pattern [RDF::URI.new(current_user_uri), RDF::FOAF.knows, :friend]
      pattern [:friend, RDF::FOAF.knows, :friend_of_friend]
      pattern [:friend_of_friend, RDF::FOAF.like, :inferenced_film]
      pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/ontology/director'), :director]
    end
    
    friends = []
    solutions = query.execute(graph)
    solutions.each do |solution|
      friends << solution.friend_of_friend.to_s
    end
    friends.uniq!
    user = FbGraph::User.me(current_user.access_token).fetch
    friends_identifier = user.friends.collect{|friend| friend.identifier}
    
    f = friends.collect{|friend| friend.gsub('http://www.facebook.com/', '') }
    f.reject!{ |friend| friend == current_user.identifier }
    f.reject!{ |friend| friends_identifier.include?(friend) }
    f.uniq!
    respond_to do |format|
      format.json{ render :json => f }
    end
  end

end