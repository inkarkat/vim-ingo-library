INGO-LIBRARY
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This library contains common autoload functions that are used by almost all of
my plugins (http://www.vim.org/account/profile.php?user_id=9713). Instead of
duplicating the functionality, or installing potentially conflicting versions
with each plugin, this one core dependency fosters a lean Vim runtime and
easier plugin updates.

Separating common functions is explicitly recommended by Vim; see
write-library-script. The autoload mechanism was created to make this
really easy and efficient. Only those scripts that contain functions that are
actually used are loaded, the rest is ignored; it just "wastes" the space on
disk. (Not using autoload functions, and duplicating utility functions in the
plugin script itself, now that would be truly bad.)

Still, if you only use one or few of my plugins, yes, this might look
wasteful. However, I have published an awful lot of plugins (most of which now
use ingo-library), and intend to continue to do so. Considering that, the
decision to extract the common functionality (which caused a lot of effort for
me) benefits both users (no duplication, no incompatibilities, faster updates)
and me (less overall effort in maintaining, more time for features). Please
keep that in mind before complaining about this dependency.

Furthermore, several other authors have been following the same approach:

### RELATED WORKS

Other authors have published separate support libraries, too:

- genutils ([vimscript #197](http://www.vim.org/scripts/script.php?script_id=197)) by Hari Krishna Dara
- lh-vim-lib ([vimscript #214](http://www.vim.org/scripts/script.php?script_id=214)) by Luc Hermitte
- cecutil ([vimscript #1066](http://www.vim.org/scripts/script.php?script_id=1066)) by DrChip
- tlib ([vimscript #1863](http://www.vim.org/scripts/script.php?script_id=1863)) by Thomas Link
- TOVL ([vimscript #1963](http://www.vim.org/scripts/script.php?script_id=1963)) by Marc Weber
- l9 ([vimscript #3252](http://www.vim.org/scripts/script.php?script_id=3252)) by Takeshi Nishida
- anwolib ([vimscript #3800](http://www.vim.org/scripts/script.php?script_id=3800)) by Andy Wokula
- vim-misc ([vimscript #4597](http://www.vim.org/scripts/script.php?script_id=4597)) by Peter Odding
- maktaba (https://github.com/google/maktaba) by Google
- vital (https://github.com/vim-jp/vital.vim) by the Japanese Vim user group
- underscore.vim ([vimscript #5149](http://www.vim.org/scripts/script.php?script_id=5149)) by haya14busa provides functional
  programming functions and depends on the (rather complex) vital library

There have been initiatives to gather and consolidate useful functions into a
"standard Vim library", but these efforts have mostly fizzled out.

USAGE
------------------------------------------------------------------------------

    This library is mainly intended to be used by my own plugins. However, I try
    to maintain backwards compatibility as much as possible. Feel free to use the
    library for your own plugins and customizations, too. I'd also like to hear
    from you if you have additions or comments.

### EXCEPTION HANDLING

    For exceptional conditions (e.g. cannot locate window that should be there)
    and programming errors (e.g. passing a wrong variable type to a library
    function), error strings are |:throw|n. These are prefixed with (something
    resembling) the short function name, so that it's possible to :catch these
    and e.g. convert them into a proper error (e.g. via
    ingo#err#SetCustomException()).

CONFIGURATION
------------------------------------------------------------------------------

The filespec to the external "date" command can be set via:

    let g:IngoLibrary_DateCommand = 'date'

The preferred date format used by ingo#date#format#Preferred() can be set to a
strftime() format via:

    let g:IngoLibrary_PreferredDateFormat = '%x'

The size of the file cache (in bytes) used by ingo#file#GetLines() can be set
via:

    let g:IngoLibrary_FileCacheMaxSize = 1048576

The string used as a replacement for truncated text can be set via:

    let g:IngoLibrary_TruncateEllipsis = "\u2026"

The check for special windows in ingo#window#special#IsSpecialWindow() can be
customized via a List of Expressions or Funcrefs that are passed the window
number, and which should return a boolean flag. If any predicate is true, the
window is deemed special.

    let g:IngoLibrary_SpecialWindowPredicates =
    \   ['bufname(winbufnr(v:val)) =~# "^\\[\\%(Scratch\\|clipboard\\)\\]$"']

ingo#plugin#marks#Reserve() by default uses any unused mark. You can instead
assign a fixed set of marks that will be available for plugins via:

    let g:IngoLibrary_Marks = 'abcABC'

Some special filenames are caught by BufNewFile|,|BufRead autocmds and
translated into existing files. ingo#cmdargs#glob#Resolve() can be taught
those patterns by configuring a List of Funcrefs or expressions in
g:IngoLibrary\_SpecialFilePredicates that take a single filespec argument /
v:val and return whether this is an existing file. This will then correct the
statistics information returned by the function.
By default, includes any filespec that starts with a "protocol:/" (e.g. scp://
for netrw), and also file:lnum[:column] special filenames if
https://github.com/bogado/file-line is installed.

The ingo#text#InsertHere() function is often used to insert text at the cursor
position by plugins that don't want to offer separate insert / append mappings
(comparable to p|/|P pasting). The function tries to find a meaningful
insertion point. Its strategy can be tweaked via the following values:
- insert1:  at the beginning of the line if the cursor is in column 1, else
            appending after the character the cursor is on.
- append$:  appending after the character if the cursor is at the end of the
            line (with 'virtualedit' having "onemore": one beyond the end,
            with "all": always insert before the cursor), else inserting
            before the character the cursor is on.
- insert:   always inserting before the character the cursor is on
- append:   always appending after the character the cursor is on

If you use some operator-pending mappings as hooks into default motions (e.g.
: or /) that still maintain the original functionality,
ingo#query#get#Motion() can be instructed to ignore those mappings and instead
treat them as the built-in motions (i.e. still query the command-line or
search pattern). Define those keys you want ignored as keys in a Dict (values
don't matter):

    let g:IngoLibrary_QueryMotionIgnoredMotions = {':': 1, '/': 1, '?': 1}

If you have custom operator-pending mappings that do some tricks like
obtaining additional characters until they're done and moving the cursor,
define those keys as keys, and an appendage pattern as value (or the empty
String if there're no additional keys).
The appendage patterns will capture additional keys until either the pattern
does not match any longer (the motion then is deemed invalid and aborts), or
until the first capture group is non-empty (the motion then is deemed
complete).

    let g:IngoLibrary_QueryMotionCustomMotions = {'key': 'patter\(n\)'}

Motions can be forced to be character- / line- / blockwise (forced-motion).
If you have mapped alternatives for v / V / CTRL-V, define them as keys in:

    let g:IngoLibrary_QueryMotionCustomMotionModifiers = {"\<C-q>": 1}

If you've remapped the c\_CTRL-K trigger key for digraphs, you can adapt the
digraph detection by ingo#query#get#CharOrDigraph() and
ingo#query#get#[Valid]Char() to the changed mapping via:

    let g:IngoLibrary_DigraphTriggerKey = "\<C-k>"

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-ingo-library
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim ingo-library*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-ingo-library/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### 1.044   08-Apr-2022
- Add ingo#cursor#IsBeyondEndOfLine() variant of ingo#cursor#IsAtEndOfLine().
- ENH: Allow to customize the insertion point of ingo#text#InsertHere() via
  g:IngoLibrary\_InsertHereStrategy.
- CHG: Split ingo#subst#FirstSubstitution() into
  ingo#subst#FirstMatchingSubstitution() and
  ingo#subst#FirstChangingSubstitution().
- Add ingo#text#IsInsert().
- ingo#cmdargs#range#Parse(): BUG: Return [] as documented instead of ['', '',
  '', '', ''] on empty a:commandLine.
- Add ingo/plugin/historyrecall.vim module.
- Add ingo/str/remove.vim module.
- Add ingo#lines#Delete() variant of ingo#lines#Replace().
- ingo#plugin#register#{Set,PutContents}(): ENH: Also add the register
  contents to the search history when the target register is "/".
- Add ingo#query#motion#Get().
- Add ingo#compat#getcharstr().
- Add ingo#regexp#Anchored().
- CHG: ingo#query#get#[Writable]Register(): Turn a:errorRegister and
  a:invalidRegisterExpr into option Dict values and add
  a:options.additionalValidExpr
- Add ingo/digraph.vim module.
- Add ingo#query#get#CharOrDigraph().
- ENH: ingo#query#get#[Valid]Char() takes digraphs by default; can be disabled
  via a:options.isAllowDigraphs = 0.
- Add ingo#syntaxitem#HasHighlighting() from SameSyntaxMotion.vim.
- Add ingo#cursor#IsOnWhitespace() and ingo#cursor#IsOnEmptyLine().
- ingo#{area,text}#frompattern#Get(): ENH: Add cursorPos and additional
  arguments to context object, allow Predicate to influence returned result.
- ingo#area#frompattern#Get(): BUG: a:matchCount uninitialized
- Add ingo/print/highlighted.vim module (formerly unpublished separate
  EchoLine.vim autoload script).
- ingo#option#listchars#Render(): ENH: Add a:options.tabWidth.
- ingo#option#listchars#Render(): CHG: Deprecate a:isTextAtEnd argument, use
  a:options.isTextAtEnd now.
- ingo#option#listchars#Render(): FIX: space rendering eclipses trail
- ingo#option#listchars#Render(): ENH: Add a:options.isTextAtStart and render
  lead listchars option value (since Vim 8.2.2454).
- ingo#print#highlighted#Line(): Use 'listchars' to render tabs and spaces,
  but now only if 'list' is on. Also support "nbsp", "lead", and "eol"
  options.
- ingo#range#Get(): Don't clobber the search history.
- ingo#range#lines#Get(): Allow a:options with fallback to the
  old single a:isGetAllRanges flag and don't clobber the search history by
  default, unless a:options.isKeepPatterns = 0.
- ingo#ftplugin#onbufwinenter#Execute(): ENH: Also allow Funcref a:Action.
- ingo#ftplugin#onbufwinenter#Execute(): ENH: Add a:when = "delayed".
- ingo#escape#command#map[un]escape(), ingo#escape#mapping#keys(): Also
  convert between newline and &lt;CR&gt;.
- Add ingo/convert.vim module with ingo#convert#ToSingleLineString().

##### 1.043   04-Feb-2022
- Minor: Actually support no-argument form of
  ingo#query#get#[Writable]Register(), the documentation already states that
  the a:errorRegister defaults to the empty string.
- Add ingo/subs/apply.vim module.
- Add ingo#escape#file#CmdlineSpecialEscape().
- Add ingo#buffer#IsWritable().
- Deprecated: ingo#subst#expr#emulation#Substitute() is now available as a
  compat function ingo#compat#substitution#RecursiveSubstitutionExpression()
  because since Vim 8.0.20, the regexp engine is reentrant.
- Add ingo#hlgroup#Get{Foreground,Background,}Color().
- ingo#list#lcs#Find{All,Longest}Common(), ingo#subs#BraceCreation#FromList():
  Add optional a:isIgnoreCase argument to ignore case differences when
  searching for common substrings.
- Add ingo#window#special#HasOtherDiffWindow() variant of
  ingo#window#special#HasDiffWindow().
- dirforaction: BUG: Passed filenames with escaped glob characters not handled
  correctly; need to use the unescaped filename for l:isAbsoluteFilename
  check.
- dirforaction: ENH: Add a:parameters.completeFunctionHook.
- Add ingo/escape/mapping.vim module.
- Add ingo/window/iterate.vim module.
- Add ingo#hlgroup#GetApplicableColorModes().
- ingo#buffer#VisibleList(): ENH: Allow passing range of tab pages to be
  considered.
- Add ingo/list/transform.vim module.
- Add ingo#buffer#NameOrDefault().
- Add ingo/buffers.vim module.
- Add ingo/list/reduce.vim module.
- Add ingo#compat#getenv() and ingo#compat#setenv().
- Add ingo#buffer#IsScratch().
- Add ingo#encoding#IsUnicode().
- Add ingo/buffer/network.vim module.
- Add ingo/ranges.vim module (originally from AdvancedSorters.vim).
- ingo#file#GetLines(): Robustness: Empty a:filespec throws E17
- Add ingo#subst#Recurringly().
- Add ingo#text#Append() variant of ingo#text#Insert().
- Add ingo/text/surroundings.vim modules.
- Add ingo#regexp#EscapeLiteralReplacement().

##### 1.042   03-Aug-2020
- BUG: ingo#join#Lines() inserts the separator before the line's last
  character when joining with a following empty line and ! a:isKeepSpace.
- Support List of precisions in ingo#units#Format() and default to not showing
  a fraction for bytes in ingo#units#FormatBytesDecimal() and
  ingo#units#FormatBytesBinary() (as there are no fractional bytes).
- Add ingo#regexp#collection#LargeRange().
- Add ingo#text#InsertHere().
- Expose ingo#mapmaker#OpfuncExpression(); it can avoid duplication of
  ...#Expression() functions in many plugins.
- Add ingo/change/processed.vim module.
- CHG: ingo#area#frompattern#GetCurrent() now takes optional arguments as
  Dictionary and adds a:options.firstLnum and a:options.lastLnum.
- CHG: ingo#text#frompattern#GetCurrent() now take the optional a:currentPos
  as Dictionary and adds a:options.firstLnum, a:options.lastLnum, and
  a:options.returnValueOnNoSelection.

##### 1.041   12-Mar-2020
- Add ingo/register/pending.vim module.
- ingo#regexp#EscapeLiteralText(): Make second argument
  (a:additionalEscapeCharacters) optional; many clients don't need this.
- ingo#cmdargs#register#Parse{Ap,Pre}pendedWritableRegister(): ENH: Allow
  using the a:directSeparator default while supplying a:isPreferText by
  passing an empty List.
- Introduce g:IngoLibrary\_SpecialFilePredicates customization for
  ingo#cmdargs#glob#Resolve().
- ingo#selection#Get{In,Ex}clusiveEndPos(): Prevent "E951: \\% value too large"
  by checking line length. This condition typically happens with a linewise
  selection (where the column is 2147483647).
- Add ingo#window#quickfix#GetOtherList() variant of
  ingo#window#quickfix#GetList() that gets the quickfixType passed in.
- Add ingo#window#quickfix#CmdPre() and ingo#window#quickfix#CmdPost().
- Add optional a:Predicate argument to ingo#area#frompattern#Get() and
  ingo#text#frompattern#Get(). Additionally, the a:isOnlyFirstMatch and
  a:isUnique arguments are optional now, too.
- Add ingo#str#trcd() variant of ingo#str#trd().
- Add ingo#plugin#cmdcomplete#dirforaction#setup().
- Add ingo#fs#path#IsPath().
- ingo#plugin#cmdcomplete#dirforaction#setup(): ENH: Use special completion
  that only returns directories if a:parameters.action is "chdir".
- Add ingo/regexp/parse.vim module.
- CHG: Move ingo#regexp#multi#Expr() to ingo#regexp#parse#MultiExpr().
- ingo#regexp#deconstruct#ToQuasiLiteral() also covers new
  ingo#regexp#deconstruct#TranslateSingleCharacterAtoms() and
  ingo#regexp#deconstruct#RemoveOtherAtoms().
- Add ingo/list/merge.vim module.
- Add ingo#collections#{CharacterCount,StringDisplayWidth}{Asc,Desc}Sort().
- FIX: ingo#smartcase#IsSmartCasePattern() and ingo#smartcase#Undo() now also
  handle the smartcased single all-lower or -uppercase alphabetic word special
  case.

##### 1.040   31-Oct-2019
- Add ingo#str#TrimTrailing() variant of ingo#str#Trim().
- Add ingo#date#format#FilesystemCompatibleTimestamp() variant.
- Add ingo#window#quickfix#SetOtherList() generalization of
  ingo#window#quickfix#SetList().
- Add ingo#window#quickfix#GetName() and ingo#window#quickfix#GetPrefix().
- Add ingo#plugin#cmdcomplete#MakeFirstArgumentFixedListCompleteFunc() variant
  of ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc().
- Add ingo#change#virtcols#Get(), a variant of ingo#selection#virtcols#Get().
- Add ingo/plugin/register.vim module.

##### 1.039   10-Sep-2019
- Add ingo#date#format#Epoch().
- Add ingo#collections#SortOnFirstListElement() and
  ingo#collections#SortOnSecondListElement().
- Add ingo#range#sort#AscendingByStartLnum().
- Add ingo#buffer#scratch#CreateWithWriter().
- Add ingo#register#IsWritable().
- ingo/window/locate.vim: ENH: Support special a:winVarName of "bufnr" that
  allows searching for bufnr instead of window-local variables.
- ingo#window#switches#Win{Save,Restore}CurrentBuffer(): ENH: Also record /
  search in other tabpages if the new a:isSaveTabPage / a:isSearchTabPages is
  true.
- Add ingo#window#special#HasDiffWindow().
- Add ingo#funcref#UnaryIdentity().
- Add ingo#pos#Sort().
- Add ingo#area#frompattern#GetCurrent() and
  ingo#text#frompattern#GetCurrent(), variants of ...#GetAroundHere().
- Add ingo#selection#Get{Ex,In}clusiveEndPos().
- Add ingo#text#Replace(), a more generic variant of ingo#text#Remove().
- Add optional a:NextFilenameFuncref to
  ingo#buffer#scratch#Create\[WithWriter]().
- ENH: Also support Funcref a:contentsCommand / a:scratchCommand for
  ingo#buffer#generate#Create() and ingo#buffer#scratch#Create\[WithWriter]().
- Add ingo#buffer#scratch#converted#Create() to convert buffer contents to
  a scratch buffer with the possibility to sync back and
  ingo#ftplugin#converter#builder#EditAsFiletype() that can be used by
  filetype plugins to edit one filetype in an intermediate different format.
- ENH: Allow to preset reserved marks for ingo#plugin#marks#Reserve() via
  g:IngoLibrary\_Marks.
- ENH: ingo#selection#virtcols#Get() adds an effectiveEndVirtCol attribute.
- Add ingo#selection#virtcols#GetLimitingPatterns().
- Add ingo#regexp#virtcols#StartAnchorPattern() and
  ingo#regexp#virtcols#EndAnchorPattern().
- ENH: ingo#plugin#cmd#withpattern#CommandWithPattern(): Also support
  a:CommandTemplate Funcref argument.
- Add ingo#actions#ExecuteWithValOrFunc() variant of
  ingo#actions#EvaluateWithValOrFunc() that :executes the Action instead of
  eval()ing it.
- FIX: ingo#register#accumulate#ExecuteOrFunc(): Need to use
  ingo#actions#ExecuteWithValOrFunc(), not
  ingo#actions#EvaluateWithValOrFunc().
- ENH: ingo#cmdrangeconverter#LineToBufferRange(): Also allow Funcref argument
  for a function that takes the converted range.
- Add ingo/options/listchars.vim module.

##### 1.038   09-Jun-2019
- ingo#compat#maparg() escaping didn't consider &lt;; in fact, it needs to escape
  stand-alone &lt; and escaped \\&lt;, but not proper key notations like &lt;C-CR&gt;.
- FIX: Make ingo#cmdline#showmode#TemporaryNoShowMode() work again.
- Factor out ingo#msg#MsgFromCustomException().
- Add ingo#regexp#MakeWholeWordOrWORDSearch() variant.
- Add ingo#pos#Compare(), useful for sort().
- FIX: Handle corner cases in ingo#join#Lines().
  Return join success. Also do proper counting in ingo#join#Ranges().
- Add ingo#join#Range() variant of ingo#join#Ranges().
- FIX: ingo#comments#SplitAll(): isBlankRequired is missing from the returned
  List when there's no comment.
- Add ingo/comments/indent.vim module.

##### 1.037   28-Mar-2019
- Add ingo#dict#Make() (analog to ingo#list#Make()).
- Add ingo#selection#Set() and ingo#selection#Make().
- Add ingo#pos#Make4() and ingo#pos#Make2().
- Add ingo#change#Set().
- Add ingo#ftplugin#converter#builder#DifferentFiletype().
- Add ingo#plugin#cmdcomplete#MakeTwoStageFixedListAndMapCompleteFunc(), a
  more complex variant of ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc().
- Add ingo#ftplugin#converter#builder#Filter() variant of
  ingo#ftplugin#converter#builder#DifferentFiletype().
- Add ingo#str#Wrap().
- Add ingo#dict#FromValues().
- ENH: ingo#dict#FromKeys() can also take a ValueExtractor Funcref in addition
  to the static defaultValue.
- Add ingo#collections#FileModificationTimeSort().

##### 1.036   17-Mar-2019
- FIX: ingo#strdisplaywidth#strleft includes multi-width character that
  straddles the specified width. Need to exclude this one.
- Add ingo#strdisplaywidth#pad#Repeat\[Exact]().
- Make Unix date command used in ingo#date#epoch#ConvertTo() configurable via
  g:IngoLibrary\_DateCommand.
- ENH: Allow passing of a:truncationIndicator to
  ingo#avoidprompt#Truncate\[To]().
- Add ingo#fs#path#split#TruncateTo().
- Add ingo#str#TrimPattern() variant of ingo#str#Trim().
- Add ingo#date#epoch#Now().
- Add ingo#date#strftime().
- Add ingo#compat#trim().
- Add ingo#buffer#locate#OtherWindowWithSameBuffer().
- Add ingo#search#timelimited#FirstPatternThatMatchesInBuffer().
- Add optional a:isPreferText flag to
  ingo#cmdargs#register#Parse{Prepended,Appended}WritableRegister().
- Add ingo#comments#GetSplitIndentPattern() variant of
  ingo#comments#SplitIndentAndText() that just returns the pattern.
- Extract ingo#cmdrange#FromCount() from
  ingo#cmdrangeconverter#LineToBufferRange().
- Add ingo/plugin/cmd/withpattern.vim module.
- Add ingo/view.vim module.
- Add ingo#compat#commands#ForceSynchronousFeedkeys().
- Add ingo/plugin/persistence.vim module; implementation based on my mark.vim
  plugin.
- Add ingo#collections#SortOnOneAttribute(), ingo#collections#PrioritySort(),
  and ingo#collections#SortOnTwoAttributes().
- Add ingo/collections/recursive.vim module.
- ENH: ingo#cmdargs#range#Parse(): Add a:options.isOnlySingleAddress flag.
- ENH: Add ingo#cmdargs#range#ParsePrependedRange().
- Minor fixes to ingo#query#confirm#AutoAccelerators().
- Expose ingo#collections#fromsplit#MapOne().
- Add function/uniquify.vim module.
- Add ingo#compat#FromKey() for the reversing of ingo#compat#DictKey().
- Add ingo#collections#SortOnOneListElement(), a variant of
  ingo#collections#SortOnOneAttribute().
- Add ingo#regexp#MakeWholeWORDSearch() variant of
  ingo#regexp#MakeWholeWordSearch().
- Add ingo/file.vim module.
- Add ingo#cmdargs#pattern#PatternExpr().
- BUG: ingo#text#replace#Between() and ingo#text#replace#Area() mistakenly
  update current line instead of passed position.
- BUG: ingo#text#replace#Between() and ingo#text#replace#Area() cause "E684:
  list index out of range: 0" when the replacement text is empty.
- FIX: Off-by-one in ingo#area#IsEmpty(). Also check for invalid area.
- Add ingo#area#EmptyArea().
- FIX: Make ingo#pos#Before() return column 0 if passed a position with column
  1; this matches the behavior of ingo#pos#After(), which also returns a
  non-existent position directly after the last character, and this fits in
  well with the area functions.
- Add ingo#regexp#deconstruct#{Translate,Remove}CharacterClasses(),
  ingo#regexp#deconstruct#TranslateNumberEscapes(),
  ingo#regexp#deconstruct#TranslateBranches()  and include all translations in
  ingo#regexp#deconstruct#ToQuasiLiteral().
- FIX: Don't match optionally matched atoms \\%[] in
  ingo#regexp#collection#Expr().
- ENH: Add a:option.isCapture to ingo#regexp#collection#Expr().

##### 1.035   29-Sep-2018
- Add ingo#compat#commands#NormalWithCount().
- Add ingo#compat#haslocaldir().
- Add ingo/workingdir.vim module.
- Add ingo/selection/virtcols.vim module.
- Add ingo/str/list.vim module.
- Add ingo#funcref#AsString().
- Add ingo#compat#execute().
- Add ingo#option#GetBinaryOptionValue().
- Add ingo/buffer/ephemeral.vim module.
- Add ingo/lists/find.vim module.
- Add ingo/folds/containment.vim module.
- Add ingo/ftplugin/setting.vim module.
- Extract generic ingo#plugin#cmdcomplete#MakeCompleteFunc().
- Add ingo#fs#path#split#StartsWith() (we already had
  ingo#fs#path#split#EndsWith()).
- Add ingo#fs#path#Canonicalize().
- Add ingo#avoidprompt#EchoMsg() and ingo#avoidprompt#EchoMsgAsSingleLine().
- Tweak ingo#avoidprompt#MaxLength() algorithm; empirical testing showed that
  1 more needs to be subtracted if :set noshowcmd ruler. Thanks to an9wer for
  making me aware of this.
- CHG: Move ingo#list#Matches() to ingo#list#pattern#AllItemsMatch(). The
  previous name wasn't very clear.
- Add ingo#list#pattern#{First,All}Match\[Index]() functions.
- ingo#query#{get#Number,fromlist#Query}(): ENH: Also support number entry with leading zeros
- ingo#query#fromlist#Query(): BUG: Cannot conclude multi-digit entry with &lt;Enter&gt;
- ingo#query#fromlist#Query(): BUG: Typing non-accellerator non-number characters are treated as literal "0"
- Add ingo/lists.vim module.
- Add ingo/regexp/capture.vim module.
- Add ingo#cmdargs#substitute#GetFlags().
- Add ingo#subst#Indexed().
- Add ingo#regexp#split#PrefixGroupsSuffix().
- Add ingo#collections#SplitIntoMatches().
- Add ingo#regexp#collection#ToBranches().
- Add ingo/regexp/{deconstruct,length,multi} modules.
- Add ingo#range#Is{In,Out}side().
- Add ingo/cursor/keep.vim module.
- Add ingo#folds#GetOpenFoldRange().
- ingo#compat#commands#keeppatterns(): Don't remove the last search pattern
  when the search history wasn't modified. Allow to force compatibility
  function via g:IngoLibrary\_CompatFor here, too.
- Add ingo#regexp#split#GlobalFlags().
- Add ingo#regexp#IsValid() (from mark.vim plugin).
- Add ingo#matches#Any() and ingo#matches#All().
- Add ingo#list#split#RemoveFromStartWhilePredicate().
- Add ingo#cmdargs#file#FilterFileOptions() variant of
  ingo#cmdargs#file#FilterFileOptionsAndCommands()
- Add ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine() and
  combining ingo#cmdargs#file#FilterFileOptionsToEscaped() and
  ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped().
- Add ingo#list#AddNonEmpty().

##### 1.034   13-Feb-2018
- Add ingo/regexp/split.vim module.
- Add ingo#folds#LastVisibleLine(), ingo#folds#NextClosedLine(),
  ingo#folds#LastClosedLine() variants of existing
  ingo#folds#NextVisibleLine().
- Add ingo/plugin/rendered.vim module.
- Add ingo/change.vim module.
- Add ingo#undo#IsEnabled().
- Add ingo#str#split#AtPrefix() and ingo#str#split#AtSuffix().
- Add ingo/lnum.vim module.
- Add ingo#text#GetCharVirtCol().
- Add ingo#compat#matchstrpos().

##### 1.033   14-Dec-2017
- Add ingo/subs/BraceCreation.vim and ingo/subs/BraceExpansion.vim modules.
- Add ingo#query#get#WritableRegister() variant of ingo#query#get#Register().
- Add ingo#str#find#StartIndex().
- Fix recursive invocations of ingo#buffer#generate#Create().
- Add ingo#mbyte#virtcol#GetColOfVirtCol().
- Expose ingo#plugin#marks#FindUnused(), and have it optionally take the
  considered marks.
- Add ingo#plugin#marks#Reuse().
- BUG: ingo#syntaxitem#IsOnSyntax() considers empty a:stopItemPattern as
  unconditional stop.
- Add ingo#regexp#build#UnderCursor().
- Add ingo#escape#command#mapeval().
- Add ingo#range#IsEntireBuffer().
- Add ingo/compat/commands.vim module.
- Add ingo#register#All() and ingo#register#Writable() (so that this
  information doesn't have to be duplicated any longer).
- FIX: ingo#query#get#WritableRegister() doesn't consider all writable
  registers (-\_\* are writable, too).
- Add ingo/register/accumulate.vim module.
- Add ingo/tabpage.vim module.
- Add ingo#list#NonEmpty() and ingo#list#JoinNonEmpty().
- Factor out ingo#filetype#GetPrimary() from ingo#filetype#IsPrimary().
- Add ingo#fs#path#split#ChangeBasePath().
- ENH: ingo#funcref#ToString() returns non-Funcref argument as is (instead of
  empty String). This allows to transparently handle function names (as
  String), too.
- ingo#event#Trigger(): Temporarily disable modeline processing in
  compatibility implementation.
- Add ingo#event#TriggerEverywhere() and ingo#event#TriggerEverywhereCustom()
  compatibility wrappers for :doautoall &lt;nomodeline&gt;.

##### 1.032   20-Sep-2017
- ingo#query#get#{Register,Mark}(): Avoid throwing E523 on invalid user input
  when executed e.g. from within a :map-expr.
- Add ingo/subst/replacement.vim module with functions originally in
  PatternsOnText.vim ([vimscript #4602](http://www.vim.org/scripts/script.php?script_id=4602)).
- Add ingo/lines/empty.vim module.
- CHG: Rename ingo#str#split#First() to ingo#str#split#MatchFirst() and add
  ingo#str#split#StrFirst() variant that uses a fixed string, not a pattern.
- Add ingo/list/lcs.vim module.
- Add ingo#list#IsEmpty().
- Add ingo/collection/find.vim module.
- Add ingo/window.vim and ingo/window/adjacent modules.
- Add ingo#list#Matches().
- Add ingo/list/sequence.vim module.
- Add ingo#fs#path#IsAbsolute() and ingo#fs#path#IsUpwards().
- Add ingo/area/frompattern.vim module.
- CHG: Rename ingo#selection#position#Get() to ingo#selection#area#Get().
  Extend the function's API with options.
- Add ingo#text#GetFromArea().
- CHG: Rename ingo#text#replace#Area() to ingo#text#replace#Between() and add
  ingo#text#replace#Area() that actually takes a (single) a:area argument.
- Add ingo/area.vim module.
- Add ingo#query#fromlist#QueryAsText() variant of
  ingo#query#fromlist#Query().
- ENH: ingo#buffer#scratch#Create(): Allow to set the scratch buffer contents
  directly by passing a List as a:scratchCommand.
- Extract generic ingo#buffer#generate#Create() from ingo/buffer/scratch.vim.
- Add ingo#plugin#cmdcomplete#MakeListExprCompleteFunc() variant of
  ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc().
- Add ingo/ftplugin/converter/external.vim module.

##### 1.031   27-Jun-2017
- FIX: Potentially invalid indexing of l:otherResult[l:i] in
  s:GetUnjoinedResult(). Use get() for inner List access, too.
- Add special ingo#compat#synstack to work around missing patch 7.2.014:
  synstack() doesn't work in an empty line.
- BUG: ingo#comments#SplitIndentAndText() and
  ingo#comments#RemoveCommentPrefix() fail with nestable comment prefixes with
  "E688: More targets than List items".

##### 1.030   26-May-2017
- Add escaping of additional values to ingo#option#Join() and split into
  ingo#option#Append() and ingo#option#Prepend().
- Offer simpler ingo#option#JoinEscaped() and ingo#option#JoinUnescaped() for
  actual joining of values split via ingo#option#Split() /
  ingo#option#SplitAndUnescape().
- Add ingo#str#EndsWith() variant of ingo#fs#path#split#Contains().
- Add ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern().
- Add ingo/hlgroup.vim module.
- Add ingo#cursor#StartInsert() and ingo#cursor#StartAppend().
- Add ingo/compat/command.vim module.
- Add ingo#plugin#setting#Default().
- BUG: ingo#mbyte#virtcol#GetVirtColOfCurrentCharacter() yields wrong values
  with single-width multibyte characters, and at the beginning of the line
  (column 1). Need to start with offset 1 (not 0), and account for that
  (subtract 1) in the final return. Need to check that the virtcol argument
  will be larger than 0.
- Add ingo#format#Dict() variant of ingo#format#Format() that only handles
  identifier placeholders and a Dict containing them.
- ENH: ingo#format#Format(): Also handle a:fmt without any "%" items without
  error.
- Add ingo#compat#DictKey(), as Vim 7.4.1707 now allows using an empty
  dictionary key.
- Add ingo#os#IsWindowsShell().
- Generalize functions into ingo/nary.vim and delegate ingo#binary#...()
  functions to those. Add ingo/nary.vim module.
- ENH: ingo#regexp#collection#LiteralToRegexp(): Support inverted collection
  via optional a:isInvert flag.
- Add ingo#strdisplaywidth#CutLeft() variant of ingo#strdisplaywidth#strleft()
  that returns both parts. Same for ingo#strdisplaywidth#strright().
- CHG: Rename ill-named ingo#strdisplaywidth#pad#Middle() to
  ingo#strdisplaywidth#pad#Center().
- Add "real" ingo#strdisplaywidth#pad#Middle() that inserts the padding in the
  middle of the string / between the two passed string parts.
- Add ingo#fs#path#split#PathAndName().
- Add ingo#text#ReplaceChar(), a combination of ingo#text#GetChar(),
  ingo#text#Remove(), and ingo#text#Insert().
- Add ingo#err#Command() for an alternative way of passing back [error]
  commands to be executed.
- ingo#syntaxitem#IsOnSyntax(): Factor out synstack() emulation into
  ingo#compat#synstack() and unify similar function variants.
- ENH: ingo#syntaxitem#IsOnSyntax(): Allow optional a:stopItemPattern to avoid
  considering syntax items at the bottom of the stack.
- Add ingo#compat#synstack().
- Add ingo/dict/count.vim module.
- Add ingo/digest.vim module.
- Add ingo#buffer#VisibleList().

##### 1.029   24-Jan-2017
- CHG: ingo#comments#RemoveCommentPrefix() isn't useful as it omits any indent
  before the comment prefix. Change its implementation to just erase the
  prefix itself.
- Add ingo#comments#SplitIndentAndText() to provide what
  ingo#comments#RemoveCommentPrefix() was previously used to: The line broken
  into indent (before, after, and with the comment prefix), and the remaining
  text.
- Add ingo#indent#Split(), a simpler version of
  ingo#comments#SplitIndentAndText().
- Add ingo#fs#traversal#FindFirstContainedInUpDir().
- ingo#range#lines#Get(): A single (a:isGetAllRanges = 0) /.../ range already
  clobbers the last search pattern. Save and restore if necessary, and base
  didClobberSearchHistory on that check.
- ingo#range#lines#Get(): Drop the ^ anchor for the range check to also detect
  /.../ as the end of the range.
- Add ingo#cmdargs#register#ParsePrependedWritableRegister() alternative to
  ingo#cmdargs#register#ParseAppendedWritableRegister().
- BUG: Optional a:position argument to ingo#window#preview#SplitToPreview() is
  mistakenly truncated to [1:2]. Inline the l:cursor and l:bufnr variables;
  they are only used in the function call, anyway.
- Add ingo/str/find.vim module.
- Add ingo/str/fromrange.vim module.
- Add ingo#pos#SameLineIs[OnOr]After/Before() variants.
- Add ingo/regexp/build.vim module.
- Add ingo#err#SetAndBeep().
- FIX: ingo#query#get#Char() does not beep when validExpr is given and invalid
  character pressed.
- Add ingo#query#get#ValidChar() variant that loops until a valid character
  has been pressed.
- Add ingo/range/invert.vim module.
- Add ingo/line/replace.vim and ingo/lines/replace.vim modules.
- Extract ingo#range#merge#FromLnums() from ingo#range#merge#Merge().
- ingo#range#lines#Get(): If the range is a backwards-looking ?{pattern}?, we
  need to attempt the match on any line with :global/^/... Else, the border
  behavior is inconsistent: ranges that extend the passed range at the bottom
  are (partially) included, but ranges that extend at the front would not be.
- Add ingo/math.vim, ingo/binary.vim and ingo/list/split.vim modules.
- Add ingo#comments#SplitAll(), a more powerful variant of
  ingo#comments#SplitIndentAndText().
- Add ingo#compat#systemlist().
- Add ingo#escape#OnlyUnescaped().
- Add ingo#msg#ColoredMsg() and ingo#msg#ColoredStatusMsg().
- Add ingo/query/recall.vim module.
- Add ingo#register#GetAsList().
- FIX: ingo#format#Format(): An invalid %0$ references the last passed
  argument instead of yielding the empty string (as [argument-index$] is
  1-based). Add bounds check to avoid that
- FIX: ingo#format#Format(): Also support escaping via "%%", as in printf().
- Add ingo#subst#FirstSubstitution(), ingo#subst#FirstPattern(),
  ingo#subst#FirstParameter().
- Add ingo#regexp#collection#Expr().
- BUG: ingo#regexp#magic#Normalize() also processes the contents of
  collections [...]; especially the escaping of "]" wreaks havoc on the
  pattern. Rename s:ConvertMagicness() into
  ingo#regexp#magic#ConvertMagicnessOfElement() and introduce intermediate
  s:ConvertMagicnessOfFragment() that first separates collections from other
  elements and only invokes the former on those other elements.
- Add ingo#collections#fromsplit#MapItemsAndSeparators().

##### 1.028   30-Nov-2016
- ENH: Also support optional a:flagsMatchCount in
  ingo#cmdargs#pattern#ParseUnescaped() and
  ingo#cmdargs#pattern#ParseUnescapedWithLiteralWholeWord().
- Add missing ingo#cmdargs#pattern#ParseWithLiteralWholeWord() variant.
- ingo#codec#URL#Decode(): Also convert the character set to UTF-8 to properly
  handle non-ASCII characters. For example, %C3%9C should decode to "Ü", not
  to "É".
- Add ingo#collections#SeparateItemsAndSeparators(), a variant of
  ingo#collections#SplitKeepSeparators().
- Add ingo/collections/fromsplit.vim module.
- Add ingo#list#Join().
- Add ingo/compat/window.vim module.
- Add ingo/fs/path/asfilename.vim module.
- Add ingo/list/find.vim module.
- Add ingo#option#Join().
- FIX: Correct delegation in ingo#buffer#temp#Execute(); wrong recursive call
  was used (after 1.027).
- ENH: Add optional a:isSilent argument to ingo#buffer#temp#Execute().
- ENH: Add optional a:reservedColumns also to ingo#avoidprompt#TruncateTo(),
  and pass this from ingo#avoidprompt#Truncate().
- ingo#avoidprompt#TruncateTo(): The strright() cannot precisely account for
  the rendering of tab widths. Check the result, and if necessary, remove
  further characters until we go below the limit.
- ENH: Add optional {context} to all ingo#err#... functions, in case other
  custom commands can be called between error setting and checking, to avoid
  clobbering of your error message.
- Add ingo/buffer/locate.vim module.
- Add ingo/window/locate.vim module.
- Add ingo/indent.vim module.
- Add ingo#compat#getcurpos().

##### 1.027   30-Sep-2016
- Add ingo#buffer#temp#ExecuteWithText() and ingo#buffer#temp#CallWithText()
  variants that pre-initialize the buffer (a common use case).
- Add ingo#msg#MsgFromShellError().
- ENH: ingo#query#fromlist#Query(): Support headless (testing) mode via
  g:IngoLibrary\_QueryChoices, like ingo#query#Confirm() already does.
- Expose ingo#query#fromlist#RenderList(). Expose
  ingo#query#StripAccellerator().
- ENH: ingo#cmdargs#pattern#Parse(): Add second optional a:flagsMatchCount
  argument, similar to what ingo#cmdargs#substitute#Parse() has in a:options.
- Add ingo#cmdargs#pattern#RawParse().
- Add ingo/regexp/collection.vim module.
- Add ingo#str#trd().

##### 1.026   11-Aug-2016
- Add ingo#strdisplaywidth#pad#Middle().
- Add ingo/format/columns.vim module.
- ENH: ingo#avoidprompt#TruncateTo() and ingo#strdisplaywidth#TruncateTo()
  have a configurable ellipsis string g:IngoLibrary\_TruncateEllipsis, now
  defaulting to a single-char UTF-8 variant if we're in such encoding. Thanks
  to Daniel Hahler for sending a patch! It also handles pathologically small
  lengths that only show / cut into the ellipsis.
- Add ingo#compat#strgetchar() and ingo#compat#strcharpart(), introduced in
  Vim 7.4.1730.
- Support ingo#compat#strchars() optional {skipcc} argument, introduced in Vim
  7.4.755.

##### 1.025   09-Aug-2016
- Add ingo#str#Contains().
- Add ingo#fs#path#split#Contains().
- ingo#subst#pairs#Substitute(): Canonicalize path separators in
  {replacement}, too. This is important to match further pairs, too, as the
  pattern is always in canonical form, so the replacement has to be, too.
- ingo#subst#pairs#Substitute() and ingo#subst#pairs#Split(): Only
  canonicalize path separators in {replacement} on demand, via additional
  a:isCanonicalizeReplacement argument. Some clients may not need iterative
  replacement, and treat the wildcard as a convenient regexp-shorthand, not
  overly filesystem-related.
- ENH: Allow passing to ingo#subst#pairs#Substitute() [wildcard, replacement]
  Lists instead of {wildcard}={replacement} Strings, too.
- Add ingo#collections#Partition().
- Add ingo#text#frompattern#GetAroundHere().
- Add ingo#cmdline#showmode#TemporaryNoShowMode() variant of
  ingo#cmdline#showmode#OneLineTemporaryNoShowMode().
- ENH: Enable customization of ingo#window#special#IsSpecialWindow() via
  g:IngoLibrary\_SpecialWindowPredicates.
- Add ingo#query#Question().
- ENH: Make ingo#window#special#SaveSpecialWindowSize() return sum of special
  windows' widths and sum of special windows' heights.
- Add ingo/swap.vim module.
- Add ingo#collections#unique#Insert() and ingo#collections#unique#Add().
- BUG: Unescaped backslash resulted in unclosed [...] regexp collection
  causing ingo#escape#file#fnameunescape() to fail to escape on Unix.
- Add ingo#text#GetCharBefore() variant of ingo#text#GetChar().
- Add optional a:characterOffset to ingo#record#PositionAndLocation().
- Add ingo#regexp#MakeStartWordSearch() ingo#regexp#MakeEndWordSearch()
  variants of ingo#regexp#MakeWholeWordSearch().
- Add ingo#pos#IsInsideVisualSelection().
- Add ingo#escape#command#mapunescape().
- ENH: Add second optional flag a:isKeepDirectories to
  ingo#cmdargs#glob#Expand() / ingo#cmdargs#glob#ExpandSingle().
- Add ingo#range#borders#StartAndEndRange().
- Add ingo#msg#VerboseMsg().
- Add ingo#compat#sha256(), with a fallback to an external sha256sum command.
- Add ingo#collections#Reduce().
- Add ingo/actions/iterations.vim module.
- Add ingo/actions/special.vim module.
- Add ingo#collections#differences#ContainsLoosely() and
  ingo#collections#differences#ContainsStrictly().
- Add ingo#buffer#ExistOtherLoadedBuffers().
- FIX: Temporarily reset 'switchbuf' in ingo#buffer#visible#Execute() and
  ingo#buffer#temp#Execute(), to avoid that "usetab" switched to another tab
  page.
- ingo#msg#HighlightMsg(): Make a:hlgroup optional, default to 'None' (so the
  function is useful to return to normal highlighting).
- Add ingo#msg#HighlightN(), an :echon variant.

##### 1.024   23-Apr-2015
- FIX: Also correctly set change marks when replacing entire buffer with
  ingo#lines#Replace().
- Add ingo/collections/differences.vim module.
- Add ingo/compat/regexp.vim module.
- Add ingo/encoding.vim module.
- Add ingo/str/join.vim module.
- Add ingo#option#SplitAndUnescape().
- Add ingo#list#Zip() and ingo#list#ZipLongest().
- ingo#buffer#visible#Execute(): Restore the window layout when the buffer is
  visible but in a window with 0 height / width. And restore the previous
  window when the buffer isn't visible yet. Add a check that the command
  hasn't switched to another window (and go back if true) before closing the
  split window.
- Add ingo/regexp/virtcols.vim module.
- Add ingo#str#GetVirtCols() and ingo#text#RemoveVirtCol().
- FIX: Off-by-one: Allow column 1 in ingo#text#Remove().
- BUG: ingo#buffer#scratch#Create() with existing scratch buffer yields "E95:
  Buffer with this name already exists" instead of reusing the buffer.
- Keep current cursor position when ingo#buffer#scratch#Create() removes the
  first empty line in the scratch buffer.
- ingo#text#frompattern#GetHere(): Do not move the cursor (to the end of the
  matched pattern); this is unexpected and can be easily avoided.
- FIX: ingo#cmdargs#GetStringExpr(): Escape (unescaped) double quotes when the
  argument contains backslashes; else, the expansion of \\x will silently fail.
- Add ingo#cmdargs#GetUnescapedExpr(); when there's no need for empty
  expressions, the removal of the (single / double) quotes may be unexpected.
- ingo#text#Insert(): Also allow insertion one beyond the last line (in column
  1), just like setline() allows.
- Rename ingo#date#format#Human() to ingo#date#format#Preferred(), default to
  %x value for strftime(), and allow to customize that (even dynamically,
  maybe based on 'spelllang').
- Add optional a:templateForNewBuffer argument to ingo#fs#tempfile#Make() and
  ensure (by default) that the temp file isn't yet loaded in a Vim buffer
  (which would generate "E139: file is loaded in another buffer" on the usual
  :write, :saveas commands).
- Add ingo#compat#shiftwidth(), taken from :h shiftwidth().

##### 1.023   09-Feb-2015
- ENH: Make ingo#selection#frompattern#GetPositions() automatically convert
  \\%# in the passed a:pattern to the hard-coded cursor column.
- Add ingo#collections#mapsort().
- Add ingo/collections/memoized.vim module.
- ENH: Add optional a:isReturnAsList flag to ingo#buffer#temp#Execute() and
  ingo#buffer#temp#Call().
- ENH: Also allow passing an items List to ingo#dict#Mirror() and
  ingo#dict#AddMirrored() (useful to influence which key from equal values is
  used).
- ENH: Also support optional a:isEnsureUniqueness flag for
  ingo#dict#FromItems().
- Expose ingo#regexp#MakeWholeWordSearch().
- Add ingo#plugin#setting#GetTabLocal().
- ENH: Add a:isFile flag to ingo#escape#file#bufnameescape() in order to do
  full matching on scratch buffer names. There, the expansion to a full
  absolute path must be skipped in order to match.
- ENH: Add a:isGetAllRanges optional argument to ingo#range#lines#Get().
- Add ingo#strdisplaywidth#TruncateTo().
- Add ingo/str/frompattern.vim module.
- Add ingo/folds/persistence.vim module.
- Add ingo#cmdargs#pattern#IsDelimited().
- Support ingo#query#fromlist#Query() querying of more than 10 elements by
  number. Break listing of query choices into multiple lines when the overall
  question doesn't fit in a single line.
- Add ingo/event.vim module.
- Add ingo/range/merge.vim module.
- Add ingo#filetype#IsPrimary().
- Add ingo#plugin#setting#GetScope().
- Add ingo#regexp#fromwildcard#AnchoredToPathBoundaries().
- Use :close! in ingo#buffer#visible#Execute() to handle modified buffers when
  :set nohidden, too.
- Improve heuristics of ingo#window#quickfix#IsQuickfixList() to also handle
  empty location list (with non-empty quickfix list).
- Minor: ingo#text#Remove(): Correct exception prefix.
- Add ingo#window#quickfix#TranslateVirtualColToByteCount() from
  autoload/QuickFixCurrentNumber.vim.

##### 1.022   26-Sep-2014
- Add ingo#pos#Before() and ingo#pos#After().
- Move LineJuggler#FoldClosed() and LineJuggler#FoldClosedEnd() into
  ingo-library as ingo#range#NetStart() and ingo#range#NetEnd().
- Add ingo/regexp/pairs.vim module.
- Add ingo#compat#glob() and ingo#compat#globpath().
- ingo#range#lines#Get() needs to consider and temporarily disable closed
  folds when resolving /{pattern}/ ranges.

##### 1.021   10-Jul-2014
- Add ingo#compat#uniq().
- Add ingo#option#Contains() and ingo#option#ContainsOneOf().
- BUG: Wrong position type causes ingo#selection#position#get() to be one-off
  with :set selection=exclusive and when the cursor is after the selection.
- Use built-in changenr() in ingo#undo#GetChangeNumber(); actually, the entire
  function could be replaced by the built-in, if it would not just return one
  less than the number of the undone change after undo. We want the result to
  represent the current change, regardless of what undo / redo was done
  earlier. Change the implementation to test for whether the current change is
  the last in the buffer, and if not, make a no-op change to get to an
  explicit change state.
- Simplify ingo#buffer#temprange#Execute() by using changenr(). Keep using
  ingo#undo#GetChangeNumber() because we need to create a new no-op change
  when there was a previous :undo.
- Add ingo/smartcase.vim module.
- FIX: ingo#cmdargs#substitute#Parse() branch for special case of {flags}
  without /pat/string/ must only be entered when a:arguments is not empty.
- ENH: Allow to pass path separator to ingo#regexp#fromwildcard#Convert() and
  ingo#regexp#fromwildcard#IsWildcardPathPattern().
- Add ingo/collections/permute.vim module.
- Add ingo#window#preview#OpenFilespec(), a wrapper around :pedit that
  performs the fnameescape() and obeys the custom g:previewwindowsplitmode.

##### 1.020   11-Jun-2014
- Add ingo/dict/find.vim module.
- Use ingo#escape#Unescape() in ingo#cmdargs#pattern#Unescape(). Add
  ingo#cmdargs#pattern#ParseUnescaped() to avoid the double and inefficient
  ingo#cmdargs#pattern#Unescape(ingo#cmdargs#pattern#Parse()) so far used by
  many clients.
- Add ingo#cmdargs#pattern#ParseUnescapedWithLiteralWholeWord() for the common
  [/]{pattern}[/ behavior as built-in commands like |:djump|]. When the
  pattern isn't delimited by /.../, the returned pattern is modified so that
  only literal whole words are matched. so far used by many clients.
- CHG: At ingo#regexp#FromLiteralText(), add the a:isWholeWordSearch also on
  either side, or when there are non-keyword characters in the middle of the
  text. The \* command behavior where this is modeled after only handles a
  smaller subset, and this extension looks sensible and DWIM.
- Add ingo#compat#abs().
- Factor out and expose ingo#text#Replace#Area().
- CHG: When replacing at the cursor position, also jump to the beginning of
  the replacement. This is more consistent with Vim's default behavior.
- Add ingo/record.vim module.
- ENH: Allow passing optional a:tabnr to
  ingo#window#preview#IsPreviewWindowVisible().
- Factor out ingo#window#preview#OpenBuffer().
- CHG: Change optional a:cursor argument of
  ingo#window#preview#SplitToPreview() from 4-tuple getpos()-style to [lnum,
  col]-style.
- Add ingo/query/fromlist.vim module.
- Add ingo/option.vim module.
- Add ingo/join.vim module.
- Expose ingo#actions#GetValExpr().
- Add ingo/range/lines.vim module.
- ENH: Add a:options.commandExpr to ingo#cmdargs#range#Parse().

##### 1.019   24-May-2014
- Add ingo#plugin#setting#BooleanToStringValue().
- Add ingo#strdisplaywidth#GetMinMax().
- Add ingo/undo.vim module.
- Add ingo/query.vim module.
- Add ingo/pos.vim module.
- Add optional a:isBeep argument to ingo#msg#ErrorMsg().
- ingo#fs#path#Normalize(): Don't normalize to Cygwin /cygdrive/x/... when the
  chosen path separator is "\\". This would result in a mixed separator style
  that is not actually handled.
- ingo#fs#path#Normalize(): Add special normalization to "C:/" on Cygwin via
  ":/" path separator argument.
- In ingo#actions#EvaluateWithValOrFunc(), remove any occurrence of "v:val"
  instead of passing an empty list or empty string. This is useful for
  invoking functions (an expression, not Funcref) with optional arguments.
- ENH: Make ingo#lines#Replace() handle replacement with nothing (empty List)
  and replacing the entire buffer (without leaving an additional empty line).
- Correct ingo#query#confirm#AutoAccelerators() default choice when not given
  (1 instead of 0). Avoid using the default choice's first character as
  accelerator unless in GUI dialog, as the plain text confirm() assigns a
  default accelerator.
- Move subs/URL.vim into ingo-library as ingo/codec/URL.vim module.
- Allow optional a:ignorecase argument for ingo#str#StartsWith() and
  ingo#str#EndsWith().
- Add ingo#fs#path#IsCaseInsensitive().
- Add ingo#str#Equals() for when it's convenient to pass in the a:ignorecase
  flag. This avoids coding the conditional between ==# and ==? yourself.
- Add ingo/fs/path/split.vim module.
- Add ingo#fs#path#Exists().
- FIX: Correct ingo#escape#file#wildcardescape() of \* and ? on Windows.

##### 1.018   14-Apr-2014
- FIX: Off-by-one: Allow column 1 in ingo#text#Insert(). Add special cases for
  insertion at front and end of line (in the hope that this is more
  efficient).
- Add ingo#escape#file#wildcardescape().
- I18N: Correctly capture last multi-byte character in ingo#text#Get(); don't
  just add one to the end column, but instead match at the column itself, too.
- Add optional a:isExclusive flag to ingo#text#Get(), as clients may end up
  with that position, and doing a correct I18N-safe decrease before getting
  the text is a hen-and-egg problem.
- Add ingo/buffer/temprange.vim module.
- Add ingo#cursor#IsAtEndOfLine().
- FIX: Off-by-one in emulated ingo#compat#strdisplaywidth() reported one too
  few.

##### 1.017   13-Mar-2014
- CHG: Make ingo#cmdargs#file#FilterFileOptionsAndCommands() return the
  options and commands in a List, not as a joined String. This allows clients
  to easily re-escape them and handle multiple ones, e.g. ++ff=dos +setf\\ foo.
- Add workarounds for fnameescape() bugs on Windows for ! and [] characters.
- Add ingo#escape#UnescapeExpr().
- Add ingo/str/restricted.vim module.
- Make ingo#query#get#Char() only abort on &lt;Esc&gt; when that character is not in
  the validExpr (to allow to explicitly query it).
- Add ingo/query/substitute.vim module.
- Add ingo/subst/expr/emulation.vim module.
- Add ingo/cmdargs/register.vim module.

##### 1.016   22-Jan-2014
- Add ingo#window#quickfix#GetList() and ingo#window#quickfix#SetList().
- Add ingo/cursor.vim module.
- Add ingo#text#Insert() and ingo#text#Remove().
- Add ingo#str#StartsWith() and ingo#str#EndsWith().
- Add ingo#dict#Mirror() and ingo#dict#AddMirrored().
- BUG: Wrap :autocmd! undo\_ftplugin\_N in :execute to that superordinated
  ftplugins can append additional undo commands without causing "E216: No such
  group or event: undo\_ftplugin\_N|setlocal".
- Add ingo/motion/helper.vim module.
- Add ingo/motion/omap.vim module.
- Add ingo/subst/pairs.vim module.
- Add ingo/plugin/compiler.vim module.
- Move ingo#escape#shellcommand#shellcmdescape() to
  ingo#compat#shellcommand#escape(), as it is only required for older Vim
  versions.

##### 1.015   28-Nov-2013
- Add ingo/format.vim module.
- FIX: Actually return the result of a Funcref passed to
  ingo#register#KeepRegisterExecuteOrFunc().
- Make buffer argument of ingo#buffer#IsBlank() optional, defaulting to the
  current buffer.
- Allow use of ingo#buffer#IsEmpty() with other buffers.
- CHG: Pass _all_ additional arguments of ingo#actions#ValueOrFunc(),
  ingo#actions#NormalOrFunc(), ingo#actions#ExecuteOrFunc(),
  ingo#actions#EvaluateOrFunc() instead of only the first (interpreted as a
  List of arguments) when passed a Funcref as a:Action.
- Add ingo#compat#setpos().
- Add ingo/print.vim module.

##### 1.014   14-Nov-2013
- Add ingo/date/format.vim module.
- Add ingo#os#PathSeparator().
- Add ingo/foldtext.vim module.
- Add ingo#os#IsCygwin().
- ingo#fs#path#Normalize(): Also convert between the different D:\\ and
  /cygdrive/d/ notations on Windows and Cygwin.
- Add ingo#text#frompattern#GetHere().
- Add ingo/date/epoch.vim module.
- Add ingo#buffer#IsPersisted().
- Add ingo/list.vim module.
- Add ingo/query/confirm.vim module.
- Add ingo#text#GetChar().
- Add ingo/regexp/fromwildcard.vim module (contributed by the EditSimilar.vim
  plugin). In constrast to the simpler ingo#regexp#FromWildcard(), this
  handles the full range of wildcards and considers the path separators on
  different platforms.
- Add ingo#register#KeepRegisterExecuteOrFunc().
- Add ingo#actions#ValueOrFunc().
- Add ingo/funcref.vim module.
- Add month and year granularity to ingo#date#HumanReltime().
- Add ingo/units.vim module.

##### 1.013   13-Sep-2013
- Also avoid clobbering the last change ('.') in ingo#selection#Get() when
  'cpo' contains "y".
- Name the temp buffer for ingo#buffer#temp#Execute() and re-use previous
  instances to avoid increasing the buffer numbers and output of :ls!.
- CHG: Make a:isIgnoreIndent flag to ingo#comments#CheckComment() optional and
  add a:isStripNonEssentialWhiteSpaceFromCommentString, which is also on by
  default for DWIM.
- CHG: Don't strip whitespace in ingo#comments#RemoveCommentPrefix(); with the
  changed ingo#comments#CheckComment() default behavior, this isn't necessary,
  and is unexpected.
- ingo#comments#RenderComment: When the text starts with indent identical to
  what 'commentstring' would render, avoid having duplicate indent.
- Minor: Return last search pattern instead of empty string on
  ingo#search#pattern#GetLastForwardSearch(0).
- Avoid using \\ze in ingo#regexp#comments#CommentToExpression(). It may be
  used in a larger expression that still wants to match after the prefix.
- FIX: Correct case of ingo#os#IsWin\*() function names.
- ingo#regexp#FromWildcard(): Limit \* glob matching to individual path
  components and add \*\* for cross-directory matching.
- Consistently use operating system detection functions from ingo/os.vim
  within the ingo-library.

##### 1.012   05-Sep-2013
- CHG: Change return value format of ingo#selection#frompattern#GetPositions()
  to better match the arguments of functions like ingo#text#Get().
- Add ingo/os.vim module.
- Add ingo#compat#fnameescape() and ingo#compat#shellescape() from
  escapings.vim.
- Add remaining former escapings.vim functions as ingo/escape/shellcommand.vim
  and ingo/escape/file.vim modules.
- Add ingo/motion/boundary.vim module.
- Add ingo#compat#maparg().
- Add ingo/escape/command.vim module.
- Add ingo/text/frompattern.vim module.

##### 1.011   02-Aug-2013
- Add ingo/range.vim module.
- Add ingo/register.vim module.
- Make ingo#collections#ToDict() handle empty list items via an optional
  a:emptyValue argument. This also distinguishes it from ingo#dict#FromKeys().
- ENH: Handle empty list items in ingo#collections#Unique() and
  ingo#collections#UniqueStable().
- Add ingo/gui/position.vim module.
- Add ingo/filetype.vim module.
- Add ingo/ftplugin/onbufwinenter.vim module.
- Add ingo/selection/frompattern.vim module.
- Add ingo/text.vim module.
- Add ingo/ftplugin/windowsettings.vim module.
- Add ingo/text/replace.vim module.
- FIX: Use the rules for the /pattern/ separator as stated in :help E146 for
  ingo#cmdargs#pattern#Parse() and ingo#cmdargs#substitute#Parse().
- FIX: Off-by-one in ingo#strdisplaywidth#HasMoreThan() and
  ingo#strdisplaywidth#strleft().
- Add ingo#str#Reverse().
- ingo#fs#traversal#FindLastContainedInUpDir now defaults to the current
  buffer's directory; omit the argument.
- Add ingo#actions#EvaluateWithValOrFunc().
- Extract ingo#fs#path#IsUncPathRoot().
- Add ingo#fs#traversal#FindDirUpwards().

##### 1.010   09-Jul-2013
- Add ingo/actions.vim module.
- Add ingo/cursor/move.vim module.
- Add ingo#collections#unique#AddNew() and
  ingo#collections#unique#InsertNew().
- Add ingo/selection/position.vim module.
- Add ingo/plugin/marks.vim module.
- Add ingo/date.vim module.
- Add ingo#buffer#IsEmpty().
- Add ingo/buffer/scratch.vim module.
- Add ingo/cmdargs/command.vim module.
- Add ingo/cmdargs/commandcommands.vim module.
- Add ingo/cmdargs/range.vim module.

##### 1.009   03-Jul-2013
- Minor: Make substitute() robust against 'ignorecase' in various functions.
- Add ingo/subst.vim module.
- Add ingo/escape.vim module.
- Add ingo/regexp/comments.vim module.
- Add ingo/cmdline/showmode.vim module.
- Add ingo/str.vim module.
- Add ingo/strdisplaywidth/pad.vim module.
- Add ingo/dict.vim module.
- Add ingo#msg#HighlightMsg(), and allow to pass an optional highlight group
  to ingo#msg#StatusMsg().
- Add ingo#collections#Flatten() and ingo#collections#Flatten1().
- Move ingo#collections#MakeUnique() to ingo/collections/unique.vim.
- Add ingo#collections#unique#ExtendWithNew().
- Add ingo#fs#path#Equals().
- Add ingo#tabstops#RenderMultiLine(), as ingo#tabstops#Render() does not
  properly render multi-line text.
- Add ingo/str/split.vim module.
- FIX: Avoid E108: No such variable: "b:browsefilter" in
  ingo#query#file#Browse().

##### 1.008   13-Jun-2013
- Fix missing argument error for ingo#query#file#BrowseDirForOpenFile() and
  ingo#query#file#BrowseDirForAction().
- Implement ingo#compat#strdisplaywidth() emulation inside the library;
  EchoWithoutScrolling.vim isn't used for that any more.
- Add ingo/avoidprompt.vim, ingo/strdisplaywidth.vim, and ingo/tabstops
  modules, containing the former EchoWithoutScrolling.vim functions.
- Add ingo/buffer/temp.vim and ingo/buffer/visible.vim modules.
- Add ingo/regexp/previoussubstitution.vim module.

##### 1.007   06-Jun-2013
- Add ingo/query/get.vim module.
- Add ingo/query/file.vim module.
- Add ingo/fs/path.vim module.
- Add ingo/fs/tempfile.vim module.
- Add ingo/cmdargs/file.vim module.
- Add ingo/cmdargs/glob.vim module.
- CHG: Move most functions from ingo/cmdargs.vim to new modules
  ingo/cmdargs/pattern.vim and ingo/cmdargs/substitute.vim.
- Add ingo/compat/complete.vim module.

##### 1.006   29-May-2013
- Add ingo/cmdrangeconverter.vim module.
- Add ingo#mapmaker.vim module.
- Add optional isReturnError flag on
  ingo#window#switches#GotoPreviousWindow().
- Add ingo#msg#StatusMsg().
- Add ingo/selection/patternmatch.vim module.
- Add ingo/selection.vim module.
- Add ingo/search/pattern.vim module.
- Add ingo/regexp.vim module.
- Add ingo/regexp/magic.vim module.
- Add ingo/collections/rotate.vim module.
- Redesign ingo#cmdargs#ParseSubstituteArgument() to the existing use cases.
- Add ingo/buffer.vim module.

##### 1.005   02-May-2013
- Add ingo/plugin/setting.vim module.
- Add ingo/plugin/cmdcomplete.vim module.
- Add ingo/search/buffer.vim module.
- Add ingo/number.vim module.
- Add ingo#err#IsSet() for those cases when wrapping the command in :if does
  not work (e.g. :call'ing a range function).
- Add ingo#syntaxitem.vim module.
- Add ingo#comments.vim module.

##### 1.004   10-Apr-2013
- Add ingo/compat.vim module.
- Add ingo/folds.vim module.
- Add ingo/lines module.
- Add ingo/matches module.
- Add ingo/mbyte/virtcol module.
- Add ingo/window/\* modules.
- FIX: ingo#external#LaunchGvim() broken with "E117: Unknown function: s:externalLaunch".

##### 1.003   27-Mar-2013
- Add ingo#msg#ShellError().
- Add ingo#system#Chomped().
- Add ingo/fs/traversal.vim module.
- Add search/timelimited.vim module.

##### 1.002   08-Mar-2013
- Minor: Allow to specify filespec of GVIM executable in
  ingo#external#LaunchGvim().
- Add err module for LineJugglerCommands.vim plugin.

##### 1.001   21-Feb-2013
- Add cmdargs and collections modules for use by PatternsOnText.vim plugin.

##### 1.000   12-Feb-2013
- First published version as separate shared library.

##### 0.001   05-Jan-2009
- Started development of shared autoload functionality.

------------------------------------------------------------------------------
Copyright: (C) 2009-2022 Ingo Karkat -
Contains URL encoding / decoding algorithms written by Tim Pope. -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
