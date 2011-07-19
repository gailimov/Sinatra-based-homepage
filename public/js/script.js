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
