def tick args
  args.state.current_scene ||= :title_scene

  current_scene = args.state.current_scene

  case current_scene
  when :title_scene
    tick_title_scene args
  when :game_scene
    tick_game_scene args
  when :game_over_scene
    tick_game_over_scene args
  end

  if args.state.current_scene != current_scene
    raise "Scene was changed incorrectly. Set args.state.next_scene to change scenes."
  end

  if args.state.next_scene
    args.state.current_scene = args.state.next_scene
    args.state.next_scene = nil
  end
end

def tick_title_scene args
  args.outputs.background_color = [255, 255, 255]
  args.outputs.labels << [320, 500, "20 Second Circle Clicker", 20, 255, 0, 0, 0]
  args.outputs.labels << [150, 400, "Click on as many circles as you can within 20 seconds!", 10, 255, 0, 0, 0]
  args.outputs.labels << [370, 300, "Press the Enter key to start.", 10, 255, 0, 0, 0]
  args.outputs.sprites << {x: 200, y: 600, w: 63, h: 63, path:'sprites/circle-red.png'}
  args.outputs.sprites << {x: 900, y: 100, w: 64, h: 64, path:'sprites/square-red.png'}

  if args.inputs.keyboard.enter
    args.state.next_scene = :game_scene
  end
end

def tick_game_scene args
  args.state.click_animation ||= []
  args.state.miss_click_animation ||= []
  args.state.circles_clicked ||= 0
  args.state.squares_clicked ||= 0
  args.state.misses ||= 0
  args.state.circle ||= {x: 100, y: 100, w: 63, h: 63, path:'sprites/circle-red.png'}
  args.state.circle_center_point ||= {x: 100, y: 100}
  args.state.square ||= {x: 700, y: 500, w: 64, h: 64, path:'sprites/square-red.png'}
  args.state.circle_new_x ||= 100
  args.state.circle_new_y ||= 100
  args.state.square_new_x ||= 100
  args.state.square_new_y ||= 100
  args.state.time_seconds ||= 20
  args.state.time_frame ||= 0

  if args.state.time_seconds > 0
    args.state.time_frame += 1
  end

  if args.state.time_seconds == 0
    args.state.next_scene = :game_over_scene
  end

  if args.state.time_frame == 59
    args.state.time_frame = 0
    args.state.time_seconds -= 1
  end

  args.state.circle_center_point[:x] = args.state.circle[:x] + 32
  args.state.circle_center_point[:y] = args.state.circle[:y] + 32

  args.state.click_animation.each do |click|
    click[:age]  += 0.5
    click[:path] = "sprites/circle-click-animation-#{click[:age].floor}.png"
  end
  args.state.click_animation = args.state.click_animation.reject { |click| click[:age] >= 9 }

  args.state.miss_click_animation.each do |click|
    click[:age]  += 0.5
    click[:path] = "sprites/miss-click-animation-#{click[:age].floor}.png"
  end
  args.state.miss_click_animation = args.state.miss_click_animation.reject { |click| click[:age] >= 9 }


  if args.inputs.mouse.inside_circle? args.state.circle_center_point, 31
    if args.inputs.mouse.click
      args.state.click_animation << {x: args.inputs.mouse.x - 15, y: args.inputs.mouse.y - 15, w: 31, h: 31, path: 'sprites/circle-click-animation-0.png', age: 0}
      move_target args
      args.state.circles_clicked += 1
    end
  elsif args.inputs.mouse.inside_rect? args.state.square
    if args.inputs.mouse.click
      args.state.miss_click_animation << {x: args.inputs.mouse.x - 15, y: args.inputs.mouse.y - 15, w: 31, h: 31, path: 'sprites/miss-click-animation-0.png', age: 0}
      move_target args
      args.state.squares_clicked += 1
    end
  else
    if args.inputs.mouse.click
      args.state.miss_click_animation << {x: args.inputs.mouse.x - 15, y: args.inputs.mouse.y - 15, w: 31, h: 31, path: 'sprites/miss-click-animation-0.png', age: 0}
      args.state.misses += 1
    end
  end

  args.outputs.background_color = [255, 255, 255]
  args.outputs.labels << [50, 700, "Time    #{(args.state.time_seconds)}", 5, 255, 0, 0, 0]
  args.outputs.sprites << args.state.circle
  args.outputs.sprites << args.state.square
  args.outputs.sprites << args.state.click_animation
  args.outputs.sprites << args.state.miss_click_animation
end

def tick_game_over_scene args
  args.outputs.background_color = [255, 255, 255]
  args.outputs.labels << [560, 500, "Times up!", 10, 255, 0, 0, 0]
  args.outputs.labels << [460, 450, "Circles clicked: #{(args.state.circles_clicked)}", 10, 255, 0, 0, 0]
  args.outputs.labels << [460, 400, "Squares clicked: #{(args.state.squares_clicked)}", 10, 255, 0, 0, 0]
  args.outputs.labels << [460, 350, "Clicks that missed: #{(args.state.misses)}", 10, 255, 0, 0, 0]
  args.outputs.labels << [320, 300, "Press the Enter key to try again.", 10, 255, 0, 0, 0]
  if args.inputs.keyboard.enter
    args.state.next_scene = :game_scene
    args.state.circles.clear
    args.state.circles_clicked = 0
    args.state.squares_clicked = 0
    args.state.misses = 0
    args.state.time_seconds = 20
  end
end

def random_x args
  (args.grid.w.randomize :ratio) * -1
end

def random_y args
  (args.grid.h.randomize :ratio) * -1
end

def move_target args
  args.state.circle_new_x = rand(1280 - args.state.circle[:w])
  args.state.circle_new_y = rand(720 - args.state.circle[:h])
  if args.state.circle_new_x.between?(args.state.circle[:x] - (args.state.circle[:w]), args.state.circle[:x] + (args.state.circle[:w] * 2))
    args.state.circle_new_x = rand(1280 - args.state.circle[:w])
  end
  if args.state.circle_new_y.between?(args.state.circle[:y] - (args.state.circle[:h]), args.state.circle[:y] + (args.state.circle[:h] * 2))
    args.state.circle_new_y = rand(720 - args.state.circle[:h])
  end
  args.state.circle[:x] = args.state.circle_new_x
  args.state.circle[:y] = args.state.circle_new_y

  args.state.square_new_x = rand(1280 - args.state.square[:w])
  args.state.square_new_y = rand(720 - args.state.square[:h])
  if args.state.square_new_x.between?(args.state.square[:x] - (args.state.square[:w]), args.state.square[:x] + (args.state.square[:w] * 2))
    args.state.square_new_x = rand(1280 - args.state.square[:w])
  end
  if args.state.square_new_y.between?(args.state.square[:y] - (args.state.square[:h]), args.state.square[:y] + (args.state.square[:h] * 2))
    args.state.square_new_y = rand(720 - args.state.square[:h])
  end
  if args.state.square_new_x.between?(args.state.circle[:x] - (args.state.circle[:w]), args.state.circle[:x] + (args.state.circle[:w] * 2))
    args.state.square_new_x = rand(1280 - args.state.square[:w])
  end
  if args.state.square_new_y.between?(args.state.circle[:y] - (args.state.circle[:h]), args.state.circle[:y] + (args.state.circle[:h] * 2))
    args.state.square_new_y = rand(720 - args.state.square[:h])
  end
  args.state.square[:x] = args.state.square_new_x
  args.state.square[:y] = args.state.square_new_y
end