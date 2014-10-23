class ReportsetByArmData < ReportsetData

    # ReportsetByArmData extends the base class and adds By Arm methods - assumes the sectiondata is class SectionByArmData
    
    def initialize
        super()
    end
        
    # SectionData access methods ------------------------------------------------------------------------
    def isQuestionComplexByArm(sidx,arm_id,q_id)
        return @dataset[sidx].isQuestionComplexByArm(arm_id,q_id)
    end
    
    def getQuestionRowNamesByArmByID(sidx,arm_id,q_id)
        return @dataset[sidx].getQuestionRowNamesByArmByID(arm_id,q_id)
    end
    
    def getQuestionColNamesByArmByID(sidx,arm_id,q_id)
        return @dataset[sidx].getQuestionColNamesByArmByID(arm_id,q_id)
    end
    
    def getQuestionValueByArm(idx,arm_id,q_id)
        return @dataset[idx].getQuestionValueByArm(arm_id,q_id)
    end
    
    def getQuestionMatrixValueByArm(sidx,arm_id,q_id,row_idx,col_idx)
        return @dataset[sidx].getQuestionMatrixValueByArm(arm_id,q_id,row_idx,col_idx)
    end
    
    # Question EXCEL Methods ------------------------------------------------------------------------
    def getQuestionEXCELSpanByArm(arm_id,q_name)
        col_span = 0
        for sidx in 0..size() - 1
            study_colspan = @dataset[sidx].getQuestionColSpanByArm(arm_id,q_name)
            if study_colspan > col_span
                col_span = study_colspan
            end
        end
        return col_span
    end
    
    def getQuestionEXCELLabelsByArm(arm_id,q_name)
        # All studies have the same set of Question labels for the same question
        return @dataset[0].getQuestionEXCELLabelsByArm(arm_id,q_name)
    end
    
    def getQuestionEXCELValuesByArm(sidx,arm_id,q_name)
        return @dataset[sidx].getDesignDetailEXCELValuesByArm(arm_id,q_name)
    end
end
