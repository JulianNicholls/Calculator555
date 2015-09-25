# Label Block
LabelBlock = Struct.new(:texts, :top_left, :font, :colour, :leading) do
  def render
    text_pos = top_left.dup

    texts.each do |text|
      font.draw(text, text_pos.x, text_pos.y, 0, 1, 1, colour)
      text_pos.move_by!(0, leading)
    end
  end
end

# Label block renderer
class LabelsRenderer
  def initialize
    @blocks = []

    yield self if block_given?
  end

  def add_block(texts, top_left, font, colour, leading = 0)
    @blocks << LabelBlock.new(
      texts, top_left, font, colour, leading != 0 ? leading : font.height)
  end

  def process_blocks
    @blocks.each(&:render)
  end
end
