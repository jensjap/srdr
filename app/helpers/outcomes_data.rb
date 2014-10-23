class OutcomesData < SectionData

    # OutcomesData is a container object encapsulating Outcomes
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("outcomes");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("Outcomes");
        setSectionDescription("Outcomes");
        setSectionPrefix("ou");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
