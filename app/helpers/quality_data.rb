class QualityData < SectionData

    # QualityData is a container object encapsulating Quality Dimensions
    # properly load and serve data requests
    def initialize()
        super()
        setSectionID("quality");
        # Set default name and prefix - this is also provided in the cached YAML file meta section
        setSectionName("QualityDimensions");
        setSectionDescription("Quality Dimensions");
        setSectionPrefix("qd");
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
end
