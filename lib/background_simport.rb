require 'import_handler'

class BackgroundSimport
  def import(user_id, project_id, ef_id, section, force, local_file, email)
    # Instantiate Importer object and parse the data.
    ih = RubyXLImport.new(user_id, project_id, ef_id, section, force)
    #ih = RooImport.new(user_id, project_id, ef_id, section, force)
    
    wb = ih.set_workbook(local_file)
    ih.parse_data(wb, ['^k[ey]*[\s_-]*q[uestion]*$', 'author, year', 'pmid'])

    # Validate the workbook.
    if ih.validate_workbook
      ih.add_email_recipient('jens_jap@brown.edu')
      ih.add_email_recipient(email)

      # Set the section options to 0 so that questions show up once only.
      ih.set_ef_section_options(ef_id)

      # Process rows now.
      ih.process_rows
    end

    puts "Import finished."
  end

end