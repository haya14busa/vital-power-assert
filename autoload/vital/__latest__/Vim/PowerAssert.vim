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

function! s:assert(expr_str) abort
  let args = printf('(%s, %s)', a:expr_str, string(a:expr_str))
  return 'execute "execute" "' . escape((s:_funcname('s:_assert') . args), '"') . '"'
endfunction

function! s:_assert(bool, expr_str) abort
  if ! a:bool
    let nodes = s:_inspect(a:expr_str)
    let args = map(nodes, 's:_node_to_evaluated_node_str(v:val)')
    return 'execute "execute" "' . escape((s:_funcname('s:_throw_cmd') . printf('(%s, [%s])', string(a:expr_str), join(args, ', '))), '"') . '"'
  else
    return ''
  endif
endfunction

" To eval `expr` and get `col` and evaluated expression
function! s:_node_to_evaluated_node_str(node) abort
  return printf("{'col': %s, 'expr': %s}", a:node.pos.col, a:node.expr)
endfunction

function! s:_throw_cmd(whole_expr, evaluated_nodes) abort
  let msgs = s:_build_assertion_graph(a:whole_expr, a:evaluated_nodes)
  return s:_pseudo_throw_cmd(join(msgs, "\n"))
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

" @evaluated_nodes List[{'col': Number, 'expr': Expr}]
function! s:_build_assertion_graph(whole_expr, evaluated_nodes) abort
  let lines = [a:whole_expr]
  let cols = sort(map(copy(a:evaluated_nodes), 'v:val.col'), 'n')
  let lines += [s:_cols_to_str(cols)]
  for inspect in reverse(s:List.sort_by(a:evaluated_nodes, 'v:val.col'))
    let col = s:_pop(cols)
    let line = s:_cols_to_str(cols)
    let line .= repeat(' ', col - len(line) - 1) . string(inspect.expr)
    let lines += [line]
  endfor
  return lines
endfunction

function! s:_cols_to_str(cols) abort
  let max = max(a:cols)
  let strs = map(range(max), '" "')
  for col in a:cols
    let strs[col - 1] = '|'
  endfor
  return join(strs, '')
endfunction

" RETURN: [Node, ...]
" NODE: which could be evaluated
function! s:_flatten_node(expr_node) abort
  let stack = [a:expr_node]
  let flat_nodes = []

  while !empty(stack)
    let node = s:_pop(stack)
    if node.type isnot# s:VimlParser.NODE_CURLYNAME
      call s:_push(flat_nodes, node)
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
    return [a:node.left] + a:node.rlist
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
    return s:_flatten(a:node.value)
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
    return []
  else
    throw printf('PowerAssert: unknown node: %s', string(a:node))
  endif
endfunction

function! s:_filter_to_inspect_nodes(nodes) abort
  let excludes = [
  \   s:VimlParser.NODE_NUMBER,
  \   s:VimlParser.NODE_STRING,
  \   s:VimlParser.NODE_LIST,
  \   s:VimlParser.NODE_DICT
  \ ]
  return filter(copy(a:nodes), 'index(excludes, v:val.type) is# -1')
endfunction

function! s:_to_expr_with_pos(node) abort
  return {'pos': a:node.pos, 'expr': s:_compile(a:node)}
endfunction

function! s:_compile(expr_node) abort
  let c = s:VimlCompiler.new()
  return c.compile(a:expr_node)
endfunction

function! s:_parse_expr(expr_str) abort
  let reader = s:VimlParser.StringReader.new(a:expr_str)
  let expr_parser = s:VimlParser.ExprParser.new(reader)
  return expr_parser.parse()
endfunction

function! s:_inspect(expr_str) abort
  let node = s:_parse_expr(a:expr_str)
  return map(s:_filter_to_inspect_nodes(s:_flatten_node(node)), 's:_to_expr_with_pos(v:val)')
endfunction

function! s:_pop(list) abort
  return remove(a:list, -1)
endfunction

function! s:_push(list, val) abort
  call add(a:list, a:val)
  return a:list
endfunction

" Take each elements from lists to a new list.
function! s:_flatten(list, ...) abort
  let limit = a:0 > 0 ? a:1 : -1
  let memo = []
  if limit == 0
    return a:list
  endif
  let limit -= 1
  for Value in a:list
    let memo +=
          \ type(Value) == type([]) ?
          \   s:_flatten(Value, limit) :
          \   [Value]
    unlet! Value
  endfor
  return memo
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
