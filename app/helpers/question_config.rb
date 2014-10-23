class QuestionConfig

    # QuestionConfig stores information regarding how a Question is to be managed and displayed in reports
    def initialize
        @id = nil
        @name = nil
        @description = nil
        @show = false
    end
    
    # Data access setter/getter methods
    def setID(i)
        @id = i
    end
    
    def getID()
        return(@id)
    end
    
    def setName(n)
        @name = n
    end
    
    def getName()
        return(@name)
    end
    
    def setDescription(d)
        @description = d
    end
    
    def getDescription()
        return(@description)
    end
    
    def show()
        @show = true
    end
    
    def hide()
        @show = false
    end
    
    def isVisible()
        return @show
    end
    
    # Complete setter method
    def set(i,n,d,s)
        setID(i)
        setName(n)
        setDescription(d)
        if s
            show()
        else
            hide()
        end
    end
    
    def toYAML()
        return "\""+getID()+"\", \""+getName()+"\", \""+getDescription()+"\", \""+isVisible().to_s+"\""
    end
    
    def loadYAML(ymldata)
        setID(ymldata[0])
        setName(ymldata[1])
        setDescription(ymldata[2])
        if ymldata[2] == "true"
            show()
        else
            hide()
        end
    end
end
