#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

main() {
  # set configuration option variables
  show_krbtgt_label=$(get_tmux_option "@ponokai-krbtgt-context-label" "")
  krbtgt_principal=$(get_tmux_option "@ponokai-krbtgt-principal" "")
  show_kubernetes_context_label=$(get_tmux_option "@ponokai-kubernetes-context-label" "")
  show_only_kubernetes_context=$(get_tmux_option "@ponokai-show-only-kubernetes-context" false)
  eks_hide_arn=$(get_tmux_option "@ponokai-kubernetes-eks-hide-arn" false)
  eks_extract_account=$(get_tmux_option "@ponokai-kubernetes-eks-extract-account" false)
  hide_kubernetes_user=$(get_tmux_option "@ponokai-kubernetes-hide-user" false)
  terraform_label=$(get_tmux_option "@ponokai-terraform-label" "")
  show_fahrenheit=$(get_tmux_option "@ponokai-show-fahrenheit" true)
  show_location=$(get_tmux_option "@ponokai-show-location" true)
  fixed_location=$(get_tmux_option "@ponokai-fixed-location")
  show_powerline=$(get_tmux_option "@ponokai-show-powerline" true)
  transparent_powerline_bg=$(get_tmux_option "@ponokai-transparent-powerline-bg" false)
  show_flags=$(get_tmux_option "@ponokai-show-flags" true)
  show_left_icon=$(get_tmux_option "@ponokai-show-left-icon" session)
  show_left_icon_padding=$(get_tmux_option "@ponokai-left-icon-padding" 0)
  show_right_icon=$(get_tmux_option "@ponokai-show-right-icon" shortname)
  show_right_icon_padding=$(get_tmux_option "@ponokai-right-icon-padding" 0)
  show_military=$(get_tmux_option "@ponokai-military-time" false)
  timezone=$(get_tmux_option "@ponokai-set-timezone" "")
  show_timezone=$(get_tmux_option "@ponokai-show-timezone" true)
  show_left_separator=$(get_tmux_option "@ponokai-show-left-separator" )
  show_right_separator=$(get_tmux_option "@ponokai-show-right-separator" )
  show_edge_icons=$(get_tmux_option "@ponokai-show-edge-icons" false)
  show_inverse_divider=$(get_tmux_option "@ponokai-inverse-divider" )
  show_day_month=$(get_tmux_option "@ponokai-day-month" false)
  show_refresh=$(get_tmux_option "@ponokai-refresh-rate" 5)
  show_synchronize_panes_label=$(get_tmux_option "@ponokai-synchronize-panes-label" "Sync")
  time_format=$(get_tmux_option "@ponokai-time-format" "")
  show_ssh_session_port=$(get_tmux_option "@ponokai-show-ssh-session-port" false)
  show_libreview=$(get_tmux_option "@ponokai-show-libreview" false)
  IFS=' ' read -r -a plugins <<< $(get_tmux_option "@ponokai-plugins" "cwd cpu-usage ram-usage battery network time weather")
  show_empty_plugins=$(get_tmux_option "@ponokai-show-empty-plugins" true)

  # Ponokai Color Palette
  black="#000000"
  bg_dim="#252630"
  bg0="#000000"
  bg1="#1c1c1c"
  bg2="#303030"
  bg3="#444444"
  bg4="#585858"
  bg_red="#ffb3bd"
  diff_red="#a67f82"
  bg_green="#cbecb0"
  diff_green="#818f80"
  bg_blue="#b3e7f9"
  diff_blue="#808d9f"
  diff_yellow="#9c937a"
  fg0="#f2f2f3"
  red="#ff8c9a"
  orange="#f3bb9a"
  yellow="#f8e7b0"
  green="#b4e49a"
  blue="#98d4e7"
  purple="#bdb2ff"
  grey="#c4c6cf"
  grey_dim="#9da1af"

  # Override default colors and possibly add more
  colors="$(get_tmux_option "@ponokai-colors" "")"
  if [ -n "$colors" ]; then
    eval "$colors"
  fi

  IFS=' ' read -r -a window_separator_colors <<< $(get_tmux_option "@ponokai-window-status-colors" "purple bg1")
  IFS=' ' read -r -a powerline_colors <<< $(get_tmux_option "@ponokai-powerline-colors" "bg1 blue")

  # Set transparency variables - Colors and window dividers
  if $transparent_powerline_bg; then
	  powerline_colors[0]="default"
    if $show_edge_icons; then
      window_separator_colors[0]=default
      window_separator="$show_right_separator"
    else
      window_separator_colors[0]=default
      window_separator="$show_inverse_divider"
    fi
  else
    if $show_edge_icons; then
      window_separator="$show_inverse_divider"
    else
      window_separator="$show_left_separator"
    fi
  fi

  # Handle left icon configuration
  case $show_left_icon in
    smiley)
      left_icon="☺";;
    session)
      left_icon="#S";;
    window)
      left_icon="#W";;
    hostname)
      left_icon="#H";;
    shortname)
      left_icon="#h";;
    *)
      left_icon=$show_left_icon;;
  esac

  # Handle left icon padding
  padding=""
  if [ "$show_left_icon_padding" -gt "0" ]; then
    padding="$(printf '%*s' $show_left_icon_padding)"
  fi
  left_icon="$left_icon$padding"

  # Handle powerline option
  if $show_powerline; then
    right_separator="$show_right_separator"
    left_separator="$show_left_separator"
  fi

  # Set timezone unless hidden by configuration
  if [[ -z "$timezone" ]]; then
    case $show_timezone in
      false)
        timezone="";;
      true)
        timezone="#(date +%Z)";;
    esac
  fi

  IFS=' ' read -r -a status_colors <<< $(get_tmux_option "@ponokai-status-colors" "bg1 fg0")
  case $show_flags in
    false)
      flags=""
      current_flags="";;
    true)
      flags="#{?window_flags,#[fg=${!flag_colors[1]}]#{window_flags},}"
      current_flags="#{?window_flags,#[fg=${!flag_colors[1]}]#{window_flags},}"
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set the prefix + t time format
  if $show_military; then
    tmux set-option -g clock-mode-style 24
  else
    tmux set-option -g clock-mode-style 12
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  IFS=' ' read -r -a pane_border_colors <<<  $(get_tmux_option "@ponokai-pane-border-colors" "grey purple")
  tmux set-option -g pane-active-border-style "fg=${!pane_border_colors[1]}"
  tmux set-option -g pane-border-style "fg=${!pane_border_colors[0]}"

  # message styling
  IFS=' ' read -r -a message_colors <<< $(get_tmux_option "@ponokai-message-colors" "bg2 fg0")
  tmux set-option -g message-style "bg=${!message_colors[0]},fg=${!message_colors[1]}"

  # status bar
  IFS=' ' read -r -a flag_colors <<< $(get_tmux_option "@ponokai-flag-colors" "black purple")
  tmux set-option -g status-style "bg=${!status_colors[0]},fg=${!status_colors[1]}"

  IFS=' ' read -r -a client_colors <<< $(get_tmux_option "@ponokai-client-colors" "bg1 red")

  # Status left
  if $show_powerline; then
    if $show_edge_icons; then
      tmux set-option -g status-left "#[bg=${!powerline_colors[0]},fg=${!powerline_colors[1]},bold]#{?client_prefix,#[fg=${!client_colors[1]}],}${right_separator}#[bg=${!powerline_colors[1]},fg=${!powerline_colors[0]}]#{?client_prefix,#[bg=${client_colors[1]}],} ${left_icon} "
    else
      tmux set-option -g status-left "#[bg=${!powerline_colors[0]},fg=${!powerline_colors[1]}]#[bg=${!powerline_colors[1]},fg=${!powerline_colors[0]}]#{?client_prefix,#[bg=${!client_colors[1]}],} ${left_icon} "
    fi
    previous_plugin_background_color=${!powerline_colors[0]}
  else
    tmux set-option -g status-left "#[bg=${!powerline_colors[0]},fg=${!powerline_colors[1]}]#{?client_prefix,#[bg=${!client_colors[1]}],} ${left_icon}"
  fi

  # Status right
  tmux set-option -g status-right ""

  for plugin in "${plugins[@]}"; do

    if case $plugin in custom:*) true;; *) false;; esac; then
      script=${plugin#"custom:"}
      if [[ -x "${current_dir}/${script}" ]]; then
        IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-custom-plugin-colors" "blue black")
        script="#($current_dir/${script})"
      else
        colors[0]="red"
        colors[1]="black"
        script="${script} not found!"
      fi

    elif [ $plugin = "cwd" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@ponokai-cwd-colors" "grey black")
      tmux set-option -g status-right-length 250
      script="#($current_dir/cwd.sh)"

    elif [ $plugin = "fossil" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@ponokai-fossil-colors" "green black")
      tmux set-option -g status-right-length 250
      script="#($current_dir/fossil.sh)"

    elif [ $plugin = "git" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@ponokai-git-colors" "green black")
      tmux set-option -g status-right-length 250
      script="#($current_dir/git.sh)"

    elif [ $plugin = "hg" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@ponokai-hg-colors" "green black")
      tmux set-option -g status-right-length 250
      script="#($current_dir/hg.sh)"

    elif [ $plugin = "battery" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-battery-colors" "red black")
      script="#($current_dir/battery.sh)"

    elif [ $plugin = "gpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-gpu-usage-colors" "red black")
      script="#($current_dir/gpu_usage.sh)"

    elif [ $plugin = "gpu-ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-gpu-ram-usage-colors" "blue black")
      script="#($current_dir/gpu_ram_info.sh)"

    elif [ $plugin = "gpu-power-draw" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-gpu-power-draw-colors" "green black")
      script="#($current_dir/gpu_power.sh)"

    elif [ $plugin = "cpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-cpu-usage-colors" "orange black")
      script="#($current_dir/cpu_info.sh)"

    elif [ $plugin = "ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-ram-usage-colors" "blue black")
      script="#($current_dir/ram_info.sh)"

    elif [ $plugin = "tmux-ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-tmux-ram-usage-colors" "blue black")
      script="#($current_dir/tmux_ram_info.sh)"

    elif [ $plugin = "network" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-network-colors" "green black")
      script="#($current_dir/network.sh)"

    elif [ $plugin = "network-bandwidth" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-network-bandwidth-colors" "blue black")
      tmux set-option -g status-right-length 250
      script="#($current_dir/network_bandwidth.sh)"

    elif [ $plugin = "network-ping" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-network-ping-colors" "blue black")
      script="#($current_dir/network_ping.sh)"

    elif [ $plugin = "network-vpn" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-network-vpn-colors" "blue black")
      script="#($current_dir/network_vpn.sh)"

    elif [ $plugin = "attached-clients" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-attached-clients-colors" "blue black")
      script="#($current_dir/attached_clients.sh)"

    elif [ $plugin = "mpc" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-mpc-colors" "green black")
      script="#($current_dir/mpc.sh)"

    elif [ $plugin = "spotify-tui" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-spotify-tui-colors" "green black")
      script="#($current_dir/spotify-tui.sh)"

    elif [ $plugin = "krbtgt" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-krbtgt-colors" "blue black")
      script="#($current_dir/krbtgt.sh $krbtgt_principal $show_krbtgt_label)"

    elif [ $plugin = "playerctl" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-playerctl-colors" "green black")
      script="#($current_dir/playerctl.sh)"

    elif [ $plugin = "kubernetes-context" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-kubernetes-context-colors" "blue black")
      script="#($current_dir/kubernetes_context.sh $eks_hide_arn $eks_extract_account $hide_kubernetes_user $show_only_kubernetes_context $show_kubernetes_context_label)"

    elif [ $plugin = "terraform" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-terraform-colors" "purple black")
      script="#($current_dir/terraform.sh $terraform_label)"

    elif [ $plugin = "continuum" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-continuum-colors" "blue black")
      script="#($current_dir/continuum.sh)"

    elif [ $plugin = "weather" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-weather-colors" "blue black")
      script="#($current_dir/weather_wrapper.sh $show_fahrenheit $show_location '$fixed_location')"

    elif [ $plugin = "time" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-time-colors" "purple black")
      if [ -n "$time_format" ]; then
        script=${time_format}
      else
        if $show_day_month && $show_military ; then # military time and dd/mm
          script="%a %d/%m %R ${timezone} "
        elif $show_military; then # only military time
          script="%R ${timezone} "
        elif $show_day_month; then # only dd/mm
          script="%a %d/%m %I:%M %p ${timezone} "
        else
          script="%a %m/%d %I:%M %p ${timezone} "
        fi
      fi
    elif [ $plugin = "synchronize-panes" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-synchronize-panes-colors" "blue black")
      script="#($current_dir/synchronize_panes.sh $show_synchronize_panes_label)"

    elif [ $plugin = "libreview" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-libre-colors" "fg0 bg2")
      script="#($current_dir/libre.sh $show_libreview)"

    elif [ $plugin = "ssh-session" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-ssh-session-colors" "green black")
      script="#($current_dir/ssh_session.sh $show_ssh_session_port)"

    elif [ $plugin = "network-public-ip" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@ponokai-network-public-ip-colors" "blue black")
      script="#($current_dir/network-public-ip.sh)"

    elif [ $plugin = "sys-temp" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@ponokai-sys-temp-colors" "green black")
      script="#($current_dir/sys_temp.sh)"

    else
      continue
    fi


    # edge styling
    if $show_edge_icons; then
      right_edge_icon="#[bg=${!powerline_colors[0]},fg=${!colors[0]}]${show_left_separator}"
      plugin_background_color=${!powerline_colors[0]}
    else 
      plugin_background_color=${previous_plugin_background_color}
    fi

    if $show_powerline; then
      if $show_empty_plugins; then
        tmux set-option -ga status-right " #[fg=${!colors[0]},bg=${plugin_background_color},nobold,nounderscore,noitalics]${right_separator}#[fg=${!colors[1]},bg=${!colors[0]}] $script $right_edge_icon"
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[0]},nobold,nounderscore,noitalics] ${right_separator}#[fg=${!colors[1]},bg=${!colors[0]}] $script $right_edge_icon}"
      fi
      previous_plugin_background_color=${!colors[0]}
    else
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
    fi

  done

  if [[ "$show_right_icon" != "false" ]]; then
    case $show_right_icon in
      smiley)
        right_icon="☺";;
      session)
        right_icon="#S";;
      window)
        right_icon="#W";;
      hostname)
        right_icon="#H";;
      shortname)
        right_icon="#h";;
      *)
        right_icon=$show_right_icon;;
    esac

    # Handle left icon padding
    padding=""
    if [ "$show_right_icon_padding" -gt "0" ]; then
      padding="$(printf '%*s' $show_right_icon_padding)"
    fi
    right_icon="$padding$right_icon"

    if $show_edge_icons; then
      right_edge_icon="#[bg=${!powerline_colors[0]},fg=${!powerline_colors[1]}]${show_left_separator}"
      plugin_background_color=${!powerline_colors[0]}
    else 
      plugin_background_color=${previous_plugin_background_color}
    fi

    if $show_powerline; then
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!powerline_colors[0]},bg=${plugin_background_color},nobold,nounderscore,noitalics]${right_separator}#[fg=${!powerline_colors[1]},bg=${!powerline_colors[0]}]#{?client_prefix,#[fg=${!client_colors[1]}],} ${right_icon} $right_edge_icon"
      else
        tmux set-option -ga status-right "#[fg=${!powerline_colors[1]},nobold,nounderscore,noitalics]${right_separator}#[fg=${!powerline_colors[1]},bg=${!powerline_colors[0]}]#{?client_prefix,#[fg=${!client_colors[1]}],} ${right_icon} $right_edge_icon"
      fi
    else
        tmux set-option -ga status-right "#[fg=${!powerline_colors[1]},bg=${!powerline_colors[0]}]#{?client_prefix,#[fg=${!client_colors[1]}],} ${right_icon}"
    fi
  fi 

  first_window_index=$(tmux list-windows -F '#I' | sort -n | head -n1)

  # Window option
  IFS=' ' read -r -a window_status_colors <<< $(get_tmux_option "@ponokai-window-status-colors" "purple bg1")
  if $show_powerline; then

  

    tmux set-window-option -g window-status-current-format \
      "#[bg=${!window_separator_colors[0],fg=${!window_separator_colors[1]]#{?#{==:#I,${first_window_index}},#{?client_prefix,#[fg=${!client_colors[1]}],#[fg=${!powerline_colors[1]}]},}${window_separator}\
      #[fg=${!window_status_colors[1]},bg=${!window_status_colors[0]}] #I #W${current_flags} \
      #[fg=${!window_separator_colors[0]},bg=${!window_separator_colors[1]}]${left_separator}"

    # For inactive windows
    tmux set-window-option -g window-status-format \
      "#[bg=${!window_separator_colors[1],fg=${!window_separator_colors[1]]#{?#{==:#I,${first_window_index}},#{?client_prefix,#[fg=${!client_colors[1]}],#[fg=${!powerline_colors[1]}]},}${left_separator} \
      #[fg=${!window_separator_colors[1]},bg=${!window_separator_colors[1]}]#I #W${flags} \
      #[bg=${!window_separator_colors[1]},fg=${!window_separator_colors[1]}]${left_separator}"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${!window_status_colors[1]},bg=${!window_status_colors[0]}] #I #W${current_flags} "
    
    # For inactive windows
    tmux set-window-option -g window-status-format "#[fg=${!window_status_colors[0]},bg=${!window_status_colors[1]}] #I #W${flags} "
  fi




  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
  tmux set-window-option -g window-status-separator ""
}

# run main function
main