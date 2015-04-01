# encoding: utf-8

module GlobalModelMethod
  def clean_string
    # Details
    self.question          = self.question.to_s.gsub(/[“”]/, '"')          if (self.respond_to?(:question)          && self.question.present?)
    self.field_type        = self.field_type.to_s.gsub(/[“”]/, '"')        if (self.respond_to?(:field_type)        && self.field_type.present?)
    self.field_note        = self.field_note.to_s.gsub(/[“”]/, '"')        if (self.respond_to?(:field_note)        && self.field_note.present?)
    self.instruction       = self.instruction.to_s.gsub(/[“”]/, '"')       if (self.respond_to?(:instruction)       && self.instruction.present?)
    self.option_text       = self.option_text.to_s.gsub(/[“”]/, '"')       if (self.respond_to?(:option_text)       && self.option_text.present?)
    self.subquestion       = self.subquestion.to_s.gsub(/[“”]/, '"')       if (self.respond_to?(:subquestion)       && self.subquestion.present?)
    self.value             = self.value.to_s.gsub(/[“”]/, '"')             if (self.respond_to?(:value)             && self.value.present?)
    self.notes             = self.notes.to_s.gsub(/[“”]/, '"')             if (self.respond_to?(:notes)             && self.notes.present?)
    self.subquestion_value = self.subquestion_value.to_s.gsub(/[“”]/, '"') if (self.respond_to?(:subquestion_value) && self.subquestion_value.present?)

    # Arms & Outcomes
    self.title        = self.title.to_s.gsub(/[“”]/, '"')        if (self.respond_to?(:title)        && self.title.present?)
    self.units        = self.units.to_s.gsub(/[“”]/, '"')        if (self.respond_to?(:units)        && self.units.present?)
    self.description  = self.description.to_s.gsub(/[“”]/, '"')  if (self.respond_to?(:description)  && self.description.present?)
    self.note         = self.note.to_s.gsub(/[“”]/, '"')         if (self.respond_to?(:note)         && self.note.present?)
    self.notes        = self.notes.to_s.gsub(/[“”]/, '"')        if (self.respond_to?(:notes)        && self.notes.present?)
    self.outcome_type = self.outcome_type.to_s.gsub(/[“”]/, '"') if (self.respond_to?(:outcome_type) && self.outcome_type.present?)

    # Adverse Events
    self.description = self.description.to_s.gsub(/[“”]/, '"') if (self.respond_to?(:description) && self.description.present?)

    # Quality Dimensions
    self.field_notes            = self.field_notes.to_s.gsub(/[“”]/, '"')            if (self.respond_to?(:field_notes)            && self.field_notes.present?)
    self.guideline_used         = self.guideline_used.to_s.gsub(/[“”]/, '"')         if (self.respond_to?(:guideline_used)         && self.guideline_used.present?)
    self.current_overall_rating = self.current_overall_rating.to_s.gsub(/[“”]/, '"') if (self.respond_to?(:current_overall_rating) && self.current_overall_rating.present?)
    self.rating_item            = self.rating_item.to_s.gsub(/[“”]/, '"')            if (self.respond_to?(:rating_item)            && self.rating_item.present?)
  end
end