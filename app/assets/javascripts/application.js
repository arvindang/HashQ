// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_tree .



function checkquestion(textid,infodiv)
{
	var question = $('#'+ textid).val();
	if(question != '')
		{
			if(isvalidquestion(question))
					{
							$('#' + infodiv).html("Good");
							return true;
					} else {
							$('#' + infodiv).html("'#q' first, question with '?' and answers seperated by semi-colons");
							return true;
	 				}
			}else{			
				$('#' + infodiv).html("");
				return true;
			}
			
}

function isvalidquestion(question) {
 		var pattern = new RegExp(/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/i);
 		return pattern.test(question);
	}

function limitChars(textid, limit, infodiv)
{
	var text = $('#'+textid).val();	
	var textlength = text.length;
	if(textlength > 10000)
	{
		$('#' + infodiv).html('You cannot write more then '+limit+' characters!');
		$('#'+ textid).val(text.substr(0,limit));
		return false;
	}
	else
	{
		$('#' + infodiv).html((limit - textlength));
		return true;
	}
}


$(function(){

	$('a[rel=popover]').popover({
	      offset: 10
	    })
	    .click(function(e) {
	      e.preventDefault();
    });
 
		$('#q').keyup(function(){
 			limitChars('q', 140, 'charlimitinfo');
			checkquestion('q','validquestion');
 		});


});