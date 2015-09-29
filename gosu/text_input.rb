require 'gosu_enhanced'
require 'constants'

# The Gosu TextInput object maintains the position of the caret as the index
# of the character that it's left of via the caret_pos attribute. If there is
# a selection, the selection_start attribute yields its beginning, using the
# same indexing scheme. If there is no selection, selection_start is equal to
# caret_pos.

# A TextInput object is purely abstract; drawing the input field is left to
# the user. In this case, we are subclassing TextInput to add this code.
# As with most of Gosu, how this is handled is completely left open; Gosu only
# aims to provide enough code for games (or intermediate UI toolkits) to be
# built upon it.

# Text field class
# :reek:TooManyMethods
class TextField < Gosu::TextInput
  include GosuEnhanced
  include Constants

  def initialize(window, point, text = '', options = {})
    # Gosu::TextInput's constructor doesn't expect any arguments.
    super()

    @window     = window
    @point      = point
    self.text   = text

    @base_size  = options.fetch(:width, 60)
    @font       = options.fetch(:font, tf_default_font)
  end

  # Restrict the text to minus (not actually needed), decimal point, and 0-9
  # :reek:UtilityFunction
  def filter(text)
    text.match(/[0-9\-.]*/)
  end

  def draw
    draw_background
    draw_selection
    draw_caret

    @font.draw(text, @point.x, @point.y, 0, 1, 1, 0xff000000)
  end

  # Potentially grow size
  def width
    [@base_size, full_text_width].max
  end

  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    border.contains?(mouse_x, mouse_y)
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

  # :reek:UtilityFunction
  def tf_default_font
    Gosu::Font.new(18, name: Gosu.default_font_name)
  end

  def border
    @border ||= Region(
      @point.offset(-REST_PAD, -REST_PAD),
      Size(width + 2 * REST_PAD, height + REST_PAD + BOTTOM_PAD)
    )
  end

  def draw_background
    border_clr  = active_field? ? Gosu::Color::BLUE : Gosu::Color::BLACK
    top_left    = border.position
    size        = border.size

    @window.draw_rectangle(top_left, size, 0, border_clr)
    @window.draw_rectangle(top_left.offset(2, 2),
                           size.deflate(4, 4), 0, Gosu::Color::WHITE)
  end

  # Draw the selection background, if any; if not, sel_x and pos_x will be
  # the same value, making this rectangle empty.

  def draw_selection
    return unless active_field? && sel_x != pos_x

    @window.draw_rectangle(
      @point.offset(sel_left, 0), Size(sel_width, height), 0, SELECTION_COLOR
    )
  end

  # Draw the caret; again, only if this is the currently selected field.
  def draw_caret
    return unless active_field?

    @window.draw_simple_line(@point.offset(sel_x, 0),
                             @point.offset(pos_x + 1, height),
                             0, Gosu::Color::BLACK)
  end

  def full_text_width
    @font.text_width(text)
  end

  # Calculate the position and width of the selection rectangle, if any
  def sel_left
    [sel_x, pos_x].min
  end

  def sel_width
    [sel_x, pos_x].max - sel_left
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
