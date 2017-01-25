" ingo/fs/path/split.vim: Functions for splitting a file system path.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"   - ingo/str.vim autoload script
"
" Copyright: (C) 2014-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.002	30-Apr-2015	Add ingo#fs#path#split#Contains().
"   1.019.001	22-May-2014	file creation

function! ingo#fs#path#split#AtBasePath( filespec, basePath )
"******************************************************************************
"* PURPOSE:
"   Split off a:basePath from a:filespec. The check will be done on normalized
"   paths.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec.
"   a:basePath  Filespec to the base directory that contains a:filespec.
"* RETURN VALUES:
"   Remainder of a:filespec, after removing a:basePath, or empty List if
"   a:filespec did not start with a:basePath.
"******************************************************************************
    let l:filespec = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:filespec, '/'), '')
    let l:basePath = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:basePath, '/'), '')
    if ingo#str#StartsWith(l:filespec, l:basePath, ingo#fs#path#IsCaseInsensitive(l:filespec))
	return strpart(a:filespec, len(l:basePath))
    endif
    return []
endfunction

function! ingo#fs#path#split#Contains( filespec, fragment )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec contains a:fragment anywhere. To match entire
"   (anchored) path fragments, pass a fragment surrounded by forward slashes
"   (e.g. "/foo/"); you can always use forward slashes, as these will be
"   internally normalized.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec to be examined.
"   a:fragment  Path fragment that may be contained inside a:filespec.
"* RETURN VALUES:
"   1 if contained, 0 if not.
"******************************************************************************
    let l:filespec = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:filespec, '/'), '')
    let l:fragment = ingo#fs#path#Normalize(a:fragment, '/')
    return ingo#str#Contains(l:filespec, l:fragment, ingo#fs#path#IsCaseInsensitive(l:filespec))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
