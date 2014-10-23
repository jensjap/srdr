# this controller handles deletion of feedback items. this can only be done by the administrator on the feedback items page.
class FeedbackItemsController < ApplicationController
	
	# delete feedback item, only accessible by admin
	def destroy
		item = FeedbackItem.find(params[:id])	
		item.destroy
		redirect_to :back 
	end
end