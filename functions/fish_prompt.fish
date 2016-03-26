function show_pwd -d "Show the current directory"
  set -l pwd (prompt_pwd)
  segment " $pwd " white 1abc9c
end


function show_virtualenv -d "Show active python virtual environments"
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    segment " $venvname " white 2c3e50
    end
end

function show_user -d "Show user"
  if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
    set -l host (hostname -s)
    set -l who (whoami)

    # Skip @ bit if hostname == username
    if [ "$USER" != "$host" ]
      segment " $who@$host" fa0 111
    else
      segment " $who" fa0 111
    end
  end
end

function show_prompt -d "Shows the prompt with privilede appropriate symbol"
  set -l uid (id -u $USER)

  if [ $uid -eq 0 ]
    segment " ! " fa0 c0392b
  else
    segment " ⌁ " fa0 black
  end
end


## SHOW PROMPT
function fish_prompt
  show_prompt
  show_user
  show_virtualenv
  show_pwd

  segment_close
end
