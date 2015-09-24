class CreateSrdrQualityImprovementQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :srdr_quality_improvement_questionnaires do |t|
      t.string :q1_first
      t.string :q1_last
      t.string :q1_email
      t.string :q2
      t.string :q3_lead
      t.string :q3_collaborator
      t.string :q4
      t.string :q5
      t.string :q6_month
      t.string :q6_year
      t.string :q7_abstrackr
      t.string :q7_openmeta
      t.string :q7_distiller
      t.string :q7_covidence
      t.string :q7_docdata
      t.string :q7_eros
      t.string :q7_sumari
      t.string :q7_cast
      t.string :q7_rayyan
      t.string :q7_revman
      t.string :q7_other
      t.string :q8
      t.string :q9
      t.string :q10
      t.string :q11
      t.string :q12a
      t.string :q12b
      t.string :q13
      t.string :q14
      t.string :q14_month
      t.string :q14_year
      t.string :q15
      t.string :q16
      t.string :q17a
      t.string :q17b
      t.string :q17c
      t.string :q17d
      t.string :q17e
      t.string :q18
      t.string :q19
      t.string :q20a
      t.string :q20b
      t.string :q20c
      t.string :q20d
      t.string :q20e
      t.string :q20f
      t.string :q21
      t.string :q22
      t.string :q23a
      t.string :q23b
      t.string :q23c
      t.string :q23d
      t.string :q24
      t.string :q25
      t.string :q26
      t.string :q26_month
      t.string :q26_year
      t.string :q27a
      t.string :q27b
      t.string :q27c
      t.string :q28
      t.string :q29
      t.string :q30
      t.string :q30_month
      t.string :q30_year
      t.string :q31a
      t.string :q31b
      t.string :q31c
      t.string :q32
      t.string :q33
      t.string :q34
      t.string :q34_month
      t.string :q34_year
      t.string :q35
      t.string :q36
      t.string :q37
      t.string :q38
      t.string :q38_month
      t.string :q38_year
      t.string :q39a
      t.string :q39b
      t.string :q39c
      t.string :q39d
      t.string :q40
      t.string :q41

      t.timestamps
    end
  end

  def self.down
    drop_table :srdr_quality_improvement_questionnaires
  end
end
