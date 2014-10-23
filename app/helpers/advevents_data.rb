class AdveventsData < SectionByArmsData

    # AdveventsData is a container object encapsulating Adverse Events
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("adverse_events");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("AdvEvents");
        setSectionDescription("Adverse Events");
        setSectionPrefix("ae");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
