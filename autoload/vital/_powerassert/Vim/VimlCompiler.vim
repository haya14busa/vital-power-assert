"=============================================================================
" FILE: autoload/vital/__latest__/VimlCompiler.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V = a:V
  let s:VLP = s:V.import('Vim.VimlParser').import()
endfunction

function! s:_vital_depends() abort
  return ['Vim.VimlParser']
endfunction

function! s:import() abort
  call extend(s:, s:VLP)
  return extend(deepcopy(s:VLP.Compiler), s:VimlCompiler)
endfunction

let s:VimlCompiler = {}

function! s:VimlCompiler.compile(node) abort
  if a:node.type == s:NODE_TOPLEVEL
    return self.compile_toplevel(a:node)
  " elseif a:node.type == s:NODE_COMMENT
  "   return self.compile_comment(a:node)
  " elseif a:node.type == s:NODE_EXCMD
  "   return self.compile_excmd(a:node)
  " elseif a:node.type == s:NODE_FUNCTION
  "   return self.compile_function(a:node)
  " elseif a:node.type == s:NODE_DELFUNCTION
  "   return self.compile_delfunction(a:node)
  " elseif a:node.type == s:NODE_RETURN
  "   return self.compile_return(a:node)
  " elseif a:node.type == s:NODE_EXCALL
  "   return self.compile_excall(a:node)
  " elseif a:node.type == s:NODE_LET
  "   return self.compile_let(a:node)
  " elseif a:node.type == s:NODE_UNLET
  "   return self.compile_unlet(a:node)
  " elseif a:node.type == s:NODE_LOCKVAR
  "   return self.compile_lockvar(a:node)
  " elseif a:node.type == s:NODE_UNLOCKVAR
  "   return self.compile_unlockvar(a:node)
  " elseif a:node.type == s:NODE_IF
  "   return self.compile_if(a:node)
  " elseif a:node.type == s:NODE_WHILE
  "   return self.compile_while(a:node)
  " elseif a:node.type == s:NODE_FOR
  "   return self.compile_for(a:node)
  " elseif a:node.type == s:NODE_CONTINUE
  "   return self.compile_continue(a:node)
  " elseif a:node.type == s:NODE_BREAK
  "   return self.compile_break(a:node)
  " elseif a:node.type == s:NODE_TRY
  "   return self.compile_try(a:node)
  " elseif a:node.type == s:NODE_THROW
  "   return self.compile_throw(a:node)
  " elseif a:node.type == s:NODE_ECHO
  "   return self.compile_echo(a:node)
  " elseif a:node.type == s:NODE_ECHON
  "   return self.compile_echon(a:node)
  " elseif a:node.type == s:NODE_ECHOHL
  "   return self.compile_echohl(a:node)
  " elseif a:node.type == s:NODE_ECHOMSG
  "   return self.compile_echomsg(a:node)
  " elseif a:node.type == s:NODE_ECHOERR
  "   return self.compile_echoerr(a:node)
  " elseif a:node.type == s:NODE_EXECUTE
  "   return self.compile_execute(a:node)
  elseif a:node.type == s:NODE_TERNARY
    return self.compile_ternary(a:node)
  elseif a:node.type == s:NODE_OR
    return self.compile_or(a:node)
  elseif a:node.type == s:NODE_AND
    return self.compile_and(a:node)
  elseif a:node.type == s:NODE_EQUAL
    return self.compile_equal(a:node)
  elseif a:node.type == s:NODE_EQUALCI
    return self.compile_equalci(a:node)
  elseif a:node.type == s:NODE_EQUALCS
    return self.compile_equalcs(a:node)
  elseif a:node.type == s:NODE_NEQUAL
    return self.compile_nequal(a:node)
  elseif a:node.type == s:NODE_NEQUALCI
    return self.compile_nequalci(a:node)
  elseif a:node.type == s:NODE_NEQUALCS
    return self.compile_nequalcs(a:node)
  elseif a:node.type == s:NODE_GREATER
    return self.compile_greater(a:node)
  elseif a:node.type == s:NODE_GREATERCI
    return self.compile_greaterci(a:node)
  elseif a:node.type == s:NODE_GREATERCS
    return self.compile_greatercs(a:node)
  elseif a:node.type == s:NODE_GEQUAL
    return self.compile_gequal(a:node)
  elseif a:node.type == s:NODE_GEQUALCI
    return self.compile_gequalci(a:node)
  elseif a:node.type == s:NODE_GEQUALCS
    return self.compile_gequalcs(a:node)
  elseif a:node.type == s:NODE_SMALLER
    return self.compile_smaller(a:node)
  elseif a:node.type == s:NODE_SMALLERCI
    return self.compile_smallerci(a:node)
  elseif a:node.type == s:NODE_SMALLERCS
    return self.compile_smallercs(a:node)
  elseif a:node.type == s:NODE_SEQUAL
    return self.compile_sequal(a:node)
  elseif a:node.type == s:NODE_SEQUALCI
    return self.compile_sequalci(a:node)
  elseif a:node.type == s:NODE_SEQUALCS
    return self.compile_sequalcs(a:node)
  elseif a:node.type == s:NODE_MATCH
    return self.compile_match(a:node)
  elseif a:node.type == s:NODE_MATCHCI
    return self.compile_matchci(a:node)
  elseif a:node.type == s:NODE_MATCHCS
    return self.compile_matchcs(a:node)
  elseif a:node.type == s:NODE_NOMATCH
    return self.compile_nomatch(a:node)
  elseif a:node.type == s:NODE_NOMATCHCI
    return self.compile_nomatchci(a:node)
  elseif a:node.type == s:NODE_NOMATCHCS
    return self.compile_nomatchcs(a:node)
  elseif a:node.type == s:NODE_IS
    return self.compile_is(a:node)
  elseif a:node.type == s:NODE_ISCI
    return self.compile_isci(a:node)
  elseif a:node.type == s:NODE_ISCS
    return self.compile_iscs(a:node)
  elseif a:node.type == s:NODE_ISNOT
    return self.compile_isnot(a:node)
  elseif a:node.type == s:NODE_ISNOTCI
    return self.compile_isnotci(a:node)
  elseif a:node.type == s:NODE_ISNOTCS
    return self.compile_isnotcs(a:node)
  elseif a:node.type == s:NODE_ADD
    return self.compile_add(a:node)
  elseif a:node.type == s:NODE_SUBTRACT
    return self.compile_subtract(a:node)
  elseif a:node.type == s:NODE_CONCAT
    return self.compile_concat(a:node)
  elseif a:node.type == s:NODE_MULTIPLY
    return self.compile_multiply(a:node)
  elseif a:node.type == s:NODE_DIVIDE
    return self.compile_divide(a:node)
  elseif a:node.type == s:NODE_REMAINDER
    return self.compile_remainder(a:node)
  elseif a:node.type == s:NODE_NOT
    return self.compile_not(a:node)
  elseif a:node.type == s:NODE_PLUS
    return self.compile_plus(a:node)
  elseif a:node.type == s:NODE_MINUS
    return self.compile_minus(a:node)
  elseif a:node.type == s:NODE_SUBSCRIPT
    return self.compile_subscript(a:node)
  elseif a:node.type == s:NODE_SLICE
    return self.compile_slice(a:node)
  elseif a:node.type == s:NODE_DOT
    return self.compile_dot(a:node)
  elseif a:node.type == s:NODE_CALL
    return self.compile_call(a:node)
  elseif a:node.type == s:NODE_NUMBER
    return self.compile_number(a:node)
  elseif a:node.type == s:NODE_STRING
    return self.compile_string(a:node)
  elseif a:node.type == s:NODE_LIST
    return self.compile_list(a:node)
  elseif a:node.type == s:NODE_DICT
    return self.compile_dict(a:node)
  elseif a:node.type == s:NODE_OPTION
    return self.compile_option(a:node)
  elseif a:node.type == s:NODE_IDENTIFIER
    return self.compile_identifier(a:node)
  elseif a:node.type == s:NODE_CURLYNAME
    return self.compile_curlyname(a:node)
  elseif a:node.type == s:NODE_ENV
    return self.compile_env(a:node)
  elseif a:node.type == s:NODE_REG
    return self.compile_reg(a:node)
  elseif a:node.type == s:NODE_CURLYNAMEPART
    return self.compile_curlynamepart(a:node)
  elseif a:node.type == s:NODE_CURLYNAMEEXPR
    return self.compile_curlynameexpr(a:node)
  else
    throw printf('VimlCompiler: unknown node: %s', string(a:node))
  endif
