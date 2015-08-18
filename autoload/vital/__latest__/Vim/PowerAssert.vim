"=============================================================================
" FILE: autoload/vital/__latest__/Vim/PowerAssert.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:V = a:V
  let s:VimlParser = s:V.import('Vim.VimlParser').import()
  let s:VimlCompiler = s:V.import('Vim.VimlCompiler').import()
  let s:List = s:V.import('Data.List')
endfunction

function! s:_vital_depends() abort
  return ['Vim.VimlParser', 'Vim.VimlCompiler', 'Data.List']
endfunction

" @__debug__ Bool Do not run anything if it's false
"_@_pseudo_throw__ Bool Echo messages, then throw abort exception if it's true
" or just `:throw` them.(`:throw` cannot output message with breaklines).
" NOTE: if someone `unlet` g:__vital_power_assert_config, it throws exception
" in production regardless config so use `get()` to get global config
function! s:_config() abort
  return extend({
  \   '__debug__': 0,
  \   '__pseudo_throw__': 1
  \ }, get(g:, '__vital_power_assert_config', {}))
endfunction

function! s:define(cmdname) abort
  let cmd = printf("'command!' '-nargs=*' '%s' ':execute' \"%s(<q-args>)\"", a:cmdname, s:_funcname('s:assert'))
  return 'execute ' . cmd
endfunction

" RETURN: command to execute (s:_assert()) to evaluate given expression
" in the same scope with caller's one
" TODO: support additional message
function! s:assert(expr_str) abort
  if s:_config().__debug__
    " assert !empty(empty_str)
    let _assert = s:_funcname('s:_assert')
    let args = printf('%s, %s', a:expr_str, string(a:expr_str))
    let rhs = escape(printf('%s(%s)', _assert, args), '"')
    return 'execute "execute" "' . rhs . '"'
  else
    return ''
  endif
endfunction

" @bool: evaluated expr_str
" RETURN: throw command which display graphical assertion result if bool is
" falsy
function! s:_assert(bool, expr_str) abort
  " assert !empty(empty_str)
  if ! a:bool
    " Aggregate nodes to evaluate which we want to inspect and eval in the
    " same scope with caller's one by returnign comamnd with nodes to eval as
    " arguments.
    let nodes = map(s:_aggregate_nodes_to_eval(a:expr_str), 's:_node_to_eval_str(v:val)')
    let _throw_cmd = s:_funcname('s:_throw_cmd')
    let args = printf('%s, [%s]', string(a:expr_str), join(nodes, ', '))
    let rhs = escape(printf('%s(%s)', s:_funcname('s:_throw_cmd'), args), '"')
    return 'execute "execute" "' . rhs . '"'
  else
    return ''
  endif
endfunction

" RETURN: generate pseudo-throw command with graphical assertion result
" from evaluated_nodes which evaluated in the same scope with caller's one
function! s:_throw_cmd(whole_expr, evaluated_nodes) abort
  let msgs = s:_build_assertion_graph(a:whole_expr, a:evaluated_nodes)
  if s:_config().__pseudo_throw__
    return s:_pseudo_throw_cmd(join(msgs, "\n"))
  else
    return s:_build_actual_throw_cmd(join(msgs, "\n"))
  endif
endfunction

" Vim cannot output multiple lines with `:echom` nor `:throw`, so execute
" `:echom` each line and execute `:throw` additionally just for aborting
function! s:_pseudo_throw_cmd(msg, ...) abort
  let do_throw = get(a:, 1, 1)
  return join([
  \   'try',
  \   '  throw ' . string(a:msg),
  \   'catch',
  \   '  echohl ErrorMsg',
  \   '  echom v:throwpoint',
  \   '  for s:__vital_assert_line in split(v:exception, "\n")',
  \   '    echom s:__vital_assert_line',
  \   '  endfor',
  \   '  unlet s:__vital_assert_line',
  \   '  echohl None',
  \   'endtry'
  \ ] + (do_throw ? ['throw "vital: PowerAssert: abort"'] : []), '|')
endfunction

function! s:_build_actual_throw_cmd(msg) abort
  return printf('throw "vital: PowerAssert:\n%s"', escape(a:msg, '"'))
endfunction

" @evaluated_nodes List[{'col': Number, 'expr': Expr}]
function! s:_build_assertion_graph(whole_expr, evaluated_nodes) abort
  let lines = [a:whole_expr]
  let cols = sort(map(copy(a:evaluated_nodes), 'v:val.pos.col'), 'n')
  let lines += [s:_cols_line(cols)]
  for node_with_pos in reverse(s:List.sort_by(a:evaluated_nodes, 'v:val.pos.col'))
    let col = s:List.pop(cols)
    let line = s:_cols_line(cols)
    let line .= repeat(' ', col - len(line) - 1) . string(node_with_pos.expr)
    let lines += [line]
  endfor
  return lines
endfunction

" >>> echo s:_cols_line([1, 2, 5, 10])
" ||  |    |
function! s:_cols_line(cols) abort
  let max = max(a:cols)
  let strs = map(range(max), '" "')
  for col in a:cols
    let strs[col - 1] = '|'
  endfor
  return join(strs, '')
endfunction

" RETURN: [Node, ...]
" NODE: which could be evaluated
function! s:_flatten_evaluatable_node(expr_node) abort
  let stack = [a:expr_node]
  let flat_nodes = []

  while !empty(stack)
    let node = s:List.pop(stack)
    if node.type isnot# s:VimlParser.NODE_CURLYNAME
      call s:List.push(flat_nodes, node)
    endif
    let stack += s:_next_evaluatable_node(node)
  endwhile

  return flat_nodes
