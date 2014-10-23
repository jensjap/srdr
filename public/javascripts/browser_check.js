function getInternetExplorerVersion()
// Returns the version of Windows Internet Explorer or a -1
// (indicating the use of another browser).
{
   var rv = -1; // Return value assumes failure.
   if (navigator.appName == 'Microsoft Internet Explorer')
   {
      var ua = navigator.userAgent;
      var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
      if (re.exec(ua) != null)
         rv = parseFloat( RegExp.$1 );
   }
   return rv;
}
function assignStylesheet(){
  var msg = "You're not using Windows Internet Explorer.";
  var ver = getInternetExplorerVersion();
  if ( ver > -1 )
  {
    if ( ver>= 8.0 ){
       document.write("<link href='/stylesheets/modern_browsers.css' rel='stylesheet' media='screen,print' type='text/css'/>");
    }else if ( ver == 7.0 ){
       //alert("You are using IE7");
  	   document.write("<link href='/stylesheets/ie7.css' rel='stylesheet' media='screen,print' type='text/css'/>");
    }else if ( ver == 6.0 ){
  	  alert("We're sorry but Internet Explorer 6 is not fully supported. Please consider upgrading your browser.");
    }else{
  	  alert("Please upgrade your copy of Microsoft Internet Explorer.");
    }
  }else{
    //alert("modern browser");
    document.write("<link href='/stylesheets/modern_browsers.css' rel='stylesheet' media='screen,print' type='text/css'/>");
  }
}