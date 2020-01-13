module DifferentiateArmHelper
  # Sanity check.
  # Simple test to ensure arms are unique within a study.
  # This is by arm id and not arm title yet.
  #
  # return Bool
  def self.check_for_arm_id_uniqueness(study_id)
    study = Study.find study_id
    lsof_arms = []
    study.arms.each do |arm|
      if lsof_arms.include? arm
        return false
      else
        lsof_arms << arm
      end
    end

    if lsof_arms.length.eql? study.arms.length
      return true
    else
      return false
    end
  end

  def self.differentiate_arm_titles(study_id)
    unique = true
    study = Study.find study_id
    lsof_arm_titles = []
    study.arms.each do |arm|
      if lsof_arm_titles.include? arm.title
        puts "List of existing titles: #{ lsof_arm_titles }"
        new_title = "#{ arm.title } - #{ arm.description }"
        puts "Original title: #{ arm.title }"
        puts "New title: #{ new_title }"
        arm.title = new_title
        #arm.save
        lsof_arm_titles << arm.title
        unique = false
      else
        lsof_arm_titles << arm.title
      end

    end

    return unique
  end
end
