/**
 * Drag'n'drop push pin with jQuery and HTML5 Drag & Drop
 * by Jens Jap
 * Modified from source: http://decafbad.com/2009/07/drag-and-drop/js/outline.js
 */
$( document ).ready (function () {

    /**
     * Immediately Invoked Function Expression -- to work well
     * with other plugins, and still use jQuery $ alias.
     */
    (function ( $ ) {

        /**
         * Get lowercase tagname for node.
         */
        $.fn.tagName = function() {
            if (!this.get(0)) return;
            return this.get(0).tagName.toLowerCase();
        };

        /**
         * jQuery plugin interface for creating pintastic instances.
         */
        $.fn.pintastic = function() {
            return this.data('pintastic',
                new arguments.callee.support(this));
        }

        /**
         * Constructor for pintastic support class.
         */
        $.fn.pintastic.support = function(root) {
            this.init.apply(this, arguments);
        }

        /**
         * Support class for the pintastic plugin.
         */
        $.fn.pintastic.support.prototype = {

            /**
             * Initialize the pintastic support object.
             */
            init: function(root) {
                this.root    = root;
                this.dragged = null;

                this.wireUpEvents();
            },

            /**
             * Wire up event handlers for the pintastic.
             */
            wireUpEvents: function() {

                // Save an object reference for event handlers.
                var $this = this;

                this.root
                    .find('img.draggable-pin').attr('draggable', 'true').end()

                    .bind('dragstart', function(ev) {
                        $this.setDraggedFromEvent(ev);
                        $this.captureQuestionId(ev);
                        return true;
                    })

                    .bind('dragend', function(ev) {
                        $(ev.target).removeClass('dragging');
                        return false;
                    })

                    .bind('dragenter', function(ev) {
                        $this.updateDropFeedback(ev, 'highlight');
                        return false;
                    })

                    .bind('dragleave', function(ev) {
                        $this.updateDropFeedback(ev, 'clear');
                        return false;
                    })

                    .bind('dragover', function(ev) {
                        if ( $(ev.target).hasClass('drop-zone') ) {
                            return false;
                        }
                        return true;
                    })

                    .bind('drop', function(ev) {
                        ev.preventDefault();
                        $this.performDrop(ev);
                        $this.dragged = null;
                        return false;
                    });

            },

            /**
             * Capture the node dragged from an event.
             */
            setDraggedFromEvent: function(ev) {

                // dragged property works for draggable-pin images only.
                var node = $(ev.target);
                while (node.tagName() != 'img') {
                    node = node.parent();
                }

                if ( $(node.context).hasClass('draggable-pin') ) {
                    this.dragged = node;
                    this.dragged.addClass('dragging');
                }
            },

            /**
             * Find the question id from the nearest editable field and save it
             * in the dataTransfer object for later
             */
            captureQuestionId: function(ev) {

                // dragged property works for draggable-pin images only.
                var node = $(ev.target);
                while (node.tagName() != 'img') {
                    node = node.parent();
                }

                if ( $(node.context).hasClass('draggable-pin') ) {
                    // Find the nearest .editable_field and extract its ID. This is the question ID.
                    qId = node.prevAll('.editable_field:first').attr('id');
                    // We add information to the DataTransfer object for later.
                    var dt = ev.originalEvent.dataTransfer;
                    dt.setData('qId', qId);
                    // Copy the dt object over to the 'current' event.
                    //ev.dataTransfer = dt;
                }
            },

            /**
             * Get the node dragged, whether captured by us or dragged in from
             * another window.
             */
            getDragged: function(ev) {
                var node = null;
                if (this.dragged) {
                    // Use the node captured at dragstart, if available.
                    node = this.dragged;
                } else {

                    // Look for HTML or text content dragged in from outside.
                    var dt = ev.originalEvent.dataTransfer;
                    var content = dt.getData('text/html');
                    if (!content) content = dt.getData('text/plain');

                    if (content) {
                        // If any content available, build a new node for drop.
                        node = $(document.createElement('li'));
                        node.attr('draggable', 'true');
                        node.append('<div>'+content+'</div>');

                        // Remember this node for next check.
                        this.dragged = node;
                    }

                }
                return node;
            },

            /**
             * Determine details for potential drop, given an event from one of the
             * drop listeners.
             */
            checkDrop: function(ev, target) {
                var t_pos = target.position();
                var drop = {
                    land_above: ev.pageY < t_pos.top + (target.height()/2),
                    land_child: ev.pageX > t_pos.left + 75,
                    allowed:
                        !this.dragged ||
                        ( this.dragged &&
                            ( target[0] != this.dragged[0] ) &&
                            ( $.inArray(this.dragged[0], target.parents()) == -1 )
                        )
                };
                return drop;
            },

            /**
             * Update the feedback for drop on dragover.
             */
            updateDropFeedback: function(ev, action) {
                if ( $(ev.target).hasClass('drop-zone') ) {
                    if (action === "highlight") {
                        ev.target.style.backgroundColor = "fuchsia";
                        /*ev.target.style.opacity = 0.3;*/
                    } else if (action === "clear") {
                        ev.target.removeAttribute('style');
                    }
                }
            },

            /**
             * Perform the drop suggested by the event.
             */
            performDrop: function(ev) {

                var target = ev.target,
                    dt     = ev.originalEvent.dataTransfer,
                    qId    = dt.getData('qId');

                var myClassList = target.className.replace(" drop-zone", "");

                console.log('Target element: \n', target);
                console.log('DataTransfer object: \n', dt);
                console.log('Question ID: \n', qId);
                console.log('Class: \n', myClassList);
                return false;
            },

            /**
             * Find a child list for the given target, creating a new one if
             * necessary.
             */
            getTargetUL: function(target) {
                var ul = target.find('ul:first');
                if (!ul.length) {
                    target.append('<ul></ul>');
                    ul = target.find('ul:first');
                }
                return ul;
            },

            EOF:null
        };

    }( jQuery ));

    // jQuery creates it's own event object, and it doesn't have a
    // dataTransfer property yet. This adds dataTransfer to the event object.
    // Thanks to l4rk for figuring this out!
    //jQuery.event.props.push('dataTransfer');  // I guess we don't need this any more.

    // Remove default .draggable from images.
    $("img").attr('draggable', false);

    // Set up the drop zones in the PDF.
    $("div#page-container div.t").addClass('drop-zone');

    // Start up Pintastic
    $("#container-split").pintastic();

});
