require 'rdf'
require 'rdf/raptor'  # for RDF/XML support
require 'rdf/ntriples'

include RDF
 
graph = RDF::Graph.load("app/assets/rdf/people-film.nt")

## Same director
query = RDF::Query.new do
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.like, :film]
    pattern [:film, RDF::URI.new('http://dbpedia.org/property/director'), :director]
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.knows, :friend]
    pattern [:friend, RDF::FOAF.like, :inferenced_film]
    pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/property/director'), :director]
end

## Find friends
query2 = RDF::Query.new do
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.like, :film]
    pattern [:film, RDF::URI.new('http://dbpedia.org/property/director'), :director]
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.knows, :friend]
    pattern [:friend, RDF::FOAF.knows, :friend_of_friend]
    pattern [:friend_of_friend, RDF::FOAF.like, :inferenced_film]
    pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/property/director'), :director]
end

## Same actors
query3 = RDF::Query.new do
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.like, :film]
    pattern [:film, RDF::URI.new('http://dbpedia.org/property/starring'), :actor]
    pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.knows, :person]
    pattern [:person, RDF::FOAF.like, :inferenced_film]
    pattern [:inferenced_film, RDF::URI.new('http://dbpedia.org/property/starring'), :actor]
end

query3 = RDF::Query.new do
    pattern [RDF::URI.new('http://dbpedia.org/resource/War_of_the_Worlds_%282005_film%29'), RDF::URI.new('http://dbpedia.org/property/starring'), :actor]
end

m = []
solutions = query.execute(graph)
solutions.distinct
solutions.filter do |solution|
  solution.film != solution.inferenced_film
end

solutions.each do |solution|
  #puts solution.inferenced_film
end

# query2.execute(graph).each do |solution|
#   puts solution.friend_of_friend
#   #m << solution.inferenced_film
# end

# queries = []
# movies.each do |solution_movie|
#   queries << RDF::Query.new do
#     pattern [:person, RDF::FOAF.like, :film]
#     pattern [RDF::URI.new('http://www.facebook.com/100000023494269'), RDF::FOAF.knows, :person]
#     pattern [:film, RDF::URI.new('http://dbpedia.org/property/director'), RDF::URI.new(solution_movie.director)]
#   end
# end
# 
# solutions_array = []
# queries.each do |query|
#   solutions_array << query.execute(graph)
# end
# 
# solutions_array.each do |solutions|
#   solutions = query.execute(graph)
#   solutions.distinct
#   #puts solutions
#   #solutions.filter{|solution| solution.person != RDF::URI.new('http://www.facebook.com/100000023494269')}
# end

# q = RDF::Query.new do
# #  pattern [:person, RDF::FOAF.like, :film]
#   pattern [RDF::URI.new('http://dbpedia.org/resource/The_War_of_the_Roses_%28film%29'), RDF::URI.new('http://dbpedia.org/property/director'), :director]
# end
# 
# q.execute(graph).each do |solution|
#   puts solution.film
# end


query2 = RDF::Query.new do
    pattern [:film, RDF::URI.new("http://dbpedia.org/property/starring"), :actor]
end
query2.execute(graph).each do |solution|
    puts solution.actor
end
