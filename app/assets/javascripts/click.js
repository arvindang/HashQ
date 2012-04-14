$(function(){

	$('#ahq').click(function() {
	  $('#ask').slideToggle('slow', function() {
	    // Animation complete.
	  });
	});

	// $('.poll-item').click(function(event) {
	// 	event.preventDefault();
	// 	$('#main').load("/polls/index");
	// });
	$(".poll-item").click(function(){

	 var poll_link = "/polls/show?id="+$(this).attr('data-poll-id');
	$("div.span9").load(poll_link);

	});

});