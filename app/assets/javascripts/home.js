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
            success: function(results, b, c) {
                if (results.length == 0) {
                    $('#suggest_box').html('Nous ne pouvons malheureusement rien suggérer.');
                } else {
                    var random = parseInt(Math.random() * results.length);
                    $('#suggest_box').html(results[random].label.value);
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
                _.each(results, function(facebook_id) {
                    var person = $('<div class="person"></div>')
                    person.append($('<fb:name uid="' + facebook_id + '"></fb:name>'));
                    person.append($('<fb:profile-pic uid="' + facebook_id + '"></fb:profile-pic>'));
                    $('#results_for_people').append(person);
                });
                FB.XFBML.parse(document.getElementById('results_for_people'));
            }
        });
        return false;
    });
    
});

