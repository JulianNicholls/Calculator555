require 'gosu_enhanced'

# Text field class
class TextField < Gosu::TextInput
  include GosuEnhanced

  # Some constants that define our appearance.
  SELECTION_COLOR = 0xcc88ffff
  BOTTOM_PAD      = 1
  REST_PAD        = 5

  def initialize(window, point, text = '')
    # TextInput's constructor doesn't expect any arguments.
    super()

    @window   = window
    @font     = Gosu::Font.new(18, name: Gosu.default_font_name)
    @point    = point
    @border   = Region(@point.offset(-REST_PAD, -REST_PAD),
                       @point.offset(width + 2 * REST_PAD, height + REST_PAD + BOTTOM_PAD))
    self.text = text
  end

  # Example filter method. You can truncate the text to employ a length limit,
  # limit the text to certain characters etc.
  def filter(text)
    text.match /[0-9\-.]*/
  end

  def draw
    draw_background
    draw_selection
    draw_caret

    # Finally, draw the text itself!
    @font.draw(text, @point.x, @point.y, 0, 1, 1, 0xff000000)
  end

  # This text field grows with the text that's being entered.
  # (Usually one would use clip_to and scroll around on the text field.)
  def width
    45
    # [200, @font.text_width(text)].max
  end

  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    @border.contains?(mouse_x, mouse_y)
  end

  # Tries to move the caret to the position specified by mouse_x
  def move_caret(mouse_x)
    len = text.length
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = len

    # Test character by character
    1.upto(len) do |index|
      next unless mouse_x < @point.x + @font.text_width(text[0...index])

      self.caret_pos = self.selection_start = index - 1
      break
    end
  end

  private

  def draw_background
    border   = active_field? ? Gosu::Color::BLUE : Gosu::Color::BLACK
    top_left = @border.position
    size     = @border.size

    @window.draw_rectangle(top_left, size, 0, border)
    @window.draw_rectangle(top_left.offset(2, 2),
                           size.deflate(4, 4), 0, Gosu::Color::WHITE)
  end

  # Draw the selection background, if any; if not, sel_x and pos_x will be
  # the same value, making this rectangle empty.

  def draw_selection
    return unless active_field? && sel_x != pos_x

    sel_left  = [sel_x, pos_x].min
    sel_width = [sel_x, pos_x].max - sel_left

    @window.draw_rectangle(@point.offset(sel_left, 0), Size(sel_width, height),
                           0, SELECTION_COLOR)
  end

  # Draw the caret; again, only if this is the currently selected field.
  def draw_caret
    return unless active_field?

    @window.draw_simple_line(@point.offset(sel_x, 0),
                             @point.offset(pos_x + 1, height),
                             0, Gosu::Color::BLACK)
  end

  # Calculate the position of the caret and the selection start.
  def pos_x
    @font.text_width(text[0...caret_pos])
  end

  def sel_x
    @font.text_width(text[0...selection_start])
  end

  # Are we the active field
  def active_field?
    @window.text_input == self
  end
end
