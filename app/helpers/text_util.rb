module TextUtil
    # This helper class provides methods to process and manipulate text 
    # utility helper class
    
    # Methods for encoding special chacters in free text and labels that otherwise would cause problems in the database or exporting to YML files
    def self.restoreCodedText(s)
        if s.nil?
            return ""
        end
        strv = s.to_s;
        strv.gsub!("-x3a-",":")
        strv.gsub!("-x27-","\'")
        strv.gsub!("-x22-","\"")
        return strv
    end
    
    def self.restoreCodedList(l)
        rl = Array.new
        if l.nil? ||
            l.size() == 0
            return rl
        end
        
        l.each do |lv|
            rl << restoreCodedText(lv)
        end
        return rl
    end
end
