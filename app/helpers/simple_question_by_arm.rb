class SimpleQuestionByArm < QuestionByArm

    # SimpleQuestionByArm represents a single value question - association to a particular arm
    def intialize
        super()
    end
    
    # HTML renderer methods -----------------------------------------------------------------------
    def renderHTMLValueByArm()
        return getValue()
    end
    
    def renderHTMLTableCell()
        return "<td>"+renderHTMLValue()+"</td>"
    end
    
    def renderHTMLTableCellAsClass(cname)
        return "<td class=\""+cname+"\">"+renderHTMLValue()+"</td>"
    end
end
