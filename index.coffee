#############################################################################
# Customization
#############################################################################
bar =
  width: "100%"
  height: 23 # Text vertically aligns best with odd heights

  gap:
    left: 8
    right: 8
    top: 4

  font:
    color: "#fff"

  background:
    color: "rgba(30, 30, 30, 0.8)"

  border:
    radius: 1
    color: "transparent"

  padding: "0 10px"

# Time format
time: "%l:%M:%S"

# Date Format
date: "%a %d %b"

#############################################################################

style: """
  width: calc(#{bar.width} - #{bar.gap.left * 3 + bar.gap.right * 2}px)
  height: #{bar.height}px
  left: #{bar.gap.left}px
  top: #{bar.gap.top}px
  color: #{bar.font.color}
  background-color: #{bar.background.color}
  padding: #{bar.padding}
  z-index: 20

  border-radius: #{bar.border.radius}px;
  border-color: #{bar.border.color}

  box-shadow: 0px 0px 20px #333333

  font-size: 13px
  font-family: 'Helvetica Neue'

  div
    display: inline-block
    height: #{bar.height}px
    line-height: #{bar.height}px

  span
    vertical-align: middle
    line-height: normal
    text-transform: lowercase;

  .left
    float: left

  .right
    float: right
    padding-left: 15px

  .center
    position: absolute
    left: 0
    width: 100%
    text-align: center

  .playing
    .icon
      padding: 0 3px

  .battery
    .icon
      margin-left: 3px
    .fa-battery-empty
      color: red

  .icon
    font-size: 16px

  .focused
    margin-top: -2px

    .icon
      margin-left: 3px
      
  .blue
    color: #3a81c3

  .teal
    color: #2aa1ae

  .white
    color: #ededed

  .grey
    color: #b3b9be
"""

command: "#{process.argv[0]} bar/commands/update.js"

refreshFrequency: 1000 # ms

render: (output) ->
  @run("bar/install")
  """
    <link rel="stylesheet" href="bar/assets/font-awesome/css/font-awesome.min.css" />

    <div class='left focused'>
      <span></span>
    </div>

    <div class='right time'>
      <span></span>
    </div>

    <div class='right date'>
      <span></span>
    </div>

    <div class='right battery'>
      <span></span>
      <span class="icon"></span>
    </div>

    <div class='center playing'>
      <span class="icon"></span>
      <span></span>
    </div>
  """

update: (output, el) ->
  data = JSON.parse(output)
  @addFocused(data.active, el)
  @addTime(data.time, el)
  @addDate(data.date, el)
  @addBattery(data.battery, el)
  @addPlaying(data.music, el)

addFocused: (output, el) ->
  values = output.split('@')
  file = ""
  screenhtml = ""
  mode = values[0]
  screens = values[1]
  wins = values[2]
  win = ""
  i = 0

  screensegs = screens.split('(')

  for sseg in screensegs
    screensegs[i] = sseg.replace /^\s+|\s+$/g, ""
    i+=1

  screensegs = (x for x in screensegs when x != '')

  i = 0

  #apply a proper number tag so that space change controls can be added
  for sseg in screensegs
    i += 1
    # the active space has a closing paren aroound the name
    if sseg.slice(-1) == ")"
      screenhtml += "<span class='icon fa fa-circle'></span>"
    else
      screenhtml += "<span class='icon grey screen#{i} fa fa-circle'></span>"

  $(".focused span", el).html("<span class='icon fa fa-terminal'></span>&nbsp;&nbsp;&nbsp;" +
                              "<span class='white'>#{mode} " +
							  "<span class='blue'> ⎢ </span></span>" +
							  screenhtml)

addDate: (date, el) ->
  $(".date span", el).text(date)

addTime: (time, el) ->
  $(".time span, el").text(time)

addBattery: (battery, el) ->
  battery = parseInt(battery)
  $(".battery span:first-child", el).text("#{battery}%")
  $icon = $(".battery span.icon", el)
  $icon.removeClass().addClass("icon")
  $icon.addClass("fa #{@batteryIcon(battery)}")

addPlaying: (music, el) ->
  @source ||= {}

  # DOM handles
  $icon = $(".playing span.icon")
  $playing = $(".playing span:last-child", el)

  if music and music.playing
      $icon.addClass("fa fa-play-circle")
      $playing.text(music.track)
  else
      $icon.removeClass("fa-play-circle")
      $playing.text("")

  @source = "iTunes"

batteryIcon: (percentage) =>
  return if percentage > 90
    "fa-battery-full"
  else if percentage > 70
    "fa-battery-three-quarters"
  else if percentage > 40
    "fa-battery-half"
  else if percentage > 20
    "fa-battery-quarter"
  else
    "fa-battery-empty"
