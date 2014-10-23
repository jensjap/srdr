class DesignDetailsConfig < ReportconfigData

    # DesignDetailsConfig is a container object encapsulating Design Details report builder configuration
    # properly load and serve data requests
    def initialize()
        super()
        # Set class specific initialization
    end
    
    def setConfig(reportsetdata)
        super(reportsetdata)
        # Set the individual record components
        addQuestionDetail("instructions", "Instructions")
    end       
end
