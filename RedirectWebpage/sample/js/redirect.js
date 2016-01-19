
function RedirectiOS(){
		gotoAppPage = setTimeout("setiOSPage()", 1500);
}; 

function setTitle(device) {
    return ;
}

function setContent() {
    return "Sorry Story Grid is only available for iOS at the moment.";
}


document.getElementById("goto_developerpage").addEventListener("click", function(event)
{
   window.location="http://awhitman92.com/portfolio/storygrid";     
});


function setiOSPage() {
	 window.location="https://geo.itunes.apple.com/us/app/story-grid-combine-countless/id1054868234?mt=8";     
}
       
 //document.write("You will be redirected to main page in 10 sec.");
 function getMobileOperatingSystem() {
  var userAgent = navigator.userAgent || navigator.vendor || window.opera;

  if( userAgent.match( /iPad/i ) || userAgent.match( /iPhone/i ) || userAgent.match( /iPod/i ) )
  {
  	document.getElementById("title").innerHTML = "Redirecting to AppStore"; 
  	document.getElementById("Content").innerHTML = "Story Grid: Combine Countless Photos to Share an Experience";
    RedirectiOS();


  }
  //else if( userAgent.match( /Android/i ) )
  //{
  //  return 'Android';
  //}
  else
  {
    document.getElementById("title").innerHTML = "App Not Available for Device"; 
  	document.getElementById("Content").innerHTML = setContent(); 
  }
}