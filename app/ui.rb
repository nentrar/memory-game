module UI
    def self.align_rect(w, h, opts = {})
      screen_w = opts[:screen_w] || 1280
      screen_h = opts[:screen_h] || 720
      anchor   = opts[:anchor] || :center
      pad_x    = opts[:pad_x] || 0
      pad_y    = opts[:pad_y] || 0
  
      x = case anchor
          when :left, :center_left, :top_left, :bottom_left then pad_x
          when :center, :center_top, :center_bottom then (screen_w - w) / 2 + pad_x
          when :right, :center_right, :top_right, :bottom_right then screen_w - w - pad_x
          else (screen_w - w) / 2
          end
  
      y = case anchor
          when :bottom, :bottom_left, :bottom_right then pad_y
          when :center, :center_left, :center_right then (screen_h - h) / 2 + pad_y
          when :top, :top_left, :top_right then screen_h - h - pad_y
          else (screen_h - h) / 2
          end
  
      [x, y, w, h]
    end
  
    def self.align_in_rect(rect, w, h, opts = {})
      anchor = opts[:anchor] || :center
      pad_x  = opts[:pad_x] || 0
      pad_y  = opts[:pad_y] || 0
  
      x0, y0, rw, rh = rect
  
      x = case anchor
          when :left, :top_left, :bottom_left then x0 + pad_x
          when :center, :center_left, :center_right then x0 + (rw - w) / 2 + pad_x
          when :right, :top_right, :bottom_right then x0 + rw - w - pad_x
          else x0 + (rw - w) / 2
          end
  
      y = case anchor
          when :bottom, :bottom_left, :bottom_right then y0 + pad_y
          when :center, :center_left, :center_right then y0 + (rh - h) / 2 + pad_y
          when :top, :top_left, :top_right then y0 + rh - h - pad_y
          else y0 + (rh - h) / 2
          end
  
      [x, y, w, h]
    end
  
    def self.label(text, opts = {})
      size   = opts[:size] || 2
      align  = opts[:align] || 1
      color  = opts[:color] || [255, 255, 255]
      pad_x  = opts[:pad_x] || 0
      pad_y  = opts[:pad_y] || 0
      anchor = opts[:anchor] || :center
  
      char_w = size * 10 * 0.6
      w = text.length * char_w
      h = size * 10
  
      x, y, _, _ = align_rect(w, h, anchor: anchor, pad_x: pad_x, pad_y: pad_y)
      [x, y, text, size, align, *color]
    end
  
    def self.label_in_rect(text, rect, opts = {})
      size   = opts[:size] || 2
      align  = opts[:align] || 0  
      color  = opts[:color] || [255, 255, 255]
      anchor = opts[:anchor] || :center
      pad_x  = opts[:pad_x] || 0
      pad_y  = opts[:pad_y] || 0

      char_w = size * 10 * 0.6
      w = text.length * char_w
      h = size * 10

      x, y, *_ = align_in_rect(rect, w, h, anchor: anchor, pad_x: pad_x, pad_y: pad_y)

      label = [x, y, text, size, align, *color]
      label_rect = [x - (align == 0 ? w/2 : 0), y, w, h]

      { label: label, rect: label_rect }
    end

  
    def self.button(text, opts = {})
      size         = opts[:size] || 2
      padding      = opts[:padding] || 20
      bg_color     = opts[:bg] || [0, 0, 0, 128]
      border_color = opts[:border] || [255, 255, 255]
      anchor       = opts[:anchor] || :center
      pad_x        = opts[:pad_x] || 0
      pad_y        = opts[:pad_y] || 0
  
      char_w = size * 10 * 0.6
      w = text.length * char_w + padding * 2
      h = size * 10 + padding * 2
  
      x, y, _, _ = align_rect(w, h, anchor: anchor, pad_x: pad_x, pad_y: pad_y)
  
      {
        solid: [x, y, w, h] + bg_color,
        border: [x, y, w, h] + border_color,
        label: [x + w / 2, y + h / 2, text, size, 1, 255, 255, 255],
        rect: [x, y, w, h]
      }
    end
  end 