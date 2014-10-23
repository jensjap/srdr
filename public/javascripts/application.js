$(document).ready(function() {
version = getInternetExplorerVersion();

// ADD IN HANDLING FOR OLDER BROWSERS HERE
if(version == -1 || version >= 7.0){

    // Find instance of forms in the page and for any of them other than the search box,
    // attach a listener to update a flag when the form is edited without being saved.
    $(".editable_field").on('change', function() {
        $(this).addClass('edited_field');
    });

	// update button text on form submit ("processing...")
	  $('.a_form')
	    .bind("ajax:loading", function(){
	      var $submitButton = $(this).find('input[name="commit"]');

	      // Update the text of the submit button to let the user know stuff is happening.
	      // But first, store the original text of the submit button, so it can be restored when the request is finished.
	      $submitButton.data( 'origText', $(this).text() );
	      $submitButton.text( "Submitting..." );

	    })
	    .bind("ajax:success", function(evt, data, status, xhr){
	      var $form = $(this);

	      // Reset fields and any validation errors, so form can be used again, but leave hidden_field values intact.
	      $form.find('textarea,input[type="text"],input[type="file"]').val("");
	      $form.find('div.validation-error').empty();

	      // Insert response partial into page below the form.
	      $('#comments').append(xhr.responseText);

	    })
	    .bind('ajax:complete', function(){
	      var $submitButton = $(this).find('input[name="commit"]');
	      // Restore the original submit button text
	      $submitButton.text( $(this).data('origText') );
	      $submitButton.attr("disabled", "false");
	    })
	    .bind("ajax:failure", function(evt, xhr, status, error){
	      var $form = $(this),
	          errors,
	          errorText;

	      try {
	        // Populate errorText with the comment errors
	        errors = $.parseJSON(xhr.responseText);
	      } catch(err) {
	        // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
	        errors = {message: "Please reload the page and try again"};
	      }

	      // Build an unordered list from the list of errors
	      errorText = "There were errors with the submission: \n<ul>";

	      for ( error in errors ) {
	        errorText += "<li>" + error + ': ' + errors[error] + "</li> ";
	      }

	      errorText += "</ul>";

	      // Insert error list into form
	      $form.find('div.validation-error').html(errorText);
	    });

		// -------------------------------------------------- end of validation alerts ----------


	$("#template_example_section :input").attr("disabled","disabled");

		// ---------------------------------------- used for editing/saving/deleting outcome measures ------
			/*
	$("img.edit_measure_btn").live("click", function(){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[2];
			$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'POST',
		  url: "outcome_measures/" + item_id + "/edit",
		  data: ({
				measure_id: item_id
		  })
		});
	});

	$("img.delete_measure_btn").live("click", function(){
		if (confirm("Are you sure?")){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[2];
		$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'DELETE',
		  url: "outcome_measures/" + item_id + "/destroy",
		  data: ({
				measure_id: item_id
		  })
		});
	}
	});

	$("form.edit_outcome_measure").submit(function(e){
		e.preventDefault();
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[3];
		var measure_val = $("#tabs #tabs-2 #edit_measures_list #outcome_measure_name_" + item_id).text();
		var unit_val = $("#tabs #tabs-2 #edit_measures_list #outcome_measure_unit_" + item_id).text();
		$.ajax({
		  type: 'POST',
		  url: "outcome_measures/" + item_id + "/save",
		  data: ({
				measure_id: item_id,
				measure_name: measure_val,
				unit: unit_val
		  })
		});
	});

	$("img.cancel_measure_btn").live("click", function(){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[2];
		$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'POST',
		  url: "outcome_measures/" + item_id + "/cancel",
		  data: ({
				measure_id: item_id
		  })
		});
	});
	*/
		// ---------------------------------------- used for editing/saving/deleting outcome timepoints ------

	$("img.edit_tp_btn").live("click", function(){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[2];
			$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'POST',
		  url: "outcome_timepoints/" + item_id + "/edit",
		  data: ({
				tp_id: item_id
		  })
		});
	});

	$("img.delete_tp_btn").live("click", function(){
		if (confirm("Are you sure?")){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[2];
		$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'DELETE',
		  url: "outcome_timepoints/" + item_id + "/destroy_modal",
		  data: ({
				tp_id: item_id
		  })
		});
	}
	});

	$('img.save_tp_btn').live("click", function(e){
		e.preventDefault();
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[3];
		var measure_val = $("#edit_tp_list #outcome_tp_num_" + item_id).val();
		var unit_val = $("#edit_tp_list #outcome_tp_unit_" + item_id).val();
		$.ajax({
		  type: 'POST',
		  url: "outcome_timepoints/" + item_id + "/save",
		  data: ({
				tp_id: item_id,
				tp_num: measure_val,
				tp_unit: unit_val
		  })
		});
	});

	$("img.cancel_tp_btn").live("click", function(){
		var div_id = $(this).attr("id");
		var div_id_arr = div_id.split("_");
		var item_id = div_id_arr[3];
		$(this).attr("src", "/images/waiting.gif");
		$.ajax({
		  type: 'POST',
		  url: "outcome_timepoints/" + item_id + "/cancel",
		  data: ({
				tp_id: item_id
		  })
		});
	});

	// ----------------------------------------------- popup previews

	$("#view_preview_btn").live("click", function(e){
		e.preventDefault();
		$( "#preview_div" ).dialog( "open" );
	});

	// ----------------------------------------------- feedback dialog
	$(".feedback_link").unbind("click");
	$(".feedback_link").bind("click", function(event)
	{
	  event.preventDefault();
	  $("#feedback_form").dialog({
			modal:true,
			position: 'center',
			minWidth: 650,
			title: "Send Us Feedback"

		  });

		$("#feedback_form #feedback-form-select").unbind("change");
		$("#feedback_form #feedback-form-select").bind("change",function(event) {
			$.ajax(
			{
				url: "/application/show_other",
				data: {
					"field_id":this.id,
					"field_name":this.name,
					"selected":this.value
				}
			});
		});

	});
	// --------- HORIZONTAL NAVIGATION ELEMENTS ----------------
	// GIVE IT AN ON-CLICK HANDLER
	$(".horizontal-nav-link").unbind("click");
	$(".horizontal-nav-link").bind("click", function(event){
		event.preventDefault();
		$(".horizontal-nav-link").removeClass("current");
		$(this).addClass("current");
		window.location = ($(this).attr("href"));
	});
	// GIVE IT AN ENTER-KEY PRESS HANDLER
	$(".horizontal-nav-link").unbind("keypress");
	$(".horizontal-nav-link").bind("keypress", function(event){
		event.preventDefault();
		if(event.which == 13){
			$(".horizontal-nav-link").removeClass("current");
			$(this).addClass("current");
			window.location = ($(this).attr("href"));
		}
	});
	// on click of studies/extractionforms.html.erb button
	$("#submit_extraction_form_to_study").live("click", function(event)
	{
		event.preventDefault();
		var project_id = $("#study_extraction_form_project_id").val();
		var ext_form_id = $("#study_extraction_form_extraction_form_id").val();
		var notes = $("#study_extraction_form_notes").val();
		var extforms = $("#ext_form_arr").val();
		var extnotes = $("#notes_arr").val();

		$.ajax({
		  type: 'POST',
		  url: "extraction_form_add",
		  data: ({
				project_id: project_id,
				notes: notes,
				ext_form_id: ext_form_id,
				ext_forms_list: extforms,
				ext_form_notes: extnotes
		  })
		});

	});

	$("#outcome_title").unbind("change");
	$("#outcome_title").live("change", function ()
	{
		name = $(this).attr("name");
		id = $(this).attr("id");
		value = $(this).val();

		$.ajax({
		  type: 'POST',
		  url: "outcomesetup/show_other",
		  data: ({
				field_name: name,
				field_id: id,
				selected: value
		  })
		});
	});

  }

    // You can wrap something with a div class of 'more'. If the content of this div exceeds 300 it
    // will be spliced and replaced with an href with the words 'less'. You can then toggle the
    // additional content by clicking 'less' or 'more'
    var showChar = 300;
    var ellipsestext = "...";
    var moretext = "more";
    var lesstext = "less";
    $('.more').each(function() {
        var content = $(this).html();

        if(content.length > showChar) {

            var c = content.substr(0, showChar);
            var h = content.substr(showChar-1, content.length - showChar);

            var html = c + '<span class="moreellipses">' + ellipsestext+ '&nbsp;</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>';

            $(this).html(html);
        }
    });

    $(".morelink").click(function(){
        if($(this).hasClass("less")) {
            $(this).removeClass("less");
            $(this).html(moretext);
        } else {
            $(this).addClass("less");
            $(this).html(lesstext);
        }
        $(this).parent().prev().toggle();
        $(this).prev().toggle();
        return false;
    });

    // Alert the user if there is potential data loss
    // We are looking for elements that have a class of 'edited_field' or
    // 'unsaved_form' and prevent unloading of the page.
    //
    function CheckEditedFields() {
        var edited = $('.edited_field');
        var form = $('.unsaved_form');

        if (edited.length != 0 || form.length != 0) {
            return 'Warning: Uncommitted data detected. Please confirm.';
        }
    };

    window.onbeforeunload = CheckEditedFields;
});


