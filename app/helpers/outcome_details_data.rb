class OutcomeDetailsData < SectionData

    # OutcomeDetailsData is a container object encapsulating Outcome Details
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("outcome_details");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("OutcomeDetail");
        setSectionDescription("Outcome Details");
        setSectionPrefix("od");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
