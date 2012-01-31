require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController
  
  def index
  end

  def search
    query = <<-QUERY
      select distinct ?uri, ?sc, ?rank where 
       { 
         { 
           { 
             select ?uri, ( ?sc * 3e-1 ) as ?sc, ?o1, ( sql:rnk_scale ( <LONG::IRI_RANK> ( ?uri ) ) ) as ?rank where 
             { 
               ?uri ?s1textp ?o1 .
               ?o1 bif:contains '"#{params[:query_string]}"' option ( score ?sc ) .

             }
            order by desc ( ?sc * 3e-1 + sql:rnk_scale ( <LONG::IRI_RANK> ( ?uri ) ) ) limit 20 offset 0 
           }
          }
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
      format.html{ @results }
      format.json{ render :json => @results.to_json }
    end
  end

end