endfunction

" @return List[Node]
function! s:_next_evaluatable_node(node) abort
  if a:node.type == s:VimlParser.NODE_TOPLEVEL
    " XXX: ???
    return []
  " elseif a:node.type == s:VimlParser.NODE_COMMENT
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_EXCMD
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_FUNCTION
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_DELFUNCTION
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_RETURN
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_EXCALL
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_LET
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_UNLET
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_LOCKVAR
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_UNLOCKVAR
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_IF
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_WHILE
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_FOR
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_CONTINUE
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_BREAK
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_TRY
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_THROW
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_ECHO
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_ECHON
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_ECHOHL
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_ECHOMSG
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_ECHOERR
  "   return []
  " elseif a:node.type == s:VimlParser.NODE_EXECUTE
  "   return []
  elseif a:node.type == s:VimlParser.NODE_TERNARY
    return [a:node.cond, a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_OR
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_AND
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_EQUAL
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_EQUALCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_EQUALCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NEQUAL
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NEQUALCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NEQUALCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GREATER
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GREATERCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GREATERCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GEQUAL
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GEQUALCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_GEQUALCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SMALLER
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SMALLERCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SMALLERCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SEQUAL
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SEQUALCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SEQUALCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_MATCH
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_MATCHCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_MATCHCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NOMATCH
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NOMATCHCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NOMATCHCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_IS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ISCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ISCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ISNOT
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ISNOTCI
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ISNOTCS
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_ADD
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SUBTRACT
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_CONCAT
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_MULTIPLY
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_DIVIDE
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_REMAINDER
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_NOT
    return [a:node.left]
  elseif a:node.type == s:VimlParser.NODE_PLUS
    return [a:node.left]
  elseif a:node.type == s:VimlParser.NODE_MINUS
    return [a:node.left]
  elseif a:node.type == s:VimlParser.NODE_SUBSCRIPT
    return [a:node.left, a:node.right]
  elseif a:node.type == s:VimlParser.NODE_SLICE
    return [a:node.left] + filter(copy(a:node.rlist), 'type(v:val) is# type({})')
  elseif a:node.type == s:VimlParser.NODE_DOT
    " Right is just a accessor
    return [a:node.left]
  elseif a:node.type == s:VimlParser.NODE_CALL
    let funcname = (a:node.left.type == s:VimlParser.NODE_CURLYNAME ? [a:node.left] : [])
    return funcname + a:node.rlist
  elseif a:node.type == s:VimlParser.NODE_NUMBER
    return []
  elseif a:node.type == s:VimlParser.NODE_STRING
    return []
  elseif a:node.type == s:VimlParser.NODE_LIST
    return a:node.value
  elseif a:node.type == s:VimlParser.NODE_DICT
    return s:List.flatten(a:node.value)
  elseif a:node.type == s:VimlParser.NODE_OPTION
    return []
  elseif a:node.type == s:VimlParser.NODE_IDENTIFIER
    return []
  elseif a:node.type == s:VimlParser.NODE_CURLYNAME
    return filter(copy(a:node.value), 'v:val.curly is# 1')
  elseif a:node.type == s:VimlParser.NODE_ENV
    return []
  elseif a:node.type == s:VimlParser.NODE_REG
    return []
  elseif a:node.type == s:VimlParser.NODE_CURLYNAMEPART
    return []
  elseif a:node.type == s:VimlParser.NODE_CURLYNAMEEXPR
    return type(a:node.value.value) is# type([]) ? [a:node.value] : []
  else
    throw printf('PowerAssert: unknown node: %s', string(a:node))
  endif
endfunction

function! s:_filter_out_primitive_node(nodes) abort
  let excludes = [
  \   s:VimlParser.NODE_NUMBER,
  \   s:VimlParser.NODE_STRING,
  \   s:VimlParser.NODE_LIST,
  \   s:VimlParser.NODE_DICT
  \ ]
  return filter(copy(a:nodes), 'index(excludes, v:val.type) is# -1')
endfunction

" To eval `expr` and get `pos` and evaluated expression
function! s:_compile_expr_with_pos(node) abort
  return {'pos': a:node.pos, 'expr': s:_compile(a:node)}
endfunction

function! s:_node_to_eval_str(node) abort
  return printf("{'pos': %s, 'expr': %s}", string(a:node.pos), a:node.expr)
endfunction

function! s:_compile(expr_node) abort
  let c = s:VimlCompiler.new()
  return c.compile(deepcopy(a:expr_node))
endfunction

function! s:_parse_expr(expr_str) abort
  " assert !empty(empty_str)
  let reader = s:VimlParser.StringReader.new(a:expr_str)
  let expr_parser = s:VimlParser.ExprParser.new(reader)
  return expr_parser.parse()
endfunction

function! s:_aggregate_nodes_to_eval(expr_str) abort
  " assert !empty(empty_str)
  let node = s:_parse_expr(a:expr_str)
  let nodes_to_eval = s:_filter_out_primitive_node(s:_flatten_evaluatable_node(node))
  return map(nodes_to_eval, 's:_compile_expr_with_pos(v:val)')
endfunction

function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction

let s:_s = '<SNR>' . s:_SID() . '_'

function! s:_funcname(funcname) abort
  return substitute(a:funcname, 's:', s:_s, 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
