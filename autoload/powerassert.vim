let s:PowerAssert = vital#powerassert#new().import('Vim.PowerAssert')

function! powerassert#import() abort
  return s:PowerAssert
endfunction
