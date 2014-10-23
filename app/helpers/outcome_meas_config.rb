class OutcomeMeasConfig < ReportconfigData

    # OutcomeMeasConfig is a container object encapsulating Outcome Measures report builder configuration
    # properly load and serve data requests
    def initialize()
        super()
        # Set class specific initialization
    end
    
    def setConfig(reportsetdata)
        super(reportsetdata)
        # Set the individual record components
        addQuestionDetail("description", "Description")
        addQuestionDetail("note", "Note")
    end
end
