class AdveventsConfig < ReportconfigByArmsData

    # AdveventsConfig is a container object encapsulating Adverse Events report builder configuration
    # properly load and serve data requests
    def initialize()
        super()
        # Set class specific initialization
    end
    
    def setConfig(reportsetdata)
        super(reportsetdata)
        # Set the individual record components
        addQuestionDetail("description", "Description")
    end
end
