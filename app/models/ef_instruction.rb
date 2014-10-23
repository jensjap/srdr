# == Schema Information
#
# Table name: ef_instructions
#
#  id           :integer          not null, primary key
#  ef_id        :integer
#  section      :string(255)
#  data_element :string(255)
#  instructions :text
#  created_at   :datetime
#  updated_at   :datetime
#

class EfInstruction < ActiveRecord::Base
end
