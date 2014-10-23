class OutcomeDetailsConfig < ReportconfigData

    # OutcomeDetailsConfig is a container object encapsulating Outcome Details report builder configuration
    # properly load and serve data requests
    def initialize()
        super()
        # Set class specific initialization
    end
    
    def setConfig(reportsetdata)
        super(reportsetdata)
        # Set the individual record components
        addQuestionDetail("instruction", "Instruction")
    end
end
