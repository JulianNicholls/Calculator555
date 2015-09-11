# This example demonstrates the use of the TextInput functionality.
# One can tab through, or click into the text fields and change it's contents.
# At its most basic form, you only need to create a new TextInput instance and
# set the text_input attribute of your window to it. Until you set this
# attribute to nil again, the TextInput object will build a text that can be
# accessed via TextInput#text.

# The TextInput object also maintains the position of the caret as the index
# of the character that it's left to via the caret_pos attribute. Furthermore,
# if there is a selection, the selection_start attribute yields its beginning,
# using the same indexing scheme. If there is no selection, selection_start
# is equal to caret_pos.

# A TextInput object is purely abstract, though; drawing the input field is left
# to the user. In this case, we are subclassing TextInput to add this code.
# As with most of Gosu, how this is handled is completely left open; the scheme
# presented here is not mandatory! Gosu only aims to provide enough code for
# games (or intermediate UI toolkits) to be built upon it.

require 'gosu_enhanced'

# Text field class
class TextField < Gosu::TextInput
  include GosuEnhanced

  # Some constants that define our appearance.
  SELECTION_COLOR = 0xcc8888ff
  CARET_COLOR     = 0xff000000
  PADDING         = 5

  attr_reader :x, :y

  def initialize(window, point, text = '')
    # TextInput's constructor doesn't expect any arguments.
    super()

    @window   = window
    @font     = Gosu::Font.new(18, name: Gosu.default_font_name)
    @point    = point
    self.text = text
  end

  # Example filter method. You can truncate the text to employ a length limit,
  # limit the text to certain characters etc.
  # def filter(text)
  #   text.upcase
  # end

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
    Region(@point.offset(-PADDING, -PADDING),
           @point.offset(width + 2 * PADDING, width + 2 * PADDING))
      .contains?(mouse_x, mouse_y)
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
    pad2 = 2 * PADDING

    @window.draw_rectangle(@point.offset(-PADDING, -PADDING),
                           Size(width + pad2, height + pad2),
                           0, Gosu::Color::WHITE)
  end

  # Draw the selection background, if any; if not, sel_x and pos_x will be
  # the same value, making this rectangle empty.

  def draw_selection
    return if sel_x == pos_x

    sel_left  = [sel_x, pos_x].min
    sel_width = [sel_x, pos_x].max - left

    @window.draw_rectangle(@point.offset(sel_left, 0), Size(sel_width, height),
                           0, SELECTION_COLOR)
  end

  # Draw the caret; again, only if this is the currently selected field.
  def draw_caret
    return unless active_field?

    @window.draw_simple_line(@point.offset(sel_x, 0),
                             @point.offset(pos_x, height), 0, CARET_COLOR)
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

# Test harness for textInput field
class FirstCalc < Gosu::Window
  include GosuEnhanced

  def initialize
    super(600, 600, false)
    self.caption = 'First 555 Calculator'

    # Set up an array of three text fields.
    @text_fields = Array.new(3) do |index|
      TextField.new(self, Point(520, 30 + index * 50))
    end
  end

  def needs_cursor?
    true
  end

  def draw
    @text_fields.each(&:draw)
  end

  def button_down(id)
    case id
    when Gosu::KbTab    then set_next_field
    when Gosu::KbEscape then unselect_or_exit
    when Gosu::MsLeft   then select_field
    end
  end

  private

  def set_next_field
    # Tab key will not be 'eaten' by text fields; use for switching through
    # text fields.
    index = @text_fields.index(text_input) || -1
    self.text_input = @text_fields[(index + 1) % @text_fields.size]
  end

  def unselect_or_exit
    # Escape key will not be 'eaten' by text fields; use for deselecting.
    if text_input
      self.text_input = nil
    else
      close
    end
  end

  def select_field
    # Mouse click: Select text field based on mouse position.
    self.text_input = @text_fields.find do |tf|
      tf.under_point?(mouse_x, mouse_y)
    end

    # Advanced: Move caret to clicked position
    text_input.move_caret(mouse_x) unless text_input.nil?
  end
end

FirstCalc.new.show
