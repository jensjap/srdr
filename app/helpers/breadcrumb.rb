class Breadcrumb

    # BreadCrumb is implemented as a simple Array with convience methods to push, pop, and nab URL and description
    # Each entry is a '|' delimited record of <Name>|<Description>|<URL>
    # The stack is implemented as a simple array by the instance variable @breadcrumb
    # Private method initialize - called by new will create an empty array
    def initialize
        @breadcrumb = []
    end

    def push(name,desc,url)
        @breadcrumb.push name+"|"+desc+"|"+url
    end

    def pop
        @breadcrumb.pop
    end

    # Top of stack evaluation methods
    def lookName
        crumbs = @breadcrumb.last.split("|")
        return crumbs[0]
    end

    def lookDescription
        crumbs = @breadcrumb.last.split("|")
        return crumbs[1]
    end

    def lookURL
        crumbs = @breadcrumb.last.split("|")
        return crumbs[2]
    end

    def size
        return @breadcrumb.size
    end

    def getDescriptionList
        descs = Array.new
        for i in (0..@breadcrumb.size - 1)
            crumbs = @breadcrumb[i].split("|")
            descs << crumbs[1]
        end
        return descs
    end

    def getURLList
        urls = Array.new
        for i in (0..@breadcrumb.size - 1)
            crumbs = @breadcrumb[i].split("|")
            urls << crumbs[2]
        end
        return urls
    end

    def setCurrentPage(name,desc,url)
        # Iterate through the stack and see if the page has already been visited, then pop up to the that location. Otherwise add the current location
        # to the stack
        #puts "----------- breadcrumb::setCurrentPage("+name+","+desc+","+url+") current size "+@breadcrumb.size.to_s
        if @breadcrumb.size == 0
            push(name,desc,url)
        else
            #puts "----------- breadcrumb::setCurrentPage - check current stack for url "+url
            page_loc = -1
            for i in (0..@breadcrumb.size - 1)
                crumbs = @breadcrumb[i].split("|")
                #puts "-----xxx- breadcrumb::setCurrentPage - check current stack for url "+url+" stackv["+i.to_s+"] "+crumbs[2]
                if crumbs[2] == url
                    #puts "-----xxx- breadcrumb::setCurrentPage - found match at i "+i.to_s
                    page_loc = i
                    break
                end
            end
            if page_loc >= 0
                #puts "-----xxx- breadcrumb::setCurrentPage - pop stack("+@breadcrumb.size.to_s+" to "+page_loc.to_s
                # url already in the stack - pop off everything after
                while (@breadcrumb.size > (page_loc + 1)) &&
                      (@breadcrumb.size > 0)
                    pop
                end
                #puts "-----xxx- breadcrumb::setCurrentPage - stack now size "+@breadcrumb.size.to_s
            else
                # url was not found in the stack - add it
                #puts "-----xxx- breadcrumb::setCurrentPage - url does not yet exist in stack, just push"
                push(name,desc,url)
                #puts "-----xxx- breadcrumb::setCurrentPage - stack now size "+@breadcrumb.size.to_s
            end
        end
    end
end
