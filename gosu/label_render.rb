# Label block renderer
class LabelsRenderer
  def initialize
    @blocks = []
  end

  def add_block(texts, top_left, font, colour, leading = 0)
    @blocks << {
      texts:      texts,
      top_left:   top_left,
      font:       font,
      colour:     colour,
      leading:    leading != 0 ? leading : font.height
    }
  end

  def process_blocks
    @blocks.each { |block| render block }
  end

  private

  def render(block)
    text_pos = block[:top_left].dup
    block[:texts].each do |text|
      block[:font].draw(text, text_pos.x, text_pos.y, 0, 1, 1, block[:colour])
      text_pos.move_by!(0, block[:leading])
    end
  end
end
