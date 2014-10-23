class Srdrevents

    # Srdrevents is implemented as simple Array of SRDREvents records sorted by eventdate, created_at in DESC order
    def initialize
        # TODO - add constraints last 12 months or last 10 or by site...
        @events_list = SrdrEvents.find(:all, :conditions=>["created_at is not null"], :order=> "eventdate DESC, created_at DESC")
        if @events_list.nil? ||
           @events_list.size() == 0
            #puts "------------- setup default events ----------- "
            # Initialize with default events
            sevt = SrdrEvents.new
            sevt.title = "Request to Become a Participating Center"
            sevt.description = ""
            #sevt.eventdate = nil
            sevt.url = "#"
            sevt.save

            sevt = SrdrEvents.new
            sevt.title = "Train Yourself or Your Students in Data Extraction for Systematic Reviews on SRDR"
            sevt.description = ""
            #sevt.eventdate = nil
            sevt.url = "#"
            sevt.save

            sevt = SrdrEvents.new
            sevt.title = "Get Support from Other SRDR Users in the User Forum"
            sevt.description = "INFO"
            #sevt.eventdate = nil
            sevt.url = "#"
            sevt.save

            # Get default list
            @events_list = SrdrEvents.find(:all, :conditions=>["created_at is not null"], :order=> "eventdate DESC, created_at DESC")
        else
            #puts "------------- loaded SRDR Events total "+@events_list.size().to_s
        end
    end

    def get(idx)
        return @events_list[idx]
    end

    def size
        return @events_list.size()
    end

    def getHTMLTitle(idx)
        if idx < size()
            title = getTitle(idx)
            desc = getDescription(idx)
            title_icon = ""
            if !desc.nil? &&
                desc == "INFO"
                title_icon = "<img src=\"images/Information-silk.png\" border=\"0\">"
            end
            url = getURL(idx);
            url_0 = ""
            url_1 = ""
            if !url.nil? &&
                url_0 = "<a href=\""+url+"\">"
                url_1 = "</a>"
            end
            return title_icon + url_0 + title + url_1
        else
            return nil
        end
    end

    def getTitle(idx)
        if idx < size()
            return @events_list[idx].title
        else
            return nil
        end
    end

    def getHTMLDescription(idx)
        if idx < size()
            desc = getDescription(idx)
            if !desc.nil? &&
                desc == "INFO"
                desc = ""
            end
            return desc
        else
            return nil
        end
    end

    def getDescription(idx)
        if idx < size()
            return @events_list[idx].description
        else
            return nil
        end
    end

    def getURL(idx)
        if idx < size()
            return @events_list[idx].url
        else
            return nil
        end
    end

    def getDate(idx)
        if idx < size()
            return @events_list[idx].eventdate
        else
            return nil
        end
    end

    def getPostDate(idx)
        if idx < size()
            return @events_list[idx].created_at
        else
            return nil
        end
    end
end
