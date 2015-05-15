/*
 * SimplePlaylist - A jQuery Plugin
 * @requires jQuery v1.4.0 or later
 *
 * SimplePlaylist is a html5 multitrack audio player
 * forked from http://github.com/yuanhao/Simple-Player
 *
 * Licensed under the MIT:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright (c) 2012, Zakhar Day (zakhar.day -[at]- gmail [*dot*] com)
 */

function stopAudio(audio) {
    $('.playing').removeClass('playing');
    $('.progressBar').remove();
    $('.minus').fadeOut('fast');
    audio.pause();
    audio.currentTime = 0;
}
$(function(){

    var progressBarBlock = '<div class="progressBar">' +
                             '<div class="progress"></div>' +
                           '</div>';
    

 
 $.ajax({
      
        dataType: 'json',
        
        url:'/music',
        success: function( data ) {
        $.each(data, function (i, items) {
        
               encodeName = encodeURI(items.name).replace("'", "&apos;");

      var audio = "<audio preload='none'><source src='/music/" + encodeName + "' type='audio/mp3' /></audio>",
      button = "<span class='controls' id='playToggle'></span>",
      minus = "<span class='minus'>-</span>",
      timeleft = "<span id='timeleft'>3:17</span>";
                     $('.playlist').append("<li><div class=track>"+button+"<span class='title'>" + items.name + "</span>"+minus+"<span id='timeleft'>3:17</span></div>"+audio+"</li>");
      $(audio).bind('play',function() {
        
        $(audio).before(progressBarBlock);
        $(button).addClass('playing');
        $(minus).fadeIn('fast');
        
        var progressBar = $('.progressBar'),
        progress = $('.progress');
        
        $(audio).bind('timeupdate', function(e) {
          var rem = parseInt(this.duration - this.currentTime, 10),
          pos = (this.currentTime / this.duration) * 100,
          mins = Math.floor(rem/60,10),
          secs = rem - mins*60;

          $(timeleft).text(mins + ':' + (secs > 9 ? secs : '0' + secs));
          $(progress).css('width', pos + '%');
        });
        
        $(progressBar).click(function(e) {
          if (audio.duration != 0) {
            left = $(this).offset().left;
            offset = e.pageX - left;
            percent = offset / progressBar.width();
            duration_seek = percent * audio.duration;
            audio.currentTime = duration_seek;
          }
        });
        
      }).bind('pause', function() {
        stopAudio(audio);
      });
       });
        } });
 
              
        
              });