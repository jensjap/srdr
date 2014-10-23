class EfInstructionsController < ApplicationController
  # GET /ef_instructions
  # GET /ef_instructions.xml
  def index
    puts "============ ef_instructions_controller::index"
    @ef_instructions = EfInstruction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ef_instructions }
    end
  end

  # GET /ef_instructions/1
  # GET /ef_instructions/1.xml
  def show
    @ef_instruction = EfInstruction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ef_instruction }
    end
  end

  # GET /ef_instructions/new
  # GET /ef_instructions/new.xml
  def new
    @ef_instruction = EfInstruction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ef_instruction }
    end
  end

  # GET /ef_instructions/1/edit
  def edit
    @ef_instruction = EfInstruction.find(params[:id])
  end

  # POST /ef_instructions
  # POST /ef_instructions.xml
  def create
	efid = params[:extraction_form_id]
	sectionv = params[:section]
	data_elementv = params[:data_element]
    @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", efid, sectionv, data_elementv])
    if @ef_instruction.nil?
        @ef_instruction = EfInstruction.new(params[:ef_instruction])
        @ef_instruction.ef_id = efid
        @ef_instruction.section = sectionv
        @ef_instruction.data_element = data_elementv
    else
        @ef_instruction.instructions = params[:ef_instruction]["instructions"]
    end
    
    if @ef_instruction.save
        puts "================== ef_instructions_controller::create close_winder - "+"new_"+sectionv.downcase+"_instr_entry"
		@close_window = "new_"+sectionv.downcase+"_instr_entry"
    else
		problem_html = create_error_message_html(@extraction_form_arm.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
    end
    # @ef_user_instructions is used to pass instructions to the various EF sections
    @ef_user_instructions = @ef_instruction.instructions
    # @table_container must be unique to locate which DIV instructions to update, render the @table_partial
	@table_container = sectionv.downcase+"_user_instructions"
	@table_partial = "extraction_forms/instructions"
    render "shared/saved.js.erb"
  end

  # PUT /ef_instructions/1
  # PUT /ef_instructions/1.xml
  def update
	efid = params[:extraction_form_id]
	sectionv = params[:section]
	data_elementv = params[:data_element]
    @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", efid, sectionv, data_elementv])
    if @ef_instruction.nil?
        @ef_instruction = EfInstruction.new(params[:ef_instruction])
        @ef_instruction.ef_id = efid
        @ef_instruction.section = sectionv
        @ef_instruction.data_element = data_elementv
    else
        @ef_instruction.instructions = params[:ef_instruction]["instructions"]
    end
    
    if @ef_instruction.save
        puts "================== ef_instructions_controller::update close_winder - "+"new_"+sectionv.downcase+"_instr_entry"
		@close_window = "new_"+sectionv.downcase+"_instr_entry"
    else
		problem_html = create_error_message_html(@extraction_form_arm.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
    end
    # @ef_user_instructions is used to pass instructions to the various EF sections
    @ef_user_instructions = @ef_instruction.instructions
    # @table_container must be unique to locate which DIV instructions to update, render the @table_partial
	@table_container = sectionv.downcase+"_user_instructions"
	@table_partial = "extraction_forms/instructions"
    render "shared/saved.js.erb"
  end

  # DELETE /ef_instructions/1
  # DELETE /ef_instructions/1.xml
  def destroy
    @ef_instruction = EfInstruction.find(params[:id])
    @ef_instruction.destroy

    respond_to do |format|
      format.html { redirect_to(ef_instructions_url) }
      format.xml  { head :ok }
    end
  end
end
