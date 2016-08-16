let s:PowerAssert = vital#powerassert#new().import('Vim.PowerAssert')

function! powerassert#import() abort
  return s:PowerAssert
endfunction

function! powerassert#assert(...) abort
  return call(s:PowerAssert.assert, a:000, {})
endfunction

function! powerassert#define(...) abort
  return call(s:PowerAssert.define, a:000, {})
endfunction
