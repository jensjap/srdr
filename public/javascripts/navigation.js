function SDMenu(id) {
	if (!document.getElementById || !document.getElementsByTagName)
		return false;
	this.menu = document.getElementById(id);
    if (this.menu == null) {
        this.menu = [];
    }
	this.submenus = this.menu.getElementsByTagName("div");
	this.remember = true;
	this.speed = 3;
	this.markCurrent = true;
	this.oneSmOnly = false;
	bind_nav_listeners();
}
SDMenu.prototype.init = function() {
	var mainInstance = this;
	for (var i = 0; i < this.submenus.length; i++) {
		if(typeof this.submenus[i].getElementsByTagName("span")[0] != 'undefined'){
			this.submenus[i].getElementsByTagName("span")[0].onclick = function() {
				mainInstance.toggleMenu(this.parentNode);
			};
		}
	}
	if (this.markCurrent) {
		var links = this.menu.getElementsByTagName("a");
		for (var i = 0; i < links.length; i++)
			if (links[i].href == document.location.href) {
				$(links[i]).addClass("nav-active");
				$(links[i]).addClass("nav-selected");
				/* if links[i] is in a submenu, we need to get the parent div of the submenu and activate with that */
				activate_section(links[i]);
				break;
			}
	}
	if (this.remember) {
		var regex = new RegExp("sdmenu_" + encodeURIComponent(this.menu.id) + "=([01]+)");
		var match = regex.exec(document.cookie);
		if (match) {
			var states = match[1].split("");
			for (var i = 0; i < states.length; i++){
				if (!this.submenus[i] == undefined){
					this.submenus[i].className = (states[i] == 0 ? "collapsed" : "");
				}
			}
		}
	}
};
SDMenu.prototype.toggleMenu = function(submenu) {
	if ($(submenu).hasClass("collapsed")){
		this.expandMenu(submenu);

	}else{
		this.collapseMenu(submenu);
	}
}
SDMenu.prototype.expandMenu = function(submenu) {
	var fullHeight = submenu.getElementsByTagName("span")[0].offsetHeight;
	var links = submenu.getElementsByTagName("a");
	for (var i = 0; i < links.length; i++)
		fullHeight += links[i].offsetHeight;
	var moveBy = Math.round(this.speed * links.length);

	var mainInstance = this;
	var intId = setInterval(function() {
		var curHeight = submenu.offsetHeight;
		var newHeight = curHeight + moveBy;
		if (newHeight < fullHeight)
			submenu.style.height = newHeight + "px";
		else {
			clearInterval(intId);
			submenu.style.height = "";
			$(submenu).removeClass('collapsed');
			mainInstance.memorize();
		}
	}, 30);
	this.collapseOthers(submenu);
};
SDMenu.prototype.collapseMenu = function(submenu) {
	var minHeight = submenu.getElementsByTagName("span")[0].offsetHeight;
	var moveBy = Math.round(this.speed * submenu.getElementsByTagName("a").length);
	var mainInstance = this;
	var intId = setInterval(function() {
		var curHeight = submenu.offsetHeight;
		var newHeight = curHeight - moveBy;
		if (newHeight > minHeight)
			submenu.style.height = newHeight + "px";
		else {
			clearInterval(intId);
			submenu.style.height = "";
			$(submenu).addClass("collapsed");
			mainInstance.memorize();
		}
	}, 30);
};
SDMenu.prototype.collapseOthers = function(submenu) {
	if (this.oneSmOnly) {
		for (var i = 0; i < this.submenus.length; i++)
			if (this.submenus[i] != submenu && this.submenus[i].className != "collapsed")
				this.collapseMenu(this.submenus[i]);
	}
};
SDMenu.prototype.expandAll = function() {
	var oldOneSmOnly = this.oneSmOnly;
	this.oneSmOnly = false;
	for (var i = 0; i < this.submenus.length; i++)
		if (this.submenus[i].className == "collapsed")
			this.expandMenu(this.submenus[i]);
	this.oneSmOnly = oldOneSmOnly;
};
SDMenu.prototype.collapseAll = function() {
	for (var i = 0; i < this.submenus.length; i++)
		if (this.submenus[i].className != "collapsed")
			this.collapseMenu(this.submenus[i]);
};
SDMenu.prototype.memorize = function() {
	if (this.remember) {
		var states = new Array();
		for (var i = 0; i < this.submenus.length; i++)
			states.push(this.submenus[i].className == "collapsed" ? 0 : 1);
		var d = new Date();
		d.setTime(d.getTime() + (30 * 24 * 60 * 60 * 1000));
		document.cookie = "sdmenu_" + encodeURIComponent(this.menu.id) + "=" + states.join("") + "; expires=" + d.toGMTString() + "; path=/";
	}
};
bind_nav_listeners = function(menu_obj){
	$(".left-nav-menu").children("a").bind("click",function(event){
		$(".nav-selected").removeClass("nav-selected");
		$(this).addClass("nav-selected");
		activate_section(this);
		/*$(this).addClass("nav-selected");

		section_title = $(this).prevAll("p").first();
		if(!$(section_title).hasClass("nav-active")){
			$(".nav-active").removeClass("nav-active");
			$(section_title).addClass("nav-active");
			go = true;
			current = section_title;
			while(go){
				if($(current).next().length > 0){
					sib = $(current).next();

					if(!($(sib).get(0).tagName === "P")){
						$(sib).addClass("nav-active");
						current = sib;
					}else{
						go = false;
					}
				}else{
					go = false
				}
			}

		}*/
	});
	$(".left-nav-menu").children("div").children("a").bind("click",function(event){
		$(".nav-selected").removeClass("nav-selected");
		$(this).addClass("nav-selected");
		activate_section(this);
		sectionSpan = $(this).prevAll("span").first();
		$(sectionSpan).addClass("nav-selected");
		$(sectionSpan).addClass("nav-selected");

		activate_section(this)
	});
}
activate_section = function(element){
	if($(element).parent().hasClass("left-nav-menu")){
		section_title = $(element).prevAll("p").first();
		if(!$(section_title).hasClass("nav-active")){
			$(".nav-active").removeClass("nav-active");
			$(section_title).addClass("nav-active");
			go = true;
			current = section_title;
			while(go){
				if($(current).next().length > 0){
					sib = $(current).next();

					if(!($(sib).get(0).tagName === "P")){
						$(sib).addClass("nav-active");
						current = sib;
					}else{
						go = false;
					}
				}else{
					go = false
				}
			}
		}
	}
	else{
		section_title = $(element).parent().prevAll("p").first();
		if(!$(section_title).hasClass("nav-active")){
			$(".nav-active").removeClass("nav-active");
			$(section_title).addClass("nav-active");
			go = true;
			current = section_title;
			while(go){
				if($(current).next().length > 0){
					sib = $(current).next();

					if(!($(sib).get(0).tagName === "P")){
						$(sib).addClass("nav-active");
						current = sib;
					}else{
						go = false;
					}
				}else{
					go = false
				}
			}
			sectionSpan = $(element).prevAll("span").first();
			$(sectionSpan).addClass("nav-selected");
			$(element).addClass("nav-selected");
		}

	}
}

