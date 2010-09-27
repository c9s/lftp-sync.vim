
fun! s:scan_buffers()
  let buflist = []
  for i in range(1, bufnr('$') ) 
    if bufexists( i ) && buflisted( i )
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
  cal system( "lftp -f " . script )
endf


