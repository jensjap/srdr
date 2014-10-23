$(document).ready(function()
{
   $('.open_comments_link').bind("click", function(event) {
      var self = $(this);
      var qtip = '.qtip.ui-tooltip';
   
      // Create the tooltip
      self.qtip({
         overwrite: false,
		id: $(this).attr('id'),
				 position:{
		 my: 'top right', at: 'bottom center'
		 },
         content: {
			title: {
                  text: 'Item Comments',
                  button: true
			},
			text: "Loading...",
			ajax: {
				url: 'get_comment_content', 
				type: 'POST',
				data: {
					div_id: $(this).attr('id')
				} 
			}			
         },
         show: {
            event: "click", 
            ready: true, 
            solo:  true
         },
         hide: {
            delay: 100,
            event: 'click',
            fixed: true 
         },
         style: {
            classes: 'ui-tooltip-nav ui-tooltip-light', 
            tip: false,
			width: '600'
         },
         events: {
            // Toggle an active class on each menus activator
            toggle: function(event, api) {
               api.elements.target.toggleClass('active', event.type === 'tooltipshow');
            },
			// make qtip movable on render
		   render: function(event, api) {
			   api.elements.tooltip.draggable();
		   },
		   focus: function(event, api) {
         // make sure this qtip is always on the bottom i.e. below the comment form tooltip
         event.preventDefault();
		}
         }
      });
   });
   
   $('.open_comments_summary_link').bind("click", function(event) {
      var self = $(this);
      var qtip = '.qtip.ui-tooltip';
   
      // Create the tooltip
      self.qtip({
         overwrite: false,
		id: $(this).attr('id'),
				 position:{
		 my: 'top right', at: 'bottom center'
		 },
         content: {
			title: {
                  text: 'Item Comments',
                  button: true
			},
			text: "Loading...",
			ajax: {
				url: 'get_comment_summary', 
				type: 'POST',
				data: {
					div_id: $(this).attr('id')
				} 
			}			
         },
         show: {
            event: "click", 
            ready: true, 
            solo:  true
         },
         hide: {
            delay: 100,
            event: 'click',
            fixed: true 
         },
         style: {
            classes: 'ui-tooltip-nav ui-tooltip-light', 
            tip: false,
			width: '600'
         },
         events: {
            // Toggle an active class on each menus activator
            toggle: function(event, api) {
               api.elements.target.toggleClass('active', event.type === 'tooltipshow');
            },
			// make qtip movable on render
		   render: function(event, api) {
			   api.elements.tooltip.draggable();
		   },
		   focus: function(event, api) {
         // make sure this qtip is always on the bottom i.e. below the comment form tooltip
         event.preventDefault();
		}
         }
      });
   });   
   
});



