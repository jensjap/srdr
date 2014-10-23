class ArmsData < SectionData

    # ArmDetailData is a container object encapsulating Arm Details
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("arms");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("Arms");
        setSectionDescription("Arms");
        setSectionPrefix("am");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
