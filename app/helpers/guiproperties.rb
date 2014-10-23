class Guiproperties
   
    # Helper class to access GUI and Site properties
    def initialize
        @gproperties = YAML.load_file("properties/gui.properties")
    end

    # Base data access method -------------------------------------------------
    def getData(id, subid)
        if @gproperties[id].nil?
            return ""
        end
        if @gproperties[id][subid].nil?
            return ""
        end
        return @gproperties[id][subid]
    end

    # Site Properties ---------------------------------------------------------
    def getSiteData(name)
        return getData("site-info",name)
    end

    def getSiteName()
        return getSiteData("name")
    end

    def getSiteDescription()
        return getSiteData("description")
    end

    def getSiteURL()
        return getSiteData("url")
    end

    def getSiteIP()
        return getSiteData("ip")
    end

    def getSiteType()
        return getSiteData("type")
    end

    def isSiteTypeProduction()
        return (getSiteType() == "production")
    end

    # Training Site Properties ------------------------------------------------
    def getTrainingSiteData(name)
        return getData("training-site",name)
    end

    def getTrainingSiteName()
        return getTrainingSiteData("name")
    end

    def getTrainingSiteDescription()
        return getTrainingSiteData("description")
    end

    def getTrainingSiteURL()
        return getTrainingSiteData("url")
    end

    def getTrainingSiteIP()
        return getTrainingSiteData("ip")
    end

    # Database Info Properties ------------------------------------------------
    def getDbData(name)
        return getData("database-info",name)
    end

    def getDbName()
        return getDbData("name")
    end

    def isMySQL()
        return (getDbData("name") == "MYSQL")
    end

    def isDefault()
        dbname = getDbData("name")
        return (dbname.nil?) || (dbname == "DEFAULT") || (dbname == "SQLITE3")
    end

    def getDbDescription()
        return getDbData("description")
    end

    def getDbURL()
        return getDbData("url")
    end

    def getDBIP()
        return getDbData("ip")
    end

    def getDBType()
        return getDbData("type")
    end

    def isDBTypeProduction()
        return (getDBType() == "production")
    end

    def isDBTypeDevelopment()
        return (getDBType() == "development")
    end

    # Registar Properties -----------------------------------------------------
    def getRegistarData(name)
        return getData("registar-notification",name)
    end

    def getRegistarNotificationName()
        return getRegistarData("name")
    end

    def getRegistarNotificationOrganization()
        return getRegistarData("organization")
    end

    def getRegistarNotificationEmail()
        return getRegistarData("email")
    end

    # Public Commentator Properties -------------------------------------------
    def getCommentsData(name)
        return getData("comments-notification",name)
    end

    def getCommentsNotificationName()
        return getCommentsData("name")
    end

    def getCommentsNotificationOrganization()
        return getCommentsData("organization")
    end

    def getCommentsNotificationEmail()
        return getCommentsData("email")
    end

    # Admin on SRDR-DEV Properties --------------------------------------------
    # Special properties only used on SRDR-Dev to enable functions that
    # otherwise would be handled on SRDR-Admin
    def getDevAdminData(name)
        return getData("user-admin-dev",name)
    end

    def getDevAdminActivation()
        return getDevAdminData("activation") == 1
    end

    def getDevAdminActivationValue()
        return getDevAdminData("activation")
    end

    # Cache Properties --------------------------------------------------------
    def getProjectCachePath()
        return @gproperties["cache-project-path"]
    end

    # Uploaded Files Properties --------------------------------------------------------
    def getUploadedFilesPath()
        return @gproperties["uploaded-files-path"]
    end

    # Notifications Properties ------------------------------------------------
    def isSiteNotificationOutage()
        return isSiteNoticeType("OUTAGE")
    end

    def isSiteNotificationWarning()
        return isSiteNoticeType("WARNING")
    end

    def isSiteNotificationNormal()
        return isSiteNoticeType("NOTICE")
    end

    def isSiteNoticeType(type)
        notetype = getData("site-notifications","notice_type")
        return notetype.eql?(type)
    end

    def getSiteNotificationMessage()
        return getData("site-notifications","message")
    end

    def getSiteNotificationStartDateTime()
        return getData("site-notifications","message")
    end

    # Report Builder Properties -----------------------------------------------
    def getReportBuilderURL()
        return getData("report-builder","url")
    end

    def isReportBuilderURLLocal()
        rb_url = getReportBuilderURL()
        if rb_url.nil? ||
           (rb_url.size() == 0)
            return true
        end;
        return rb_url.eql?("LOCAL")
    end
    # SRDRJ Properties ---------------------------------------------
    def getSRDRJURL()
        return getData("srdrj","url")
    end
    
    # Registry Properties ---------------------------------------------
    def getRegistryURL()
        return getData("registry","url")
    end
    
    # Data Comparison Properties ---------------------------------------------
    def getDataComparisonURL()
        return getData("comparison","url")
    end
    
    # Base data access method ---------------------------------------------------------------------------------------
    def getData(id, subid)
        if @gproperties[id].nil?
            return ""
        end
        if @gproperties[id][subid].nil?
            return ""
        end
        return @gproperties[id][subid]
    end
end
