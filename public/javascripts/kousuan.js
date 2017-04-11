$(document).ready(function() {
    'use strict';

    //----------- 全局变量 ----------------
    // 考试开始时间（毫秒）
    var examStartTime = Date.now();

    // 当前题目开始时间（毫秒）
    var currStartTime = examStartTime;

    // 当前题目
    var currq = 0;

    // 题目列表
    var allQuestions = $('#question-sources').text().split(',').map(function(v){return +v});

    // 每个题目耗费时间列表
    var periods = [];

    // 每个题目的答案
    var answers = [];

    // timerID
    var updateTimeTimer;

    //----------- 更新时间 --------------
    function updateTime() {
        var now = Date.now();
        var time = floor((now - examStartTime)/1000);
        var minutes = floor(time/60);
        var seconds = time - minutes*60;
        $('.time-passed').text('' + minutes + ':' + seconds);
    }

    function clearTimer() {
        clearInterval(updateTimeTimer);
    }

    updateTimeTimer = setInterval(updateTime, 1000);

    
    //------------ 更新题目 --------------
    function updateQuestion() {
        var qnum = allQuestions.length;
        if (currq < 0 || currq >= qnum) 
            return;
        $('.question-sequence').text('' + currq + '/' + qnum);
        var q = allQuestions[currq];
        
    }
});
