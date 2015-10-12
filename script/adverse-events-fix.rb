require 'logger'
require '../config/environment.rb'
require 'fuzzystringmatch'

ActiveRecord::Base.logger = Logger.new(STDOUT)
@log = Logger.new(STDOUT)
@log.level = Logger::DEBUG

# CONSTANTS
PROJECT_ID  = 427
USER_ID     = 957  # csuarez
INTERNAL_ID = 'G1569041010'
FILE_NAME   = 'adverse-event-names.txt'

def main
  print_run_information
  # Fetch all adverse events for this project, user, internal id.
  adverse_events = get_adverse_events_from_active_record
  # Read in the correct names from the text file.
  adverse_event_title_list = get_adverse_event_titles_from_text_file
  # Now we work.
  correct_adverse_event_titles(adverse_events, adverse_event_title_list)
end

def print_run_information
  @log.info "It works."
  @log.info "Projects ID: %s" % PROJECT_ID
  @log.info "User ID: %s" % USER_ID
  @log.info "Internal ID: %s" % INTERNAL_ID
end

def get_adverse_events_from_active_record
  study = get_study_from_active_record.first
  adverse_events = AdverseEvent.where(study_id: study.id)
  adverse_events
end

def get_study_from_active_record
  study = Study.joins(:primary_publication,
                      :primary_publication_numbers)
               .where(primary_publication_numbers: { number: INTERNAL_ID })
               .where(project_id: PROJECT_ID)
               .where(creator_id: USER_ID)
  study
end

def get_adverse_event_titles_from_text_file
  adverse_event_title_list = []
  File.open(FILE_NAME, 'r') do |io|
    io.readlines.each do |line|
      adverse_event_title_list.push line.chomp
    end
  end
  adverse_event_title_list
end

def correct_adverse_event_titles(adverse_events, adverse_event_title_list)
  # Instantiate PhraseMatcher object
  pm = PhraseMatcher.new(adverse_event_title_list)
  # Loop through all adverse events. Update title and description
  adverse_events.each do |ae|
    log_title_and_description("Before", ae)
    # Squash the title and description.
    ae_squashed_title = ae.title + " " + ae.description
    # Use the PhraseMatcher object to find the best match.
    pm.phrase = ae_squashed_title
    best_match_for_title, score = pm.best_match
    @log.debug "Best match (with a score of %s): \"%s\"" % [score, best_match_for_title]
    # Update the title and the description.
    ae.title = best_match_for_title
    ae.description = ""
    log_title_and_description("After", ae)

    #!!! Save the changes.
    #ae.save

    # Wait for <CR>
    #gets
  end
end

def log_title_and_description(timepoint, ae)
    @log.info "%s\n - Title: %s\n - Description: %s" % [timepoint, ae.title, ae.description]
end


class PhraseMatcher
  # phrase_array is an array of best possible matches.
  def initialize(phrase_array)
    @phrase_array = phrase_array
    @phrase_hash = nil
    @phrase = nil
  end

  def phrase=(phrase)
    @phrase = phrase
    _build_phrase_hash
  end

  def best_match
    match = ""
    score = nil
    if @phrase
      match = @phrase_hash.first[0]
      score = @phrase_hash.first[1]
    else
      puts "You need to set a phrase first with PhraseMatcher.phrase=\"Phrase to compare.\""
      raise
    end

    return match, score
  end

  private
    def _build_phrase_hash
      # Initialize FuzzyStringMatch object.
      jarow = FuzzyStringMatch::JaroWinkler.create( :native )
      @phrase_hash = Hash.new
      @phrase_array.each do |ph|
        score = jarow.getDistance(@phrase, ph)
        @phrase_hash[ph] = score
      end
      # Sort by score. Reverse the result so the highest score is on top.
      @phrase_hash = @phrase_hash.sort_by { |k, v| v }.reverse
    end
end


if __FILE__ == $0
  main
end
