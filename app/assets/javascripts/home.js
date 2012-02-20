$(document).ready(function() {

    var fillUriInput = function(uri, uriName, wikipediaURL, thumbnail) {
        $(this).find('.query_string').val(uriName);
        $(this).find('.query_string').attr('data-value', uri);
        $(this).find('.wikipedia_url').val(wikipediaURL);
        $(this).find('.thumbnail').val(thumbnail);
        $('#results').html('');
        $('#results').css('visibility', 'hidden');
    };

    var xhr = $.ajax();
    $(".query_string").keyup(function(event) {
        xhr.abort();
        var val = $(this).val();
        var data = {query_string: val};
        var form_el = $(this).closest('.tag_form');
        if (data.query_string.length > 1) {
            $('#results').css('visibility', 'visible');
            if ($('#results').find('#query-ajax').length == 0) {
              var li = $('<li></li>').css('text-align', 'center').append($('<img id="query-ajax" alt="Ajax-loader" height="16" src="/assets/ajax-loader.gif" width="16">'));
              $('#results').append(li);
            }

            xhr = $.ajax({
                url     : '/search_movie.json',
                type    : 'post',
                data    : data,
                dataType: "json",
                success: function(results, b, c) {
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
                }
            });
        } else {
            $('#results').empty();
        }
    });
    
    $('.tag_form').submit(function(){
        $(this).find('.query_string').val($(this).find('.query_string').attr('data-value'));
    });
    

    /****************************************************************************************** Infos */
    $('#search_directors').click(function() {
        $('#results_for_people').empty();
        $('#results_for_people').append($('<img alt="Ajax-loader" height="16" src="/assets/ajax-loader.gif" width="16">'));
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
                if (_.isEmpty(results)) {
                    li = $('<li></li>').addClass('no_tag').text('Personne ne correspond à la recherche');
                    $('#results_for_people').append(li);
                } else {
                    _.each(results, function(movie_object, facebook_id) {
                        var li = $('<li></li>')
                        var person = $('<div></div>').addClass('person');
                        person.append($('<fb:profile-pic size="square" uid="' + facebook_id + '"></fb:profile-pic>'));
                        person.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                        var movies = $('<ul></ul>').addClass('movies').addClass('list');
                        _.each(movie_object, function(movie) {
                            var movieDIV = $('<li></li>').addClass('movie');
                            movieDIV.append($('<div></div>').addClass('img_tag').attr('style', 'background-image: url(' + movie.thumbnail + ')'));
                            movieDIV.append($('<a></a>').html(movie.label).attr('href',movie.wikipedia_url));
                            movies.append(movieDIV);
                        });
                        li.append(person);
                        li.append(movies);
    
                        $('#results_for_people').append(li);
                    });
                    FB.XFBML.parse(document.getElementById('results_for_people'));                
                }
                
            }
        });
        return false;
    });
    $('#search_actors').click(function() {
        $('#results_for_actors_people').empty();
        $('#results_for_actors_people').append($('<img alt="Ajax-loader" height="16" src="/assets/ajax-loader.gif" width="16">'));
        $.ajax({
            url     : '/home/movies_you_might_like_from_actors',
            type    : 'post',
            data    :  {
                actors:  $('#actors').val()
            },
            dataType: "json",
            success: function(results, b, c) {
                $('#results_for_actors_people').empty();
                if (_.isEmpty(results)) {
                    li = $('<li></li>').addClass('no_tag').text('Personne ne correspond à la recherche');
                    $('#results_for_actors_people').append(li);
                } else {
                    _.each(results, function(facebook_id) {
                        var person = $('<div class="person"></div>')
                        person.append($('<fb:profile-pic uid="' + facebook_id + '"></fb:profile-pic>'));
                        person.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                        $('#results_for_actors_people').append(person);
                    });
                    FB.XFBML.parse(document.getElementById('results_for_actors_people'));
                }
            }
        });
        return false;
    });
    
     $.ajax({
        url     : '/home/movies_you_might_like',
        type    : 'post',
        dataType: "json",
        success: function(results, b, c) {
            $('#movies_you_might_like_results').empty();
            if (_.isEmpty(results)) {
                li = $('<li></li>').addClass('no_tag').text('Aucun film à suggérer');
                $('#movies_you_might_like_results').append(li);
            } else {
                var movies = $('<ul></ul>').addClass('movies list');
                _.each(results, function(movie) {
                    var movieDIV = $('<li></li>').addClass('movie');
                    movieDIV.append($('<div></div>').addClass('img_tag').attr('style', 'background-image: url(' + movie.thumbnail + ')'));
                    movieDIV.append($('<a></a>').html(movie.label).attr('href',movie.wikipedia_url));
                    movies.append(movieDIV);
                });
                $('#movies_you_might_like_results').append(movies);
            }
        }
    });
    $.ajax({
        url     : '/home/friends_you_might_like',
        type    : 'post',
        dataType: "json",
        success: function(results, b, c) {
            $('#friends_you_might_like_results').empty();
            if (_.isEmpty(results)) {
                li = $('<li></li>').addClass('no_tag').text('Aucune personne à suggérer');
                $('#friends_you_might_like_results').append(li);
            } else {
                _.each(results, function(facebook_id) {
                    var li = $('<li></li>').addClass('person')
                    li.append($('<fb:profile-pic size="square" uid="' + facebook_id + '"></fb:profile-pic>'));
                    li.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                    $('#friends_you_might_like_results').append(li);
                });
                FB.XFBML.parse(document.getElementById('friends_you_might_like_results'));
            }
        }
    });

    
    
    $("select").chosen({no_results_text: "No results matched"});
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
    $('#warning_box').hide();
    $('#tag_form').submit(function() {
        if (_.isUndefined($('#query_string').attr('data-value'))) {
            $('#warning_box').show();
            $('#warning_box').text('Vous devez entrer une valeur provenant de la Sugges Box.')
            return false;
        }
        return true;
    });
});