// ----------------------------------------------- end Document.ready



// call this when the anticipated value is not contained in the dropdown menu
// set the field value to "Other", create the text box, and set its value to the anticipated value
// currently used in secondary_publications/form.html.erb
function setup_other_field(value, elem_id){

	$('#' + elem_id).val("Other");
	$('<input/>', {
					'name' : $('#' + elem_id).attr('name'),
					'class' : 'inline-field',
					'style' : 'margin-left: 5px;',
					'value' : value,
					'size' : 12,
					'id': $('#' + elem_id).attr("id") + "_other"
				}).insertAfter($('#' + elem_id));
				$('#' + elem_id).attr('name', '');
		$.ajaxSetup({
			'beforeSend': function(xhr) {
				xhr.setRequestHeader("Accept", "text/javascript")
			}
		})
}

// call with an onchange event from any dropdown field that has the custom "other"
// currently used in comments/flag_form.html.erb and secondary_publications/form.html.erb
// doublecheck this.
function has_other_field(elem_id){
			elem_name_other = $("#" + elem_id + "_other").attr('name');
			elem_name_dropdown = $("#" + elem_id).attr('name');
			if ((elem_name_dropdown == null) || (elem_name_dropdown == undefined) || (elem_name_dropdown == ""))
			{
				elem_name = elem_name_other;
			}
			else
			{
				elem_name = elem_name_dropdown;
			}

			if ($("#" + elem_id).val() == 'Other') {
				$('<input/>', {
					'name' : elem_name,
					'class' : 'inline-field',
					'style' : 'margin-left: 5px;',
					'id': elem_id + "_other"
				}).insertAfter($("#" + elem_id));
				$("#" + elem_id).attr('name', '');
			} else {
			$("#" + elem_id + "_other").remove();
            $("#" + elem_id).attr('name', elem_name);
			}

}

// string function to test in javascript if string str ends in suffix
// used in extraction_forms/edit.js.erb
function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

// used in extraction_forms/edit.js.erb
function testToRedirect(str, suffix)
{
	window.location.href=suffix;
	return;
}

// feedback button js
// Get the wrapper div, and the contained &lt;a&gt; element
var feedback_btn = $("#feedback");
var feedback_link = $("#feedback a")[0];

// Check for browsers that don't support CSS3 transforms or IE's filters
if($("#feedback").css("Transform") == undefined && $("#feedback").css("WebkitTransform") == undefined && $("#feedback").css("MozTransform") == undefined && $("#feedback").css("OTransform") == undefined) {

	// Swap width with height, change padding
	$("#feedback a").css("width", "15px");
	$("#feedback a").css("height", "70px");
	$("#feedback").css("padding", "16px 8px");

	// Insert vertical SVG text
	$("#feedback a").html("<object type='image/svg+xml' data='../feedback_vertical.svg'></object>");
}

function create_tabs(){
	$("#tabs").tabs();
}

function update_url(currentURL, newURL){
	var stateObj = { foo: currentURL };
	history.pushState(stateObj, "page 2", newURL);
}
