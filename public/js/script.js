/**
 * Replies in comments
 *
 * @param {string} name Name
 */
function reply(name) {
    var comment = document.getElementById('comment-content');
    if (comment.value == 'Комментарий *') {
        comment.value = name + ', ';
    } else {
        comment.value += name + ', ';
    }
    comment.focus();
}

// jQuery
$(function() {
    $('#add-comment').click(function() {
        if ($('#comment-content').val() == '') {
            $('.errors').text('Введите комментарий, пожалуйста');
            return false;
        }
        if ($('#comment-author').val() == '') {
            $('.errors').text('Представьтесь, пожалуйста');
            return false;
        }
        if ($('#comment-email').val() == '') {
            $('.errors').text('Введите email, пожалуйста');
            return false;
        }
    });
});
