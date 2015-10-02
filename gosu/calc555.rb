#!/usr/bin/env ruby -I.

require 'text_input'

require '../calculator'
require '../rformat'
require 'label_render'
require 'constants'

# Calculator UI
class GosuCalculator < Gosu::Window
  include GosuEnhanced
  include Constants

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = '555 Timer Calculator'

    setup_labels
    setup_fields

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
    draw_resistor_values
  end

  def button_down(id)
    case id
    when Gosu::KbTab    then calculate_and_move_on
    when Gosu::KbEscape then unselect_or_exit
    when Gosu::MsLeft   then select_field
    end
  end

  private

  def setup_labels
    @font = Gosu::Font.new(18, name: Gosu.default_font_name)
    font  = @font

    @labels = LabelsRenderer.new do
      add INPUT_LABELS, INPUT_TOP_LEFT, font, Gosu::Color::BLACK, 40
      add RESULT_LABELS, RESULT_TOP_LEFT, font, Gosu::Color::BLACK, 40
    end
  end

  def setup_fields
    @text_fields = Array.new(NUM_FIELDS) do |index|
      TextField.new(self, Point(WIDTH - 80, 30 + index * 40),
                    INPUT_DEFAULTS[index])
    end
  end

  def calculate_and_move_on
    index       = @text_fields.index(text_input) || -1
    next_field  = (index + tab_delta) % NUM_FIELDS
    self.text_input = @text_fields[next_field]

    if index == HZ_INDEX
      calculate_resistors_from_frequency
    else
      calculate_resistors_from_period
    end
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

  # :reek:UncommunicativeMethodName
  def load_duty_c1
    @calculator.cap_value  = text_field_value(C1_INDEX)
    @calculator.duty_ratio = text_field_value(DUTY_INDEX)
  end

  def draw_resistor_values
    return unless @calculator.r1_value

    @font.draw(ResistorFormatter.str(@calculator.r1_value), WIDTH - 80, RESULT_TOP_LEFT.y, 1, 1, 1, Gosu::Color::BLUE)
    @font.draw(ResistorFormatter.str(@calculator.r2_value), WIDTH - 80, RESULT_TOP_LEFT.y + 40, 1, 1, 1, Gosu::Color::BLUE)
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
    text_input.move_caret(mouse_x) if text_input
  end

  # Shift-Tab moves to the previous field
  def tab_delta
    button_down?(Gosu::KbLeftShift) || button_down?(Gosu::KbRightShift) ? -1 : 1
  end
end

GosuCalculator.new.show
