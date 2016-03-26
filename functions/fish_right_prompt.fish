function get_git_status -d "Gets the current git status"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l dirty (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
    set -l ref (command git describe --tags --exact-match ^/dev/null ; or command git symbolic-ref --short HEAD 2> /dev/null ; or command git rev-parse --short HEAD 2> /dev/null)

    if [ "$dirty" != "0" ]
      set file_or_files "file"

      if [ "$dirty" != "1" ]
        set file_or_files "files"
        end

      segment_right " $dirty changed $file_or_files " white red
      end

    segment_right " $ref " white 27ae60
    segment_close
   end
end

function show_result -d "Shows the result of the previous command, or the duration if successful"
  set -l status_copy $status

  if test "$CMD_DURATION" -gt 20
    set -l duration (echo $CMD_DURATION | humanize_duration)

    if test ! -z "$duration"
        set -l indicator

        if test $status_copy -ne 0
            set indicator " $status_copy "
        end

        segment_right " $duration " white 2980b9
        # segment_close
    end
  else if test $status_copy -ne 0
    segment_right " $status_copy " white f00
    # segment_close
  else
    segment_right (date +%H:%M)" " eee 2980b9
    # segment_close
  end
end

function prompt_git -d "Display the current git state"
  set -l ref
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set ref (command git symbolic-ref HEAD 2> /dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
      set ref "➦ $branch "
    end
    set branch_symbol \uE0A0
    set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")

    set -l BG PROMPT
    set -l dirty (command git status --porcelain --ignore-submodules=dirty 2> /dev/null)
    set -l dirty_files (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)

    if [ "$dirty" = "" ]
      set BG green
      set PROMPT "$branch"
    else
      set BG yellow
      set dirty ''

      # Check if there's any commit in the repo
      set -l empty 0
      git rev-parse --quiet --verify HEAD > /dev/null ^&1; or set empty 1

      set -l target
      if [ $empty = 1 ]
        # The repo is empty
        set target '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
      else
        # The repo is not emtpy
        set target 'HEAD'

        # Check for unstaged change only when the repo is not empty
        set -l unstaged 0
        git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code; or set unstaged 1
        if [ $unstaged = 1 ]; set dirty $dirty"●"; end
      end

      # Check for staged change
      set -l staged 0
      git diff-index --cached --quiet --exit-code --ignore-submodules=dirty $target; or set staged 1
      if [ $staged = 1 ]; set dirty $dirty'✚'; end

      # Check for dirty
      if [ "$dirty" = "" ]
        set PROMPT "$branch"
      else
        set PROMPT "$branch $dirty"
      end
    end
    segment_right " $PROMPT " white 27ae60
    segment_right " $dirty_files " 2c3e50 white

  end
end

function fish_right_prompt -d "Prints right prompt"
  # get_git_status

  show_result

  prompt_git
  segment_close

end
