# == Schema Information
#
# Table name: secondary_publications
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  title              :text
#  author             :string(255)
#  country            :string(255)
#  year               :string(255)
#  association        :string(255)
#  display_number     :integer
#  extraction_form_id :integer
#  pmid               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  journal            :string(255)
#  volume             :string(255)
#  issue              :string(255)
#  trial_title        :string(255)
#

require 'test_helper'

class SecondaryPublicationTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test the get_pub_uis function
    test "should return the SecondaryPublicationNumber objects for spub 1" do
        x = SecondaryPublication.get_pub_uis(@study1_spub1.id)
        assert_equal 2, x.length
        assert_equal "ct_123456", x[0].number
        assert_equal "NCBI Protein Entry", x[1].number_type
    end

    # test get_display_number
    # there are already 2 entries, so the next should be 3
    test "should return the next display number of 3" do
        assert_equal 5, @study1_spub1.get_display_number(@proj1_study1.id)
    end

    # test shift_display_numbers
    test "should reduce maximum display number for secondary pubs from 4 to 3" do
        # see that the max is being decremented
        assert_difference("SecondaryPublication.where(:study_id=>'1').select(['display_number']).collect{|x| x.display_number}.max", -1) do
            @study1_spub3.shift_display_numbers(@proj1_study1.id)
        end
        # see that the new max is equal to 3
        y = SecondaryPublication.where(:study_id=>1).select(["display_number"]).collect{|x| x.display_number}
        assert_equal 3, y.max
    end

    # test move_up_this
    test "should move the third position up to the second" do
        # the title of the one in the second position should now be 'originally the third secondary pub'
        SecondaryPublication.move_up_this(@study1_spub3.id, @proj1_study1.id)
        x = SecondaryPublication.where(:study_id=>@proj1_study1.id, :display_number => 2)
        assert_equal "Originally the third secondary pub", x.first.title # the fourth should have been moved up twice now
        assert_equal 1, x.length  # should only find one entry with that display number

        # test the decrease other by making sure the swap took place
        # the second position element should now be in position 3
        y = SecondaryPublication.where(:study_id=>@proj1_study1, :display_number => 3)
        assert_equal 1, y.length
        assert_equal "Associated publication 2", y.first.title, "decrease_other might not have worked"

    end

    # test get_summary_info_by_pmid
    # try it out first with a working pubmed id: 222222
    test "should return the proper publication for pmid 222222" do
        x = SecondaryPublication.get_summary_info_by_pmid(222222)
        # try first for an entry we know is good
        # order is title, author, country, year, journal_title, volume, issue
        assert_equal "The surgical aspects of insulinomas.", x[0], "Incorrect Title"
        assert_equal "van Heerden JA., Edis AJ., Service FJ.", x[1], "Incorrect Authors"
        assert_equal "-- Not Found --", x[2], "Incorrect Affiliation"
        assert_equal "Annals of surgery", x[4], "Incorrect Journal"
        assert_equal "1979", x[3], "Incorrect Year"
        assert_equal "189", x[5], "Iincorrect Volume"
        assert_equal "6", x[6], "Incorrect Issue"

        # now try for an entry that doesn't exist
        y = SecondaryPublication.get_summary_info_by_pmid(22222222222222)
        assert_equal 'Not Found - Please check PubMed ID for accuracy.', y[0]
    end
end
