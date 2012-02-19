$(document).ready(function() {

    var fillUriInput = function(uri, uriName, wikipediaURL, thumbnail) {
        $(this).find('.query_string').val(uriName);
        $(this).find('.query_string').attr('data-value', uri);
        $(this).find('.wikipedia_url').val(wikipediaURL);
        $(this).find('.thumbnail').val(thumbnail);
        $('#results').html('');
        $('#results').css('visibility', 'hidden');
    };


    $("#ajax_loader").hide();
    var xhr = $.ajax();
    $(".query_string").keyup(function(event) {
        xhr.abort();
        $("#ajax_loader").hide();
        var val = $(this).val();
        var data = {query_string: val};
        var form_el = $(this).closest('.tag_form');
        if (data.query_string.length > 1) {
            $('#results').css('visibility', 'visible');
            $("#ajax_loader").show();
            xhr = $.ajax({
                url     : '/search_movie.json',
                type    : 'post',
                data    : data,
                dataType: "json",
                success: function(results, b, c) {
                    $("#ajax_loader").hide();   
                    $('#results').empty();
                    _.each(results, function(result){
                        if (result.uri) {
                            uriName = result.uri.replace('http://dbpedia.org/resource/', '').replace(/_/g, ' ');
                            uriName = decodeURI(uriName);
                            var liTag = $('<li>' + uriName + '</li>');
                            liTag.click(fillUriInput.bind(form_el, result.uri, uriName, '', ''));
                            $('#results').append(liTag);
                        }
                    });
/*
                    $('#query_string').keydown(function(evt) {
                        switch (evt.keyCode) {
                            case 38:
                                $('#results').
                                break;
                            case 40:
                                break;
                            case 13:
                                break;
                          }
                    });
*/
                }
            });
        } else {
            $('#results').empty();
        }
    });
    
    $('.tag_form').submit(function(){
        $(this).find('.query_string').val($(this).find('.query_string').attr('data-value'));
    });
    $("select").chosen({no_results_text: "No results matched"});
    $('#YouMightLike').click(function() {
        $.ajax({
            url     : '/you_might_like.json',
            type    : 'post',
            data    :  {
                uri: 'http://dbpedia.org/resource/American_football'
            },
            dataType: "json",
            success: function(results, b, c) {
                var random = parseInt(Math.random() * results.length);
                alert(results[random].label.value);
            }
        });
    });
    
    $('#suggest').click(function() {
        var user_id = $("[name='tag[user_identifier]']").val();
        $.ajax({
            url     : '/he_might_like.json',
            type    : 'post',
            data    :  {
                user_identifier: user_id
            },
            dataType: "json",
            success: function(result, b, c) {
                if (result === null) {
                    $('#suggest_box').html('Nous ne pouvons malheureusement rien suggérer.');
                } else {
                    $('#suggest_box').html(result);
                }
            }
        });
        return false;
    });
    

    /****************************************************************************************** Infos */
    $('#search_directors').click(function() {
        $.ajax({
            url     : '/home/get_infos',
            type    : 'post',
            data    :  {
                like:       $('#like_true').is(':checked'),
                directors:  $('#directors').val()
            },
            dataType: "json",
            success: function(results, b, c) {
                $('#results_for_people').empty();
                _.each(results, function(movie_object, facebook_id) {
                    var li = $('<li></li>')
                    var person = $('<div></div>').addClass('person');
                    person.append($('<fb:profile-pic size="square" uid="' + facebook_id + '"></fb:profile-pic>'));
                    person.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                    var movies = $('<div></div>').addClass('movies');
                    _.each(movie_object, function(movie) {
                        var movieDIV = $('<div></div>').addClass('movie');
                        movieDIV.append($('<div></div>').addClass('img_tag').attr('style', 'background-image: url(' + movie.movie_thumb + ')'));
                        movieDIV.append($('<a></a>').html(movie.movie_name).attr('href',movie.wikipedia_url));
                        movies.append(movieDIV);
                    });
                    li.append(person);
                    li.append(movies);

                    $('#results_for_people').append(li);
                });
                FB.XFBML.parse(document.getElementById('results_for_people'));
            }
        });
        return false;
    });
     $('#search_actors').click(function() {
        $.ajax({
            url     : '/home/movies_you_might_like_from_actors',
            type    : 'post',
            data    :  {
                actors:  $('#actors').val()
            },
            dataType: "json",
            success: function(results, b, c) {
                $('#results_for_actors_people').empty();
                _.each(results, function(facebook_id) {
                    var person = $('<div class="person"></div>')
                    person.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                    person.append($('<fb:profile-pic uid="' + facebook_id + '"></fb:profile-pic>'));
                    $('#results_for_actors_people').append(person);
                });
                FB.XFBML.parse(document.getElementById('results_for_actors_people'));
            }
        });
        return false;
    });

   /** MENU **/ 
   $('#menu ul li#un').click(function(){
      $('#menu ul li').removeClass('selected');
      $(this).addClass('selected');
      $('#content_1').css('display', 'block');
      $('#content_2').css('display', 'none');
      $('#content_3').css('display', 'none');
   });
   $('#menu ul li#deux').click(function(){
      $('#menu ul li').removeClass('selected');
      $(this).addClass('selected');
      $('#content_1').css('display', 'none');
      $('#content_2').css('display', 'block');
      $('#content_3').css('display', 'none');
   });
   $('#menu ul li#trois').click(function(){
      $('#menu ul li').removeClass('selected');
      $(this).addClass('selected');
      $('#content_1').css('display', 'none');
      $('#content_2').css('display', 'none');
      $('#content_3').css('display', 'block');
   });
});
