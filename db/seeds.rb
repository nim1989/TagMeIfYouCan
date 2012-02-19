Status.create(:name => 'validated')
Status.create(:name => 'rejected')
Status.create(:name => 'has_responded')
if Status.pending.nil?
  Status.create(:name => 'pending')
end


File.open('app/assets/rdf/people-film.nt', 'w')
require File.dirname(__FILE__) + '/seed_movie.rb'