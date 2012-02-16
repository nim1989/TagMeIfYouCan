require 'rdf'
require 'rdf/raptor'  # for RDF/XML support
require 'rdf/ntriples'

include RDF
 
# begin 
#     graph = RDF::Graph.load("hello.nt", :format => :ntriples)
#     triple_writer = RDF::NTriples::Writer.new
#     
#     RDF::Writer.open("hello.nt") do |writer|
#         if !graph.has_triple?([RDF::Node.new(:hello), RDF::FOAF.like, 'lazdaazdl'])
#           graph << [:hello, RDF::FOAF.like, "lazdagal"]  
#         end
#         writer << graph
#     end
# rescue
#     puts "An error occured"    
# end


graph = RDF::Graph.load("films.nt")
query = RDF::Query.new do
    pattern [RDF::URI.new('http://dbpedia.org/resource/Grand_Canary_%28film%29'), RDF.type, :type]
end

query.execute(graph).each do |solution|
  puts solution.type
end