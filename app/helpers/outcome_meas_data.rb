class OutcomeMeasData < SectionData

    # OutcomeMeasData is a container object encapsulating Outcome Measures
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("outcome_measures");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("OutcomeMeas");
        setSectionDescription("Outcome Measures");
        setSectionPrefix("om");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
