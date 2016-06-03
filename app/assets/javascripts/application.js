// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


var own_poster = function (poster_id) {
  var formData = new FormData();
  formData.append("poster_id", poster_id);
  $.ajax ({
    data: formData,
    type: 'POST',
    processData: false,
    contentType: false,
    dataType: 'JSON',
    url: "/home/ownPoster",
    success: function(data) {
      console.log("담기 성공");
      $("#" + data).html(" \
        <button type='button' id='<%= poster.id %>' onclick='out_poster(" + data + ")'>담기취소</button> \
      ");
    }, 
    error: function(data) {
      console.log("담기 실패");
      console.log(data);
    }
  });
}

var out_poster = function(poster_id) {
  var formData = new FormData();
  formData.append("poster_id", poster_id);
  $.ajax ({
    data: formData,
    type: 'POST',
    processData: false,
    contentType: false,
    dataType: 'JSON',
    url: "/home/outPoster",
    success: function(data) {
      console.log("빼기 성공");
      $("#" + data).html(" \
        <button type='button' id='<%= poster.id %>' onclick='own_poster(" + data + ")'>담기</button> \
      ");
    }, 
    error: function(data) {
      console.log("빼기 실패");
      console.log(data);
    }
  });
}
