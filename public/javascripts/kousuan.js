$(document).ready(function() {
    'use strict';

    //----------- 全局变量 ----------------
    // 考试开始时间（毫秒）
    var examStartTime = Date.now();

    // 当前题目开始时间（毫秒）
    var currStartTime = examStartTime;

    // 当前题目
    var currq = 0;

    // 当前答案
    var curra = '';

    // 试卷类型
    var ptype = +$('#paper-type').text();

    // 题目列表
    var allQuestions = $('#question-sources').text().split(',').map(function(v){return +v});

    // 每个题目耗费时间列表(100毫秒)
    var periods = [];

    // 每个题目的答案
    var answers = [];

    // 每个题目的正确答案
    var rightAnswers = [];

    // 题目表达式
    var qexpressions = [];

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

    
// Ajax Utility Begin-------------------------------
    var ajax = (function() {
        function request(type, url, data, done, fail) {
            var xhr = $.ajax({url: url,
                type: type,
                data: data || {},
                dataType: 'json',
                cache: false});
            if (done) xhr.done(done);
            if (fail) xhr.fail(fail);
        }

        function get(url, data, done, fail) {
            request('GET', url, data, done, fail);
        }

        function post(url, data, done, fail) {
            request('POST', url, data, done, fail);
        }

        function put(url, data, done, fail) {
            request('PUT', url, data, done, fail);
        }

        function del(url, data, done, fail) {
            request('DELETE', url, data, done, fail);
        }

        return {
            get: get,
            post: post,
            put: put,
            delete: del,
        };
    })();
// Ajax Utility End---------------------------------

    //------------ 更新题目 --------------
    (function() {
        var ops = ['+', '-', '*', '/']
        var dos = [
            function(a,b) {return a+b;},
            function(a,b) {return a-b;},
            function(a,b) {return a*b;},
            function(a,b) {return a/b;}
        ];
        for (i=0; i<allQuestions.length; i++) {
            var q = allQuestions[i];
            var d3 = q%256;
            q = Math.floor(q/256);
            var d2 = q%256;
            q = Math.floor(q/256);
            var d1 = q%256;
            q = Math.floor(q/256);
            var qt = q%256;

            var op1 = qt%4;
            var op2, three
            if (qt >= 128) {
                op2 = Math.floor(qt/4)%4;
                three = true;
            } else if (qt >= 64) {
                d1 = d1 * 10;
                d2 = d2 * 10;
                d3 = d3 * 10;
            }

            var exp = '' + d1 + ops[op1] + d2;
            var result = dos[op1](d1, d2);
            if (three) {
                exp = exp + ops[op2] + d3;
                result = dos[op2](result, d3);
            }

            rightAnswers.push(result);
            qexpressions.push(exp);
        }
    })();

    function updateQuestion() {
        var qnum = allQuestions.length;
        if (currq < 0 || currq >= qnum) 
            return;
        $('.question-sequence').text('' + currq + '/' + qnum);
        $('.expression').text(qexpressions[currq]);
    }

    function updateAnswer() {
        $('.answer').text(curra);
    }

    // ----------------
    function commitAnswer() {
        clearTimer();

        var allAnswers = [];
        for (i=0; i<answers.length; i++) {
            allAnswers.push(answers[i] * 65536 + period[i]);
        }
        ajax.post('/answersheets', {
                ptype: ptype,
                questions: allQuestions,
                answers: allAnswers
            },
            function(data) {
            },
            function(xhr, err) {
            });
                
        
    }

    function handleInput(data) {
        if (data === -1) { // remove
            curra = curra.substr(0, curra.length-1);
        } else if (data === 10) { // commit
            var currTime = Date.now();
            periods.push(Math.floor((currTime-currStartTime)/100));
            currStartTime = currTime;

            answers.push(+curra);
            curra = '';

            currq ++;
            if (currq >= allQuestions.length) {// finished
                commitAnswer();
            }
        } else if (data >= 0 && data <= 9) { // number
            if (curra.length >= 4) return;
            curra = curra + data;
        } else { // error
        }

        updateAnswer();
    }

    $('#input0').click(function() {handleInput(0);});
    $('#input1').click(function() {handleInput(1);});
    $('#input2').click(function() {handleInput(2);});
    $('#input3').click(function() {handleInput(3);});
    $('#input4').click(function() {handleInput(4);});
    $('#input5').click(function() {handleInput(5);});
    $('#input6').click(function() {handleInput(6);});
    $('#input7').click(function() {handleInput(7);});
    $('#input8').click(function() {handleInput(8);});
    $('#input9').click(function() {handleInput(9);});
    $('#input10').click(function() {handleInput(10);});
    $('#input-1').click(function() {handleInput(-1);});
});
