class QualityConfig < ReportconfigData

    # QualityConfig is a container object encapsulating Quality Dimensions report builder configuration
    # properly load and serve data requests
    def initialize()
        super()
        # Set class specific initialization
    end
    
    def setConfig(reportsetdata)
        super(reportsetdata)
        # Set the individual record components
        addQuestionDetail("note", "Field Notes")
    end
end
