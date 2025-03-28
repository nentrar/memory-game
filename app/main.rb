require 'app/words.rb'

def tick(args)
  args.state.active_scene ||= 'menu'

  case args.state.active_scene
  when 'menu'
    render_menu(args)
  when 'game'
    render_game(args)
  end
end

def initialize_game(args)
  words = WORDS.shuffle.flatten
  
  args.state.cards = words.each_with_index.map do |word, i|
    { id: i, word: word, matched: false, x: nil, y: nil }
  end

  assign_dimensions(args)

  args.state.selected_cards = []
  args.state.score = 0
  args.state.player_life = 3
  args.state.init = true
end

def render_board(args)
  args.state.cards.each do |card|
    color = if card[:matched]
              [0, 200, 0]
            elsif card[:flash_red]
              [255, 0, 0] 
            elsif args.state.selected_cards.include?(card)
              [255, 255, 0]
            else
              [200, 200, 200]
            end
    
    args.outputs.solids << [card[:x], card[:y], 200, 80, *color]
    args.outputs.labels << [card[:x] + 100, card[:y] + 40, card[:word], 5, 1, 0, 0, 0]
  end
end

def handle_input(args)
  return if args.state.selected_cards.size == 2
  
  if args.inputs.mouse.click
    clicked_card = args.state.cards.find do |card|
      args.inputs.mouse.point.inside_rect?([card[:x], card[:y], 200, 80]) && !card[:matched]
    end

    if clicked_card
      args.state.selected_cards << clicked_card
    end
  end
end

def check_match(args)
  return unless args.state.selected_cards.size == 2
  
  card1, card2 = args.state.selected_cards
  pair = WORDS.find { |eng, spa| (eng == card1[:word] && spa == card2[:word]) || (spa == card1[:word] && eng == card2[:word]) }
  
  if pair
    card1[:matched] = card2[:matched] = true
    args.state.score += 1
  else
    card1[:flash_red] = card2[:flash_red] = true
    args.state.player_life -= 1
    args.state.match_timer = args.state.tick_count + 30
  end
  
  args.state.selected_cards.clear
end

def handle_match_timer(args)
  return unless args.state.match_timer && args.state.tick_count > args.state.match_timer
  args.state.cards.each { |card| card[:flash_red] = false }
  args.state.match_timer = nil
end

def render_ui(args)
  args.outputs.labels << [10, 700, "Score: #{args.state.score}", 15, 0, 0, 0, 0, 255]
  args.outputs.labels << [1100, 700, "Life: #{args.state.player_life}", 15, 0, 0, 0, 0, 255]

  if args.state.cards.all? { |c| c[:matched] }
    args.outputs.labels << [640, 700, "You Win!", 15, 1, 0, 0, 0]
    args.outputs.labels << [640, 40, "Press Space to restart.", 5, 1, 0, 0, 0]
    args.state.restart = true
  elsif args.state.player_life == 0
    args.outputs.labels << [640, 700, "You Lose!", 15, 1, 0, 0, 0]
    args.outputs.labels << [640, 40, "Press Space to restart.", 5, 1, 0, 0, 0]
    args.state.restart = true
  end
  
  if args.state.restart && args.inputs.keyboard.key_down.space
    $gtk.reset
  end
end

def assign_dimensions(args)
  grid_width = 4 * 220
  grid_height = 5 * 100

  offset_x = (1280 - grid_width) / 2
  offset_y = (720 - grid_height) / 2

  index = 0
  4.times do |x|
    5.times do |y|
      card = args.state.cards[index]
      break unless card
      card.x = x * 220 + offset_x
      card.y = y * 100 + offset_y
      index += 1
    end
  end
end

def render_game(args)
  return unless args.state.active_scene == 'game'
  args.state.init ||= false
  initialize_game(args) unless args.state.init
  render_board(args)
  handle_input(args)
  check_match(args)
  handle_match_timer(args)
  render_ui(args)
end

def render_menu(args)
  return unless args.state.active_scene == 'menu'
  args.outputs.solids << [0, 0, args.grid.w, args.grid.h, 92, 120, 230]
  args.outputs.solids << [550, 350, 150, 50, 0, 0, 0, 128]
  args.outputs.labels << [625, 388, "Start Game", 2, 1, 255, 255, 255]
  
  if args.inputs.mouse.click && args.inputs.mouse.point.inside_rect?([550, 350, 150, 50])
    args.state.active_scene = 'game'
  end
end
