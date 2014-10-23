class ArmDetailsConfig < ReportconfigByArmsData

    # ArmDetailsConfig is a container object encapsulating Arm Details report builder configuration
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
