class CreateSrdrQualityImprovementQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :srdr_quality_improvement_questionnaires, force: true do |t|
      t.text :q1_first
      t.text :q1_last
      t.text :q1_email
      t.text :q2
      t.text :q3_lead
      t.text :q3_collaborator
      t.text :q4
      t.text :q5
      t.text :q6_month
      t.text :q6_year
      t.text :q7_abstrackr
      t.text :q7_openmeta
      t.text :q7_distiller
      t.text :q7_covidence
      t.text :q7_docdata
      t.text :q7_eros
      t.text :q7_sumari
      t.text :q7_cast
      t.text :q7_rayyan
      t.text :q7_revman
      t.text :q7_other
      t.text :q8
      t.text :q9
      t.text :q10
      t.text :q11
      t.text :q12a
      t.text :q12b
      t.text :q13
      t.text :q14
      t.text :q14_month
      t.text :q14_year
      t.text :q15
      t.text :q16
      t.text :q17a
      t.text :q17b
      t.text :q17c
      t.text :q17d
      t.text :q17e
      t.text :q18
      t.text :q19
      t.text :q20a
      t.text :q20b
      t.text :q20c
      t.text :q20d
      t.text :q20e
      t.text :q20f
      t.text :q21
      t.text :q22
      t.text :q23a
      t.text :q23b
      t.text :q23c
      t.text :q23d
      t.text :q24
      t.text :q25
      t.text :q26
      t.text :q26_month
      t.text :q26_year
      t.text :q27a
      t.text :q27b
      t.text :q27c
      t.text :q28
      t.text :q29
      t.text :q30
      t.text :q30_month
      t.text :q30_year
      t.text :q31a
      t.text :q31b
      t.text :q31c
      t.text :q32
      t.text :q33
      t.text :q34
      t.text :q34_month
      t.text :q34_year
      t.text :q35
      t.text :q36
      t.text :q37
      t.text :q38
      t.text :q38_month
      t.text :q38_year
      t.text :q39a
      t.text :q39b
      t.text :q39c
      t.text :q39d
      t.text :q40
      t.text :q41

      t.timestamps
    end
  end

  def self.down
    drop_table :srdr_quality_improvement_questionnaires
  end
end
