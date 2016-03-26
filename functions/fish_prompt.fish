set -g pad " "


## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

## Function to show current status
function show_status -d "Function to show the current status"
  if [ $RETVAL -ne 0 ]
    segment " ▲ " red white
    segment_close
    set pad ""
    end
  if [ -n "$SSH_CLIENT" ]
    segment " SSH " blue white
    segment_close
    set pad ""
    end
end

function show_virtualenv -d "Show active python virtual environments"
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    segment " $venvname " white 2c3e50
    end
end

## Show user if not default
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

# Show directory
function show_pwd -d "Show the current directory"
  set -l pwd (prompt_pwd)
  segment "$pad$pwd " white 1abc9c
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
  set -g RETVAL $status

  show_prompt
  show_user
  show_virtualenv
  show_pwd

  segment_close
end