endfunction

function! s:VimlCompiler.compile_ternary(node) abort
  return printf('(%s ? %s : %s)', self.compile(a:node.cond), self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_or(node)
  return printf('(%s || %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_and(node)
  return printf('(%s && %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_equal(node)
  return printf('(%s == %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_equalci(node)
  return printf('(%s ==? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_equalcs(node)
  return printf('(%s ==# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nequal(node)
  return printf('(%s != %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nequalci(node)
  return printf('(%s !=? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nequalcs(node)
  return printf('(%s !=# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_greater(node)
  return printf('(%s > %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_greaterci(node)
  return printf('(%s >? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_greatercs(node)
  return printf('(%s ># %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_gequal(node)
  return printf('(%s >= %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_gequalci(node)
  return printf('(%s >=? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_gequalcs(node)
  return printf('(%s >=# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_smaller(node)
  return printf('(%s < %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_smallerci(node)
  return printf('(%s <? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_smallercs(node)
  return printf('(%s <# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_sequal(node)
  return printf('(%s <= %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_sequalci(node)
  return printf('(%s <=? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_sequalcs(node)
  return printf('(%s <=# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_match(node)
  return printf('(%s =~ %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_matchci(node)
  return printf('(%s =~? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_matchcs(node)
  return printf('(%s =~# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nomatch(node)
  return printf('(%s !~ %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nomatchci(node)
  return printf('(%s !~? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_nomatchcs(node)
  return printf('(%s !~# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_is(node)
  return printf('(%s is %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_isci(node)
  return printf('(%s is? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_iscs(node)
  return printf('(%s is# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_isnot(node)
  return printf('(%s isnot %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_isnotci(node)
  return printf('(%s isnot? %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_isnotcs(node)
  return printf('(%s isnot# %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_add(node)
  return printf('(%s + %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_subtract(node)
  return printf('(%s - %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_concat(node)
  return printf('(%s . %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_multiply(node)
  return printf('(%s * %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_divide(node)
  return printf('(%s / %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_remainder(node)
  return printf('(%s %% %s)', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_not(node)
  return printf('(! %s)', self.compile(a:node.left))
endfunction

function! s:VimlCompiler.compile_plus(node)
  return printf('(+ %s)', self.compile(a:node.left))
endfunction

function! s:VimlCompiler.compile_minus(node)
  return printf('(- %s)', self.compile(a:node.left))
endfunction

function! s:VimlCompiler.compile_subscript(node)
  return printf('(%s[%s])', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_slice(node)
  let r0 = a:node.rlist[0] is s:NIL ? '' : self.compile(a:node.rlist[0])
  let r1 = a:node.rlist[1] is s:NIL ? '' : self.compile(a:node.rlist[1])
  return printf('(%s[%s : %s])', self.compile(a:node.left), r0, r1)
endfunction

function! s:VimlCompiler.compile_dot(node)
  return printf('%s.%s', self.compile(a:node.left), self.compile(a:node.right))
endfunction

function! s:VimlCompiler.compile_call(node)
  let rlist = map(a:node.rlist, 'self.compile(v:val)')
  return printf('(%s(%s))', self.compile(a:node.left), join(rlist, ', '))
endfunction

function! s:VimlCompiler.compile_number(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_string(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_list(node)
  let value = map(a:node.value, 'self.compile(v:val)')
  if empty(value)
    return '([])'
  else
    return printf('([%s])', join(value, ', '))
  endif
endfunction

function! s:VimlCompiler.compile_dict(node)
  let value = map(a:node.value, 'self.compile(v:val[0]) . " : " . self.compile(v:val[1])')
  if empty(value)
    return '({})'
  else
    return printf('({%s})', join(value, ' , '))
  endif
endfunction

function! s:VimlCompiler.compile_option(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_env(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_reg(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_curlynamepart(node)
  return a:node.value
endfunction

function! s:VimlCompiler.compile_curlynameexpr(node)
  return '{' . self.compile(a:node.value) . '}'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker

" ___Revitalizer___
" NOTE: below code is generated by :Revitalize.
" Do not mofidify the code nor append new lines
if v:version > 703 || v:version == 703 && has('patch1170')
  function! s:___revitalizer_function___(fstr) abort
    return function(a:fstr)
  endfunction
else
  function! s:___revitalizer_SID() abort
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze____revitalizer_SID$')
  endfunction
  let s:___revitalizer_sid = '<SNR>' . s:___revitalizer_SID() . '_'
  function! s:___revitalizer_function___(fstr) abort
    return function(substitute(a:fstr, 's:', s:___revitalizer_sid, 'g'))
  endfunction
endif

let s:___revitalizer_functions___ = {'_vital_depends': s:___revitalizer_function___('s:_vital_depends'),'_vital_loaded': s:___revitalizer_function___('s:_vital_loaded'),'import': s:___revitalizer_function___('s:import')}

unlet! s:___revitalizer_sid
delfunction s:___revitalizer_function___

function! vital#_powerassert#Vim#VimlCompiler#import() abort
  return s:___revitalizer_functions___
endfunction
" ___Revitalizer___
