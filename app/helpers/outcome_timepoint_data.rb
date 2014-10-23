class OutcomeTimepointData < SectionData

    # OutcomeTimepointData is a container object encapsulating Outcome Timepoints
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("outcome_timepoint");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("OutcomeTimepoint");
        setSectionDescription("Outcome Timepoints");
        setSectionPrefix("ot");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
