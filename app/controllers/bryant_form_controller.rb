class BryantFormController < ApplicationController
    layout "bryant_form_layout"

    def form
    end

    def save
        pp params
    end
end
