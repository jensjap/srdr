class DesignDetailsData < SectionData

    # DesignDetailsData is a container object encapsulating Design Details
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("design_details");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("DesignDetail");
        setSectionDescription("Design Details");
        setSectionPrefix("dd");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
