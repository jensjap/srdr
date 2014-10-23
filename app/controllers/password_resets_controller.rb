class PasswordResetsController < ApplicationController
before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
before_filter :require_no_user  
 
 # new
 # create a new password reset
 def new
 end  
   
# create 
# send the user their password reset email
 def create  
 @user = User.find_by_email(params[:email])  
	 if @user  
	 @user.deliver_password_reset_instructions!  
	 flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
	 "Please check your email."
	 redirect_to "/login"
	 else  
	 flash[:error_message] = "No user was found with that email address."  
	 redirect_to "/login"
	 end  
 end  

# edit
# show the user a password reset screen
 def edit
 end
 
  # update
 # save the user's new password
 def update  
 @user.password = params[:user][:password]  
 @user.password_confirmation = params[:user][:password_confirmation] 
	 if !@user.password.nil? && @user.password != "" && @user.save  
	 flash[:success_message] = "Password successfully updated!"  
	 redirect_to account_url  
	 else 
	 flash[:error_message] = "There was a problem updating your password. Please make sure they match and neither field is left blank."
	 render :action => :edit
	 end  
 end  
 

 # load_user_using_perishable_token
 # load the user's info using the perishable token sent to them via password reset email
 private 
 def load_user_using_perishable_token  
 @user = User.find_using_perishable_token(params[:id]) 
	if flash.length > 0
		flash.each do |key, value|
			flash.delete(key)
		end
	end
	 unless @user  
	 flash[:notice] = "We're sorry, but we could not locate your account. " +  
	 "If you are having issues try copying and pasting the URL " +  
	 "from your email into your browser or restarting the " +  
	 "reset password process."  
	 redirect_to root_url
	 end 
end
 
end
