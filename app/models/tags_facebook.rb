class TagsFacebook < ActiveRecord::Base
  belongs_to :facebook     , :class_name => "Facebook", :foreign_key => "facebook_identifier", :primary_key => "identifier"
  belongs_to :from_facebook, :class_name => 'Facebook', :foreign_key => "from_facebook_identifier", :primary_key => "identifier"
  belongs_to :tag
  belongs_to :status

  validates :facebook_identifier, :from_facebook_identifier, :tag_id , :presence => true
  
  
  def accept
    write_in_rdf(self.facebook.uri, true)
    self.status = Status.validated
    self.save
  end

  def decline
    write_in_rdf(self.facebook.uri, false)
    self.status = Status.rejected
    self.save
  end
  
  private 
  def write_in_rdf(uri, like = true)
    if like
        node = RDF::FOAF.like
    else
        node = RDF::FOAF.dislike
    end



    begin
        graph = RDF::Graph.load(RDF_FILE_PATH, :format => :ntriples)
        triple = [RDF::URI.new(uri), node, RDF::URI.new(self.tag.uri)]
        user_triple = [RDF::URI.new(uri), node, RDF::URI.new(self.tag.uri)]
        RDF::Writer.open('app/assets/rdf/people-film.nt') do |writer|
            if !graph.has_triple?(triple)
                graph << triple
            end

            if !graph.has_triple?(triple)
                graph << triple
            end
            writer << graph
        end
    rescue
        puts "An error occured - No such file" 
    end
  end

end
