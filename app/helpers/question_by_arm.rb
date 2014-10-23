class QuestionByArm < BaseQuestion

    # QuestionByArm adds support for associating the question to a specific arm
    def intialize
        super()
        @arm = "TOTAL"
        @arm_id = 0
    end
    
    def setArm(n)
        @arm = n
    end
    
    def getArm()
        return @arm
    end
    
    def setArmID(arm_id)
        @arm_id = arm_id
    end
    
    def getArmID()
        return @arm_id
    end
    
    # YAML renderer methods -----------------------------------------------------------------------
    def getYAMLID()
        return getPrefix()+"_"+getID().to_s+"_"+getArmID().to_s
    end
end
