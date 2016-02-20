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
  def initialize(&cmds)
    @blocks = []

    instance_exec(&cmds) if block_given?
  end

  # :reek:LongParameterList: { max_params: 5 }
  def add_block(texts, top_left, font, colour, leading = 0)
    @blocks << LabelBlock.new(
      texts, top_left, font, colour, leading != 0 ? leading : font.height)
  end

  alias add add_block
  alias add_labels add_block

  def process_blocks
    @blocks.each(&:render)
  end
end
