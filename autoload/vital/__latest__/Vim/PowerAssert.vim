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
endfunction

function! s:_vital_depends() abort
  return ['Vim.VimlParser', 'Vim.VimlCompiler']
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
