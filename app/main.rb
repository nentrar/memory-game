require 'app/words.rb'

def tick(args)
  args.state.active_scene ||= 'menu'

  case args.state.active_scene
  when 'menu'
    render_menu(args)
  when 'game'
    args.state.boss_life ||= 100
    args.state.player_life ||= 10
    render_game(args)
  end
end

def initialize_card_set(args)
  srand(Time.now.to_i + rand(1000))

  args.state.words = DICTIONARY.random_entries(10).map do |entry|
    [entry[:en], entry[:es]]
  end.flatten

  args.state.cards = args.state.words.each_with_index.map do |word, i|
    { id: i, word: word, matched: false, x: nil, y: nil }
  end

  assign_dimensions(args)

  args.state.selected_cards = []
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
    
    max_character_length = 12
    wrapped_text = String.wrapped_lines(card[:word], max_character_length)
    
    wrapped_text.each_with_index do |line, index|
      args.outputs.labels << {
        x: card[:x] + 100, 
        y: card[:y] + 60 - (index * 25), 
        text: line,
        size_enum: 5,
        alignment_enum: 1, 
        r: 0, g: 0, b: 0
      }
    end
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
  
  pair = DICTIONARY.entries.find do |entry|
    (entry[:en] == card1[:word] && entry[:es] == card2[:word]) ||
    (entry[:es] == card1[:word] && entry[:en] == card2[:word])
  end

  if pair
    card1[:matched] = card2[:matched] = true
    args.state.boss_life -= 1
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
  args.outputs.labels << [10, 700, "Matches: #{args.state.boss_life}", 15, 0, 0, 0, 0, 255]
  args.outputs.labels << [1000, 700, "Chances: #{args.state.player_life}", 15, 0, 0, 0, 0, 255]

  if args.state.cards.all? { |c| c[:matched] }
    if args.state.boss_life > 0
      next_round(args)
    else
      args.outputs.labels << [640, 700, "You Win!", 15, 1, 0, 0, 0]
      args.outputs.labels << [640, 40, "Press Space to restart.", 5, 1, 0, 0, 0]
      args.state.restart = true
    end
  elsif args.state.player_life == 0
    args.outputs.labels << [640, 700, "You Lose!", 15, 1, 0, 0, 0]
    args.outputs.labels << [640, 40, "Press Space to restart.", 5, 1, 0, 0, 0]
    args.state.restart = true
  end
  
  if args.state.restart && args.inputs.keyboard.key_down.space
    args.state.init = false
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
  initialize_card_set(args) unless args.state.init
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

def next_round(args)
  args.state.selected_cards.clear
  args.state.init = false
end