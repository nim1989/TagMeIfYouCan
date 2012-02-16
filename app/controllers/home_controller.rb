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
    end
    @pending_tags   = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.pending.id).order("created_at DESC")
    @validated_tags = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.validated.id).order("created_at DESC")
    @rejected_tags  = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.rejected.id).order("created_at DESC")

    # Remove duplicate tags
    @validated_tags.uniq!{ |tag_facebook| tag_facebook.tag.uri }
    @rejected_tags.uniq!{ |tag_facebook| tag_facebook.tag.uri }
    
    graph = RDF::Graph.load("app/assets/rdf/people-film.nt")
    query = RDF::Query.new do
        pattern [:movie, RDF::URI.new("http://dbpedia.org/property/director"), :director]
    end
        
    @movies = []
    @directors = []
    query.execute(graph).each do |solution|
        @movies << solution.movie
        @directors << solution.director
    end
    @directors = @directors.collect{ |director| [director.to_s.gsub('http://dbpedia.org/resource/','').gsub('_', ' '), director.to_s]}
  end
  
  def get_infos
    graph = RDF::Graph.load("app/assets/rdf/people-film.nt")
    director = params[:directors]
    if params[:like] == 'false'
        foaf = RDF::FOAF.dislike
    else 
        foaf = RDF::FOAF.like    
    end
    query = RDF::Query.new do
        pattern [:movie, RDF::URI.new("http://dbpedia.org/property/director"), RDF::URI.new(director)]
        pattern [:pers, foaf, :movie]
    end
    @pers = []
    query.execute(graph).each do |solution|
        @pers << solution.pers.to_s.gsub('http://www.facebook.com/', '')
    end
    respond_to do |format|
        format.json { render :json => @pers.to_json }
    end

  end

  def search_movie
    movies = Movie.where("lower(label) LIKE '%#{params[:query_string]}%'")
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
  
  def you_might_like
    query = <<-QUERY    
      select distinct ?new_game, ?label where {
        <#{params[:uri]}> dcterms:subject ?category.
        ?new_category skos:related ?category.
        ?new_game dcterms:subject ?new_category.
        ?new_game rdfs:label ?label.
        FILTER(lang(?label) = 'en')
      }
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
      format.json{ render :json => @results.to_json }
    end    
  end

  def he_might_like
    # Getting random uri that users has been tagged with
    uri = TagsFacebook.where(:facebook_identifier => params[:user_identifier]).collect{ |tag_facebook| tag_facebook.tag.uri }.shuffle.first
    query = <<-QUERY    
      select distinct ?new_game, ?label where {
        <#{uri}> dcterms:subject ?category.
        ?new_category skos:related ?category.
        ?new_game dcterms:subject ?new_category.
        ?new_game rdfs:label ?label.
        FILTER(lang(?label) = 'en')
      }
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
      format.json{ render :json => @results.to_json }
    end
  end
end

# Suggestion
# dbpprop:olympic
# dcterms:subject


# select distinct ?uri, ?sc, ?rank where 
#  { 
#    { 
#      {
#        select ?uri, ( ?sc * 3e-1 ) as ?sc, ?o1, ( sql:rnk_scale ( <LONG::IRI_RANK> ( ?uri ) ) ) as ?rank where 
#        { 
#          ?uri ?s1textp ?o1 .
#          ?o1 bif:contains '"#{params[:query_string]}"' option ( score ?sc ) .
# 
#        }
#       order by desc ( ?sc * 3e-1 + sql:rnk_scale ( <LONG::IRI_RANK> ( ?uri ) ) ) limit 20 offset 0 
#      }
#     }
#   }

# SELECT ?x ?label WHERE {
#   ?x rdfs:label ?label
#   FILTER(regex(?label,"^foot"))
# }