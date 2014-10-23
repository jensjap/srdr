class ArmDetailsData < SectionByArmsData

    # ArmDetailData is a container object encapsulating Arm Details
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("arm_details");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("ArmDetail");
        setSectionDescription("Arm Details");
        setSectionPrefix("ad");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
