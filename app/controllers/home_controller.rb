require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController
  
  def index
    if !current_user.nil?
      @pending_tags   = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.pending.id).order("created_at DESC")
      @validated_tags = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.validated.id).order("created_at DESC")
      @rejected_tags  = TagsFacebook.where(:facebook_identifier => current_user.identifier, :status_id => Status.rejected.id).order("created_at DESC")
    else
      respond_to do |format|
        format.html{ redirect_to new_facebook_path }
      end    
    end
  end

  def search_movie
    movies = Movie.where("lower(label) LIKE '#{params[:query_string]}%'")
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