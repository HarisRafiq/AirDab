$(function(){

  var playlist;
  $.ajax({
         
         dataType: 'json',
         async: false,
         url:'/music',
         success: function( data ) {
         playlist=data;
         var alternate = false;
         $.each(data, function (i, items) {
                var liclass='odd';
                if (alternate)
                liclass='even';
                encodeName = encodeURI(items.name).replace("'", "&apos;");
                
                var audio = "<audio controls preload='none'><source src='/music/" + encodeName + "' type='audio/mp3' /></audio>",
                button = " <span class='plays'><a href='#'>"+items.name + "</a></span> ",
                minus = "<span class='minus'>-</span>",
                timeleft = "<span id='timeleft'>3:17</span>";
                var tpl = $("  <span class='delete' id='d"+liclass+"'><a href='#'>DELETE</a></span><li class='"+liclass+"'> "+button+ "</li>");
                alternate=!alternate;
                var ul = $('.playlist');
                tpl.appendTo(ul);
                var Count=$('.playlist .plays').length;
  var aud = $('#jukebox .aud').get(0);
                var p = $('.playlist .plays').get(Count-1);
                $(p).click(function(e) {
                           
                                     e.preventDefault();
                           
                           aud.pos=Count-1;
                           aud.duration=items.duration;
                               aud.setAttribute('src', "/music/" + encodeURI(items.name));
                               $('#jukebox .info').html(items.name);
                               aud.load();

                                         });
 var i = $('.playlist .delete').get(i);
                
                $(i).click(function(e) {
                           e.preventDefault();
                         
                           var url="/delete/" + encodeURI(items.name);
                           $(tpl).remove();
                           

                           $.get(url, function(data) {
                                                                    });
                           
                           });

                
                });
         }
         });
   var aud = $('#jukebox .aud').get(0);
  aud.pos = -1;
  var liCount=$('.playlist .plays').length;
  
  $('#jukebox .play').bind('click', function(evt) {
                           evt.preventDefault();
                           if (aud.pos < 0) {
                           $('#jukebox .next').trigger('click');
                           } else {
                           aud.play();
                           
                           }
                           });
  
  $('#jukebox .pause').bind('click', function(evt) {
                            evt.preventDefault();
                            aud.pause();
                            });
  
  $('#jukebox .next').bind('click', function(evt) {
                           evt.preventDefault();
                           aud.pause();
                           aud.pos++;
                           if (aud.pos == liCount) aud.pos = 0;
                           var title=$('.playlist .plays a').get(aud.pos);
                           var titleText =  $(title).text();
                           alert(titleText);
                          encodeName = encodeURI(titleText);
                           aud.setAttribute('src', "/music/" + encodeName );
                           $('#jukebox .info').html(titleText);
                           aud.load();
                           });
  
  $('#jukebox .prev').bind('click', function(evt) {
                           evt.preventDefault();
                           aud.pause();
                           aud.pos--;
                           if (aud.pos < 0) aud.pos = liCount - 1;
                           var title=$('.playlist .plays a').get(aud.pos);
                           var titleText =  $(title).text();
                           
                           encodeName = encodeURI(titleText);
                           aud.setAttribute('src', "/music/" + encodeName );
                           $('#jukebox .info').html(titleText);
                           aud.load();
                           });
  
  // JQuery doesn't seem to like binding to these HTML 5
  // media events, but addEventListener does just fine
  
  aud.addEventListener('progress', function(evt) {
                       var width = parseInt($('#jukebox').css('width'))-10;
                       var percentLoaded = Math.round(evt.loaded / evt.total * 100);
                       var barWidth = Math.ceil(percentLoaded * (width / 100));
                       $('#jukebox .load-progress').css( 'width', barWidth );
                       
                       });
  
  aud.addEventListener('timeupdate', function(evt) {
                       var width = parseInt($('#jukebox').css('width')) ;
                       var percentPlayed = Math.round(aud.currentTime / aud.duration * 100);
                       
                       var barWidth = Math.ceil(percentPlayed * width);
                       $('#jukebox .play-progress').css( 'width', barWidth+ '%');
                       });
  
  aud.addEventListener('canplay', function(evt) {
                       $('#jukebox .play').trigger('click');
                       });
  
  aud.addEventListener('ended', function(evt) {
                       $('#jukebox .next').trigger('click');
                       });
  if (playlist.pos < 0)
  $('#jukebox .info').html(playlist[0].name);
  
  });





