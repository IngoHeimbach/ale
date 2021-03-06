" Author: Ingo Meyer <i.meyer@fz-juelich.de>
" Description: Support for css-beautify, a css style linter

call ale#Set('css_cssbeautify_executable', 'css-beautify')
call ale#Set('css_cssbeautify_options', '')
call ale#Set('css_cssbeautify_style', '(&expandtab ? "--indent-size ".shiftwidth() : "--indent-with-tabs ")')

function! ale_linters#css#cssbeautify#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'css_cssbeautify_executable')
endfunction

function! ale_linters#css#cssbeautify#GetCommand(buffer) abort
    let l:style = eval(ale#Var(a:buffer, 'css_cssbeautify_style'))
    return ale#Escape(ale_linters#css#cssbeautify#GetExecutable(a:buffer))
    \   . (!empty(l:style) ? ' ' . l:style : '')
    \   . ' ' . ale#Var(a:buffer, 'css_cssbeautify_options')
    \   . ' < %t | '
    \   . 'diff --old-group-format="%df: warning: cssbeautify style: " --unchanged-line-format="" %t - | '
    \   . 'sed -E "s/([[:digit:]]+)(: warning: cssbeautify style: )/\n\1\2/g"'
endfunction

function! ale_linters#css#cssbeautify#Handle(buffer, lines) abort
    " matches: '2: warning: ...
    let l:pattern = '\v(\d+): warning: (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'text': l:match[2],
        \   'type': 'W',
        \   'sub_type': 'style',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('css', {
\   'name': 'cssbeautify',
\   'executable': function('ale_linters#css#cssbeautify#GetExecutable'),
\   'command': function('ale_linters#css#cssbeautify#GetCommand'),
\   'callback': 'ale_linters#css#cssbeautify#Handle',
\   'read_buffer': 0
\})
