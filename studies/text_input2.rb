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
  INACTIVE_COLOR  = 0xccbbbbbb
  ACTIVE_COLOR    = 0xccffffff
  SELECTION_COLOR = 0xcc8888ff
  CARET_COLOR     = 0xff000000
  PADDING         = 5

  attr_reader :x, :y

  def initialize(window, font, x, y)
    # TextInput's constructor doesn't expect any arguments.
    super()

    @window = window
    @font   = font
    @x      = x
    @y      = y

    # Start with a self-explanatory text in each field.
    self.text = 'Click to change text'
  end

  # Example filter method. You can truncate the text to employ a length limit,
  # limit the text to certain characters etc.
  def filter(text)
    text.upcase
  end

  def draw
    draw_background
    draw_selection
    draw_caret

    # Finally, draw the text itself!
    @font.draw(text, x, y, 0, 1, 1, 0xff000000)
  end

  # This text field grows with the text that's being entered.
  # (Usually one would use clip_to and scroll around on the text field.)
  def width
    [200, @font.text_width(text)].max
  end

  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    mouse_x.between?(x - PADDING, x + width + PADDING) &&
      mouse_y.between?(y - PADDING, y + height + PADDING)
  end

  # Tries to move the caret to the position specified by mouse_x
  def move_caret(mouse_x)
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = text.length

    # Test character by character
    1.upto(text.length) do |i|
      next unless mouse_x < x + @font.text_width(text[0...i])

      self.caret_pos = self.selection_start = i - 1
      break
    end
  end

  private

  def draw_background
    # Depending on whether this is the currently selected input or not, change
    # the background's color.
    background = active_field? ? ACTIVE_COLOR : INACTIVE_COLOR

    @window.draw_rectangle(Point(x - PADDING, y - PADDING),
                           Size(width + 2 * PADDING, height + 2 * PADDING),
                           0, background)
  end

  # Draw the selection background, if any; if not, sel_x and pos_x will be
  # the same value, making this rectangle empty.

  def draw_selection
    return if sel_x == pos_x

    sel_left  = [sel_x, pos_x].min
    sel_width = [sel_x, pos_x].max - left

    @window.draw_rectangle(Point(sel_left, y), Size(sel_width, height),
                           0, SELECTION_COLOR)
  end

  # Draw the caret; again, only if this is the currently selected field.
  def draw_caret
    return unless active_field?

    @window.draw_simple_line(Point(pos_x, y), Point(pos_x, y + height),
                             0, CARET_COLOR)
  end

  # Calculate the position of the caret and the selection start.
  def pos_x
    x + @font.text_width(text[0...caret_pos])
  end

  def sel_x
    x + @font.text_width(text[0...selection_start])
  end

  # Are we the active field
  def active_field?
    @window.text_input == self
  end
end

# Test harness for textInput field
class TextInputWindow < Gosu::Window
  def initialize
    super(400, 300, false)
    self.caption = 'Text Input Example'

    font = Gosu::Font.new(self, Gosu.default_font_name, 16)

    # Set up an array of three text fields.
    @text_fields = Array.new(3) do |index|
      TextField.new(self, font, 50, 30 + index * 50)
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

TextInputWindow.new.show
