#!/usr/bin/env bash
# color-name-lookup.sh - Get human-readable color names from hex values
# Uses CSS named colors for semantic naming

set -euo pipefail

# CSS Named Colors (subset of most common/useful ones)
# Full list: https://developer.mozilla.org/en-US/docs/Web/CSS/named-color
declare -A CSS_COLORS=(
    # Reds
    ["#ff0000"]="red"
    ["#dc143c"]="crimson"
    ["#b22222"]="firebrick"
    ["#8b0000"]="darkred"
    ["#ff6347"]="tomato"
    ["#ff4500"]="orangered"
    ["#ff69b4"]="hotpink"
    ["#ff1493"]="deeppink"
    ["#c71585"]="mediumvioletred"
    ["#db7093"]="palevioletred"
    
    # Oranges/Yellows
    ["#ffa500"]="orange"
    ["#ff8c00"]="darkorange"
    ["#ffff00"]="yellow"
    ["#ffd700"]="gold"
    ["#ffffe0"]="lightyellow"
    ["#fffacd"]="lemonchiffon"
    ["#f0e68c"]="khaki"
    ["#bdb76b"]="darkkhaki"
    
    # Greens
    ["#00ff00"]="lime"
    ["#008000"]="green"
    ["#006400"]="darkgreen"
    ["#90ee90"]="lightgreen"
    ["#98fb98"]="palegreen"
    ["#32cd32"]="limegreen"
    ["#228b22"]="forestgreen"
    ["#2e8b57"]="seagreen"
    ["#3cb371"]="mediumseagreen"
    ["#00fa9a"]="mediumspringgreen"
    ["#00ff7f"]="springgreen"
    
    # Cyans/Teals
    ["#00ffff"]="cyan"
    ["#00ced1"]="darkturquoise"
    ["#40e0d0"]="turquoise"
    ["#48d1cc"]="mediumturquoise"
    ["#20b2aa"]="lightseagreen"
    ["#008080"]="teal"
    ["#008b8b"]="darkcyan"
    
    # Blues
    ["#0000ff"]="blue"
    ["#000080"]="navy"
    ["#00008b"]="darkblue"
    ["#191970"]="midnightblue"
    ["#4169e1"]="royalblue"
    ["#6495ed"]="cornflowerblue"
    ["#87ceeb"]="skyblue"
    ["#87cefa"]="lightskyblue"
    ["#add8e6"]="lightblue"
    ["#b0e0e6"]="powderblue"
    ["#5f9ea0"]="cadetblue"
    ["#4682b4"]="steelblue"
    
    # Purples/Violets
    ["#800080"]="purple"
    ["#8b008b"]="darkmagenta"
    ["#9400d3"]="darkviolet"
    ["#9932cc"]="darkorchid"
    ["#ba55d3"]="mediumorchid"
    ["#da70d6"]="orchid"
    ["#ee82ee"]="violet"
    ["#dda0dd"]="plum"
    ["#e6e6fa"]="lavender"
    ["#4b0082"]="indigo"
    ["#6a5acd"]="slateblue"
    ["#7b68ee"]="mediumslateblue"
    ["#8a2be2"]="blueviolet"
    
    # Pinks
    ["#ffc0cb"]="pink"
    ["#ffb6c1"]="lightpink"
    ["#ff69b4"]="hotpink"
    ["#ff1493"]="deeppink"
    ["#fff0f5"]="lavenderblush"
    
    # Whites/Grays/Blacks
    ["#ffffff"]="white"
    ["#f5f5f5"]="whitesmoke"
    ["#dcdcdc"]="gainsboro"
    ["#c0c0c0"]="silver"
    ["#a9a9a9"]="darkgray"
    ["#808080"]="gray"
    ["#696969"]="dimgray"
    ["#000000"]="black"
    
    # Browns
    ["#a52a2a"]="brown"
    ["#8b4513"]="saddlebrown"
    ["#d2691e"]="chocolate"
    ["#cd853f"]="peru"
    ["#f4a460"]="sandybrown"
    ["#deb887"]="burlywood"
    ["#d2b48c"]="tan"
    ["#bc8f8f"]="rosybrown"
)

# Violet Void specific color names (custom palette)
declare -A VIOLET_VOID_COLORS=(
    ["#050505"]="void-black"
    ["#0e0e0e"]="void-dark"
    ["#191919"]="void-highlight"
    ["#0f0f0f"]="void-selection"
    ["#181818"]="void-gray"
    ["#f0f0f5"]="void-foreground"
    ["#303030"]="void-muted-dark"
    ["#414141"]="void-muted"
    ["#4c4c4c"]="void-comment"
    ["#e7e7e7"]="void-white"
    ["#ff1a67"]="void-red"
    ["#ff004b"]="void-red-bright"
    ["#42ff97"]="void-green"
    ["#42ffad"]="void-green-bright"
    ["#29adff"]="void-blue"
    ["#c7b8ff"]="void-blue-bright"
    ["#00a8a4"]="void-cyan"
    ["#00fff9"]="void-cyan-bright"
    ["#fd007f"]="void-magenta"
    ["#fd0098"]="void-magenta-bright"
    ["#7c60d1"]="void-purple"
    ["#fd7cff"]="void-purple-bright"
    ["#ff7c7e"]="void-orange"
    ["#ffd93d"]="void-yellow"
)

