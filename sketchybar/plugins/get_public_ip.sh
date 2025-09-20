#!/bin/sh

IP=$(curl -s ifconfig.me)
IS_IP=$(echo "$IP" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
PADDING_RIGHT=-6

# determine default interface normally
iface=$(route get default 2>/dev/null | awk '/interface:/ {print $2}')
[ -z "$iface" ] && iface=$(netstat -rn | awk '/^default/ {print $NF; exit}')

# If the default interface is a VPN tunnel/virtual (utun/ppp/tun), find the underlying physical interface.
if printf '%s\n' "$iface" | grep -Eq '^(utun|ppp|tun)'; then
  # scutil --nwi contains a "Network interfaces: en11 en0" line we can parse
  sc_line=$(scutil --nwi 2>/dev/null | awk -F': ' '/Network interfaces:/ {print $2; exit}')
  # sc_line might be like "en11 en0" or "en0"
  if [ -n "$sc_line" ]; then
    for cand in $sc_line; do
      # skip obvious virtuals
      case "$cand" in
        lo0|utun*|vboxnet*|vmnet*|bridge*|awdl0|llw0|utun*|vmenet* ) continue ;;
      esac

      # check candidate has IPv4 address & is reachable in scutil output
      if scutil --nwi 2>/dev/null | awk -v IF="$cand" '
          BEGIN{found=0}
          $1==IF && $0 ~ /address/ {found=1; exit}
          END{if(found) exit 0; else exit 1}
        ' ; then
        phys_iface="$cand"
        break
      fi
    done
  fi

  # fallback: if we didn't find via scutil, try networksetup mapping: first non-virtual that maps to a hardware port
  if [ -z "${phys_iface:-}" ]; then
    phys_iface=$(networksetup -listallhardwareports 2>/dev/null | awk '
      $0 ~ "Hardware Port:" { hp=$0 }
      $0 ~ "Device:" { if ($2 !~ /^utun|^lo|^bridge|^ap|^awdl|^llw|^vmenet/) {
          if (!seen[$2]++) { print $2 }
        }
      }' | head -1)
  fi

  # use phys_iface if found; otherwise keep the original iface (utun) so other logic can handle unknowns
  if [ -n "${phys_iface:-}" ]; then
    # debug: echo "vpn-default $iface -> phys $phys_iface"
    iface="$phys_iface"
  fi
fi

# get the Hardware Port (human name) for that interface, e.g. "USB 10/100/1G/2.5G LAN" or "Wi-Fi"
hwport=$(networksetup -listallhardwareports 2>/dev/null | awk -v IF="$iface" '
  $0 ~ "Hardware Port:" { hp=$0 }
  $0 ~ "Device:" && $2 == IF { print hp }
' | sed 's/Hardware Port: //')

# get the ifconfig media line for the iface (e.g. "media: autoselect (2500Base-T <full-duplex>)")
media=$(ifconfig "$iface" 2>/dev/null | awk '/media:/{print tolower($0); exit}')

# aggregate checks for wired-ish keywords (case-insensitive)
# look in hwport and media for:
#   lan, ether, ethernet, base (e.g. 1000base), 10/, 100/, 1000/, 2500base
if printf '%s\n' "$hwport" "$media" | grep -Eiq 'lan|ether|ethernet|base(-| )?t|[[:digit:]]+base|(^|[ /])10($|[^[:alnum:]])|(^|[ /])100($|[^[:alnum:]])|(^|[ /])1000($|[^[:alnum:]])|2500base'; then
    IS_WIRED=1
fi

if [[ $IS_VPN != "" && $IS_IP != "" ]]; then
    if [[ $IS_WIRED -eq 1 ]]; then
        ICON=""
    else
        ICON=""
    fi
    BG_COLOR=0x408bd5ca
    PADDING_RIGHT=-8
    LABEL="($IP)"
elif [[ $IS_IP != "" ]]; then
    if [[ $IS_WIRED -eq 1 ]]; then
        ICON=""
    else
        ICON=""
    fi
    BG_COLOR=0x40f5bde6
    LABEL="$IP"
else
    BG_COLOR=0x40f5a97f
    PADDING_RIGHT=-8
    ICON=""
    LABEL="Not Connected"
fi

sketchybar --set "$NAME" \
    label="$LABEL" \
    icon="$ICON" \
    icon.padding_right=$PADDING_RIGHT \
    background.color="$BG_COLOR" \
    background.drawing=on \
    icon.drawing=on
