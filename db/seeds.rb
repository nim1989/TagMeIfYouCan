Status.create(:name => 'validated')
Status.create(:name => 'rejected')
Status.create(:name => 'has_responded')
if Status.pending.nil?
  Status.create(:name => 'pending')
end


require File.dirname(__FILE__) + '/seed_movie.rb'

Movie.all.each do |movie|
  movie.thumbnail = movie.thumbnail.gsub('commons/thumb','en').gsub(/\/200px.*/, '')
  movie.save
end

File.open('app/assets/rdf/people-film.nt', 'w')
