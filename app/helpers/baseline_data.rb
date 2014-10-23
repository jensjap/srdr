class BaselineData < SectionByArmsData

    # BaselineData is a container object encapsulating Baseline Characteristics
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("baseline");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("Baseline");
        setSectionDescription("Baseline Characteristics");
        setSectionPrefix("bl");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
