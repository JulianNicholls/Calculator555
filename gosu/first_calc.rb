#!/usr/bin/env ruby -I.

# This example demonstrates the use of the TextInput functionality.
# One can tab through, or click into the text fields and change its contents.
# At its most basic form, you only need to create a new TextInput instance and
# set the text_input attribute of your window to it. Until you set this
# attribute to nil again, the TextInput object will build a text that can be
# accessed via TextInput#text.

require 'text_input'

require '../calculator'
require 'label_render'
require 'constants'

# Test harness for textInput field
class FirstCalc < Gosu::Window
  include GosuEnhanced
  include Constants

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = 'First 555 Calculator'

    font = Gosu::Font.new(18, name: Gosu.default_font_name)

    @labels = LabelsRenderer.new do |labels|
      labels.add_block(INPUT_LABELS, INPUT_TOP_LEFT, font, 0xff000000, 40)
      labels.add_block(RESULT_LABELS, RESULT_TOP_LEFT, font, 0xff000080, 40)
    end

    # Set up an array of four text fields.
    @text_fields = Array.new(NUM_FIELDS) do |index|
      TextField.new(self, Point(WIDTH - 80, 30 + index * 40),
                    INPUT_DEFAULTS[index])
    end

    @diagram = Gosu::Image.new('../media/Astable.png')

    @calculator = Calculator555.new(INPUT_DEFAULTS[C1_INDEX])
  end

  def needs_cursor?
    true
  end

  def draw
    draw_rectangle(Point(0, 0), Size(WIDTH, HEIGHT), 0, Gosu::Color::WHITE)
    @diagram.draw(20, HEIGHT - (@diagram.height + 20), 0)

    @labels.process_blocks
    @text_fields.each(&:draw)
  end

  def button_down(id)
    case id
    when Gosu::KbTab    then calculate_and_move_on
    when Gosu::KbEscape then unselect_or_exit
    when Gosu::MsLeft   then select_field
    end
  end

  private

  def calculate_and_move_on
    index       = @text_fields.index(text_input) || -1
    next_field  = (index + tab_delta) % NUM_FIELDS
    self.text_input = @text_fields[next_field]

    if index == HZ_INDEX
      calculate_resistors_from_frequency
    else
      calculate_resistors_from_period
    end
#    puts "RA: #{@calculator.ra_value}, RB: #{@calculator.rb_value}"
  end

  def calculate_resistors_from_frequency
    @calculator.frequency = text_field_value(HZ_INDEX)
    load_duty_c1
    @text_fields[PERIOD_INDEX].text = @calculator.period_ms
  end

  def calculate_resistors_from_period
    @calculator.period = text_field_value(PERIOD_INDEX)
    load_duty_c1
    @text_fields[HZ_INDEX].text = @calculator.frequency
  end

  def load_duty_c1
    @calculator.cap_value  = text_field_value(C1_INDEX)
    @calculator.duty_ratio = text_field_value(DUTY_INDEX)
#    puts "LDC1: #{@calculator.cap_value}, #{@calculator.duty_ratio_percent}"
  end

  def text_field_value(index)
    @text_fields[index].text.to_f
  end

  def unselect_or_exit
    close unless text_input

    self.text_input = nil
  end

  def select_field
    # Mouse click: Select text field based on mouse position.
    self.text_input = @text_fields.find do |tf|
      tf.under_point?(mouse_x, mouse_y)
    end

    # Advanced: Move caret to clicked position
    text_input.move_caret(mouse_x) unless text_input.nil?
  end

  # Shift-Tab moves to the previous field
  def tab_delta
    button_down?(Gosu::KbLeftShift) || button_down?(Gosu::KbRightShift) ? -1 : 1
  end
end

FirstCalc.new.show
