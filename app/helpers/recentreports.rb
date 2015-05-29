class Recentreports

    # Recentreports is implemented as simple Array of Project records selected by most viewed metric
    # for a given study id and extraction form id
    def initialize
        siteproperties = Guiproperties.new
        # TODO - add constraints last 12 months or last 10 or by site...
        if siteproperties.isMySQL()
            @recent_projects = Project.find(:all, :conditions=>["is_public = 1"], :order=> "updated_at DESC")
        else
            @recent_projects = Project.find(:all, :conditions=>["is_public = 't'"], :order=> "updated_at DESC")
        end
    end
    
    def get(idx)
        return @recent_projects[idx]    
    end
    
    def size
        return @recent_projects.size()    
    end
    
    def getTitle(idx)
        if idx < size()
            return @recent_projects[idx].title
        else
            return nil
        end
    end
    
    def getDescription(idx)
        if idx < size()
            return @recent_projects[idx].description
        else
            return nil
        end
    end
    
    def getDate(idx)
        if idx < size()
            return @recent_projects[idx].created_at
        else
            return nil
        end
    end
    
    def isPublic(idx)
        if idx < size()
            return @recent_projects[idx].is_public
        else
            return false
        end
    end
    
    def getNumStudies(idx)
        if idx < size()
            return Project.get_num_studies(@recent_projects[idx])
        else
            return 0
        end
    end
    
    def getNumKeyQuestions(idx)
        if idx < size()
            return Project.get_num_key_qs(@recent_projects[idx])
        else
            return 0
        end
    end
    
    def getNumExtractionForms(idx)
        if idx < size()
            return Project.get_num_ext_forms(@recent_projects[idx])
        else
            return nil
        end
    end
end
