
fun! s:scan_buffers()
  let buflist = []
  for i in range(1, bufnr('$') ) 
    if bufexists( i ) && buflisted( i ) && filereadable( bufname(i) )
      cal add( buflist , bufname(i) )
    endif
  endfor
  return buflist
endf

fun! s:gen_script_buffers(buffers)
  let file = tempname()
  let lines = [ ]
  cal add( lines , printf('open -u %s,%s %s' , g:lftp_user ,g:lftp_pass , g:lftp_host ) )
  for f in a:buffers
    cal add( lines , printf('put %s -o %s', f , f) )
  endfor
  cal writefile( lines , file )
  return file
endf


fun! s:gen_config()
  let user = input( "User:" )
  let pass = input( "Pass:" )
  let host = input( "Host:" )
  let lines = []
  cal add(lines , printf( "let g:lftp_user = '%s' " , user ) )
  cal add(lines , printf( "let g:lftp_pass = '%s' " , pass ) )
  cal add(lines , printf( "let g:lftp_host = '%s' " , host ) )
  cal writefile( lines , ".lftp.vim" )
endf

fun! s:read_config()
  if ! filereadable( ".lftp.vim" )
    return
  endif
  source .lftp.vim
endf

fun! s:lftp_sync_buffers()
  cal s:read_config()
  let buffers = s:scan_buffers()
  let script = s:gen_script_buffers(buffers)
  redraw
  echomsg "Upload:"
  echomsg buffers
  exec '!lftp -f ' . script
  cal delete( script )
  echomsg "Done"
endf

fun! s:lftp_sync_current()
  cal s:read_config()
  let buffers = [ bufname('%') ]
  let script = s:gen_script_buffers(buffers)
  exec '!lftp -f ' . script
  cal delete( script )
endf

fun! s:lftp_console()
  source .lftp.vim
  exec printf('!lftp -u %s,%s %s', g:lftp_user , g:lftp_pass, g:lftp_host )
endf


com! LftpConsole      :cal s:lftp_console()
com! LftpGenConfig    :cal s:gen_config()
com! LftpSyncBuffers  :cal s:lftp_sync_buffers()
com! LftpSyncCurrent  :cal s:lftp_sync_current()
cabbr ftpsb  LftpSyncBuffers

if ! exists( 'g:lftp_sync_no_default_mapping' )
  nnoremap <leader>fu   :LftpSyncBuffers<CR>
  nnoremap <leader>fc   :LftpSyncCurrent<CR>
  nnoremap <leader>ff   :LftpConsole<CR>
endif
