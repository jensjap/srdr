class OutcomeSubgroupData < SectionData

    # OutcomeSubgroupData is a container object encapsulating Outcome Subgroups
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("outcome_subgroup");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("OutcomeSubgroup");
        setSectionDescription("Outcome Subgroups");
        setSectionPrefix("os");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