# Function to convert hex to RGB
hex_to_rgb() {
    local hex="$1"
    hex="${hex#\#}"
    
    if [[ ${#hex} -eq 3 ]]; then
        r=$((16#${hex:0:1}${hex:0:1}))
        g=$((16#${hex:1:1}${hex:1:1}))
        b=$((16#${hex:2:1}${hex:2:1}))
    elif [[ ${#hex} -eq 6 ]]; then
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
    else
        echo "Invalid hex color: $hex" >&2
        return 1
    fi
    
    echo "$r $g $b"
}

# Function to calculate color distance (Euclidean)
color_distance() {
    local r1=$1 g1=$2 b1=$3
    local r2=$4 g2=$5 b2=$6
    
    echo $(( (r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2 ))
}

# Function to find closest named color
find_closest_color() {
    local target_hex="$1"
    local target_rgb
    target_rgb=$(hex_to_rgb "$target_hex")
    read -r tr tg tb <<< "$target_rgb"
    
    local closest_name=""
    local closest_distance=999999999
    local is_violet_void=false
    
    # First check Violet Void palette for exact match
    if [[ -n "${VIOLET_VOID_COLORS[$target_hex]:-}" ]]; then
        echo "${VIOLET_VOID_COLORS[$target_hex]} (Violet Void palette)"
        return 0
    fi
    
    # Then check CSS colors for exact match
    local lower_hex="${target_hex,,}"
    for color in "${!CSS_COLORS[@]}"; do
        if [[ "${color,,}" == "$lower_hex" ]]; then
            echo "${CSS_COLORS[$color]} (CSS named color)"
            return 0
        fi
    done
    
    # No exact match, find closest from both palettes
    for color in "${!VIOLET_VOID_COLORS[@]}"; do
        local rgb
        rgb=$(hex_to_rgb "$color")
        read -r r g b <<< "$rgb"
        local dist
        dist=$(color_distance "$tr" "$tg" "$tb" "$r" "$g" "$b")
        if [[ $dist -lt $closest_distance ]]; then
            closest_distance=$dist
            closest_name="${VIOLET_VOID_COLORS[$color]} (Violet Void)"
            is_violet_void=true
        fi
    done
    
    for color in "${!CSS_COLORS[@]}"; do
        local rgb
        rgb=$(hex_to_rgb "$color")
        read -r r g b <<< "$rgb"
        local dist
        dist=$(color_distance "$tr" "$tg" "$tb" "$r" "$g" "$b")
        if [[ $dist -lt $closest_distance ]]; then
            closest_distance=$dist
            closest_name="${CSS_COLORS[$color]} (CSS)"
            is_violet_void=false
        fi
    done
    
    echo "$closest_name"
}

# Function to describe color characteristics
describe_color() {
    local hex="$1"
    local rgb
    rgb=$(hex_to_rgb "$hex")
    read -r r g b <<< "$rgb"
    
    # Calculate brightness (perceived)
    local brightness=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
    
    # Calculate saturation
    local max=$((r > g ? (r > b ? r : b) : (g > b ? g : b)))
    local min=$((r < g ? (r < b ? r : b) : (g < b ? g : b)))
    local saturation=0
    if [[ $max -gt 0 ]]; then
        saturation=$(( ((max - min) * 100) / max ))
    fi
    
    # Determine color family
    local family=""
    if [[ $saturation -lt 10 ]]; then
        if [[ $brightness -lt 30 ]]; then
            family="black/very dark gray"
        elif [[ $brightness -gt 220 ]]; then
            family="white/very light gray"
        else
            family="gray"
        fi
    elif [[ $r -gt $g && $r -gt $b ]]; then
        if [[ $g -gt $b ]]; then
            family="orange/yellow"
        else
            family="red/pink"
        fi
    elif [[ $g -gt $r && $g -gt $b ]]; then
        family="green"
    elif [[ $b -gt $r && $b -gt $g ]]; then
        if [[ $r -gt $g ]]; then
            family="purple/magenta"
        else
            family="blue/cyan"
        fi
    else
        family="neutral"
    fi
    
    echo "Brightness: $brightness/255, Saturation: ${saturation}%, Family: $family"
}

# Main
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <hex-color> [hex-color...]"
        echo "       $0 --palette  (show all Violet Void colors)"
        echo ""
        echo "Examples:"
        echo "  $0 '#7c60d1'     # Look up single color"
        echo "  $0 '#ff1a67' '#42ff97'  # Look up multiple colors"
        exit 1
    fi
    
    if [[ "$1" == "--palette" ]]; then
        echo "Violet Void Color Palette:"
        echo "==========================="
        for color in "${!VIOLET_VOID_COLORS[@]}"; do
            printf "  %-10s %s\n" "$color" "${VIOLET_VOID_COLORS[$color]}"
        done | sort -k2
        exit 0
    fi
    
    for hex in "$@"; do
        echo "Color: $hex"
        echo "  Closest match: $(find_closest_color "$hex")"
        echo "  Characteristics: $(describe_color "$hex")"
        echo ""
    done
}

main "$@"
