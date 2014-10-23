 /* user_feedback.js */

// ----------------------------------------------- message system for success, error
// msg_type = 'success' or 'error'
// msg_title = the title that will show up in bold
// msg_description = the actual message to provide
function show_message(msg_type, msg_title, msg_description){
	
	$("#message_div").html("<strong>"+msg_title+"</strong><br/><br/>"+msg_description+"<br/><br/>");
	if(msg_type == "error"){
	  $("#message_div").dialog({
	  	autoOpen: false,
	  	buttons: { "Ok": function() { $(this).dialog("close"); } },
	  	closeOnEscape: true, 
	  	draggable: false,
	  	modal: true,
	  	title: "Action Required"
	  });
	  $("#message_div").dialog("open");
	}else if(msg_type == 'success'){
		$("#message_div").dialog({
		  	autoOpen: false,
		  	closeOnEscape: true, 
		  	draggable: false,
		  	modal: true,
		  	title: ""
		});
	    $("#message_div").dialog("open")
	    setTimeout(function(){$('#message_div').dialog("close")}, 1500);
	   
	}
}