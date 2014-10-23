class FilterController < ApplicationController

    # index
    # display search page
    def index
    end
  	
    # capture filter data
    def filter
        @filtername = ""
        @filtername = params[:filtername]
        @filtervalue = ""
        @filtervalue = params[:filtervalue]
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>> filter ------------- "
    end
end
