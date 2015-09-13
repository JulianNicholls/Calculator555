#!/usr/bin/env ruby -I.

# This example demonstrates the use of the TextInput functionality.
# One can tab through, or click into the text fields and change its contents.
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

require 'text_input'

require '../calculator'

# Test harness for textInput field
class FirstCalc < Gosu::Window
  include GosuEnhanced

  WIDTH   = 560
  HEIGHT  = 700

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = 'First 555 Calculator'

    # Set up an array of three text fields.
    @text_fields = Array.new(3) do |index|
      TextField.new(self, Point(WIDTH - 80, 30 + index * 50))
    end

    @diagram = Gosu::Image.new('../media/Monostable.png')
  end

  def needs_cursor?
    true
  end

  def draw
    draw_rectangle(Point(0, 0), Size(WIDTH, HEIGHT), 0, Gosu::Color::WHITE)
    @diagram.draw(20, HEIGHT - (@diagram.height + 20), 0)

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
