class BaseQuestion

    # BaseQuestion represents the parent class from which simple, row, and matrix questions are derived.
    def intialize
        @name = "DEFAULT"
        @id = -1
        @prefix = ""
        @description = ""
        # By default - 
        @value = "-"
        @type = "SINGLE"
    end
    
    def setName(n)
        @name = n
    end
    
    def getName()
        return @name
    end
    
    def setID(id)
        @id = id
    end
    
    def getID()
        return @id
    end
    
    def setPrefix(p)
        @prefix = p
    end
    
    def getPrefix()
        return @prefix
    end
    
    def setDescription(d)
        @description = d
    end
    
    def getDescription()
        return @description
    end
    
    def setValue(v)
        @value = v
    end
    
    def getValue()
        return @value
    end
    
    def setQuestion(id,n,v)
        setID(id)
        setName(n)    
        setValue(v)
    end
    
    def loadQuestion(id,n,prefix,data)
        # Child class implements this method
    end
    
    def isSingleValue()
        return @type.eql?("SINGLE")
    end
    
    def isRowValue()
        return @type.eql?("ROW")
    end
    
    def isMatrixValue()
        return @type.eql?("MATRIX")
    end
    
    # YAML renderer methods -----------------------------------------------------------------------
    def getYAMLID()
        return getPrefix()+"_"+getID().to_s
    end
    
    # HTML renderer methods -----------------------------------------------------------------------
    def renderHTMLValue()
        return getValue()
    end
    
    def renderHTMLTableCell()
        return "<td>"+renderHTMLValue()+"</td>"
    end
    
    def renderHTMLTableCellAsClass(cname)
        return "<td class=\""+cname+"\">"+renderHTMLValue()+"</td>"
    end
end
