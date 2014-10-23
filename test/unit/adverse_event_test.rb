# == Schema Information
#
# Table name: adverse_events
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  title              :text
#  description        :text
#

require 'test_helper'

class AdverseEventTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

  # test get_adverse_events_by_arm

end
