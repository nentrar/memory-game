def tick(args)
  render_menu(args)
end

def initialize_game(args)
  colors = [:red, :blue, :green, :yellow, :purple, :orange, :cyan, :pink] * 2
  colors.shuffle!
  
  args.state.cards = colors.each_with_index.map do |color, i|
    { id: i, color: color, revealed: false, matched: false, x: nil, y: nil}
  end

  assign_dimensions(args)

  args.state.selected_cards = []
  args.state.score = 0
  args.state.showing_cards = true
  args.state.timer = args.state.tick_count + 180
  args.state.player_life = 3
  args.state.init = true
end

def color_to_rgb(color)
  {
    red: [255, 0, 0],
    blue: [0, 0, 255],
    green: [0, 255, 0],
    yellow: [255, 255, 0],
    purple: [128, 0, 128],
    orange: [255, 165, 0],
    cyan: [0, 255, 255],
    pink: [255, 192, 203]
  }[color] || [255, 255, 255] 
end


def render_board(args)
      args.state.cards.each do |card|
        color = if card[:matched]
                  [128, 128, 128]  
                elsif card[:revealed] || args.state.showing_cards
                  color_to_rgb(card[:color]) 
                else
                  [50, 50, 50]
                end
        args.outputs.solids << [card[:x], card[:y], 100, 100, *color]
      end
end


def handle_input(args)
  return if args.state.selected_cards.size == 2 || args.state.showing_cards

  if args.inputs.mouse.click
    clicked_card = args.state.cards.find do |card|
      args.inputs.mouse.point.inside_rect?([card[:x], card[:y], 100, 100]) && !card[:revealed] && !card[:matched]
    end

    if clicked_card
      clicked_card[:revealed] = true
      args.state.selected_cards << clicked_card
    end
  end
end

def check_match(args)
  return unless args.state.selected_cards.size == 2 && args.state.match_timer == nil

  card1, card2 = args.state.selected_cards

  if card1[:color] == card2[:color]
    puts "Colors are matched!"
    card1[:matched] = card2[:matched] = true
    args.state.score += 1
    args.state.selected_cards.clear
  else
    puts "Colors are not matched!"
    card1[:revealed] = card2[:revealed] = true
    args.state.player_life -= 1
    args.state.match_timer = args.state.tick_count + 60
  end
end

def handle_match_timer(args)
  return unless args.state.match_timer

  if args.state.tick_count > args.state.match_timer
    args.state.selected_cards.each { |card| card[:revealed] = false }
    args.state.selected_cards.clear
    args.state.match_timer = nil
  end
end


def render_ui(args)
  args.outputs.labels << [10, 700, "Score: #{args.state.score}", 15, 0, 0, 0, 0, 255]
  args.outputs.labels << [1100, 700, "Life: #{args.state.player_life}", 15, 0, 0, 0, 0, 255]

  if args.state.cards.all? { |c| c[:matched] }
    args.outputs.labels << [640, 700, "You Win!", 15, 1, 0, 0, 0]
  end

  if args.state.player_life == 0
    args.outputs.labels << [640, 700, "You Lose!", 15, 1, 0, 0, 0]
    args.outputs.labels << [640, 40, "Press Space to start again.", 5, 1, 0, 0, 0]
    if args.inputs.keyboard.key_down.space
      $gtk.reset
    end
  end

  if args.state.showing_cards && args.state.tick_count > args.state.timer
    args.state.showing_cards = false
  end
  
  handle_match_timer(args)
end

def assign_dimensions(args)

  grid_width = 4 * 150
  grid_height = 4 * 150

  offset_x = (1280 - grid_width) / 2
  offset_y = (720 - grid_height) / 2

  index = 0

  4.times do |x|
    4.times do |y|
      card = args.state.cards[index]
      break unless card

      card.x = x * 150 + offset_x
      card.y = y * 150 + offset_y

      index += 1
    end
  end
end

def render_game(args)
  args.state.init ||= false
  initialize_game(args) unless args.state.init
  render_board(args)
  handle_input(args)
  check_match(args)
  handle_match_timer(args)
  render_ui(args)
end

def render_menu(args)
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
  }
  
  args.outputs.solids << {
    x: 550,
    y: 350,
    w: 150,
    h: 50,
    r: 0,
    g: 0,
    b: 0,
    a: 128
  }

  args.outputs.labels << [625, 388, "Start Game", 2, 1, 255, 255, 255]

  if args.inputs.mouse.click && args.inputs.mouse.point.inside_rect?([550, 350, 150,50])
    args.outputs.solids.clear
    args.outputs.labels.clear
    render_game(args)
  end

end
