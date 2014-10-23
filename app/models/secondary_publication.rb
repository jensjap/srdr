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

# This class handles secondary publications for a study. A study can have unlimited secondary publications. A secondary publication can have
# many secondary publication numbers.
class SecondaryPublication < ActiveRecord::Base
    require 'net/http'
    belongs_to :study, :touch=>true
    validates :title, :presence => true
    has_many :secondary_publication_numbers, :dependent => :destroy
    accepts_nested_attributes_for :secondary_publication_numbers, :allow_destroy => true

    # get secondary publication numbers based on the secondary publication id.
    # @param [integer] pub_id the secondary publication id
    # @return [array] the list of secondary publication numbers
    def self.get_pub_uis(pub_id)
        return SecondaryPublicationNumber.where(:secondary_publication_id => pub_id).all
    end

    # get the next consecutive display number (ordering number) of a secondary publication based on the study id
    # @param [integer] study_id
    # @return [integer] the next number in the sequence
    def get_display_number(study_id)
        current_max = SecondaryPublication.maximum("display_number",:conditions => ["study_id = ?", study_id])
        if (current_max.nil?)
            current_max = 0
        end
        return current_max + 1
    end

    # adjust the display numbers (ordering numbers) of a secondary publication based on the study id
    # @param [integer] study_id
    def shift_display_numbers(study_id)
        myNum = self.display_number
        hi_pubs = SecondaryPublication.find(:all, :conditions => ["study_id = ? AND display_number > ?", study_id, myNum])
        hi_pubs.each { |pub|
            tmpNum = pub.display_number
            pub.display_number = tmpNum - 1
            pub.save
        }
    end

    # increment display number (ordering number) of a secondary publication based on the secondary publication id
    # @param [integer] id secondary publication id
    # @param [integer] study_id
    def self.move_up_this(id, study_id)
        @this = SecondaryPublication.find(id.to_i)
        if @this.display_number > 1
            new_num = @this.display_number - 1
            SecondaryPublication.decrease_other(new_num, study_id)
            @this.display_number = new_num
            @this.save
        end
    end

    # decrement display number (ordering number) of a secondary publication.
    # used in move_up_this(id, study_id)
    # @param [integer] num the display number to decrement
    # @param [integer] study_id
    def self.decrease_other(num, study_id)
        @other = SecondaryPublication.where(:study_id => study_id, :display_number => num).first
        if !@other.nil?
            @other.display_number = @other.display_number + 1;
            @other.save
        end
    end

    # Given an pubmed ID, return author, title, year, etc.
    # by parsing XML from pubmed
    # @param [integer] pmid pubmed id
    # @return [array] array of data containing [title,authors,country,year,journal_title,volume,issue]
    def self.get_summary_info_by_pmid(pmid)
        pmid = pmid.to_s
        pmid.strip!

        # pull the full record for this publication from PubMed at NCBI
        url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=" + pmid + "&retmode=xml"
        puts "------- GETTING SUMMARY INFO BY PMID --------\n\n"
        puts "The initial URL is #{url}\n\n"
        puts "getting the XML for that URL..."
        # get the xml as a string
        xml = Net::HTTP.get_response(URI.parse(url)).body
        puts "XML was collected: and is #{xml.length} characters long\n"
        # create an xml document with nokogiri
        # set it to ignore blank nodes
        xml = Nokogiri::XML(xml.to_s) do |config|
            config.noblanks
        end

        # set default values in case fields cannot be found.
        authors = "-- Not Found --"
        title = "Not Found - Please check PubMed ID for accuracy."
        year = "-- Not Found --"
        country = "-- Not Found --"
        journal_title = "-- Not Found --"
        volume = "-- Not Found --"
        issue = "-- Not Found --"
        abstract = "-- Not Found --"

        # get the year
        year_entry = xml.xpath("//Article//PubDate//Year")
        unless year_entry.empty?
            year = year_entry[0].children[0].content
        end

        # get the authors
        auth = xml.xpath("//Article//AuthorList//Author[LastName | Initials]")
        auth_entries = []
        unless auth.empty?
            auth.each do |author|
                begin
                    lname   = author.xpath(".//LastName")[0].content
                    initial = author.xpath(".//Initials")[0].content
                    tmp = "#{lname} #{initial}."
                rescue Exception => e
                    tmp = "--"
                    puts "WARNING: Exception thrown while looking for authors. No!! Bad NCBI!"
                    puts "WARNING: Please see exception followed by backtrace.inspect below:"
                    puts e.message
                    puts e.backtrace.inspect
                else
                    puts "INFO: Parsing list of authors did not throw any exceptions. Nicely done NCBI!"
                ensure
                    auth_entries << tmp
                end
            end
            authors = auth_entries.join(", ")
        end

        # get the title
        title_entry = xml.xpath("//Article//ArticleTitle")
        unless title_entry.empty?
            title = title_entry[0].children[0].content
        end

        # get the journal title
        journal_titl = xml.xpath("//Article//Journal//Title")
        unless journal_titl.empty?
            journal_title = journal_titl[0].children[0].content
        end

        # get the volume and issue
        vol = xml.xpath("//Article//Journal//JournalIssue//Volume")
        unless vol.empty?
            volume = vol[0].children[0].content
        end

        # get the abstract
        abst = xml.xpath("//Abstract//AbstractText")
        unless abst.empty?
            abstract = ""
            abst.each do |a|
                abstract += "#{a.children[0].content}" if a.children[0]
            end            
        end

        ish = xml.xpath("//Article//Journal//JournalIssue//Issue")
        unless ish.empty?
            issue = ish[0].children[0].content
        end

        # get the affiliation
        country_entry = xml.xpath("//Article//Affiliation")
        unless country_entry.empty?
            country = country_entry[0].children[0].content
        end

        # remove any braces from the title (I see these once in a while)
        title.gsub!(/[\[\]]/,"")
        return [title,authors,country,year,journal_title,volume,issue,abstract]
    end
end
