class ResistorFormatter
  def self.str(value)
    if value < 5_000.0
      value.round.to_s + ' Ω'
    elsif value < 1_000_000.0
      (value / 1_000.0).round(2).to_s + ' kΩ'
    else
      (value / 1_000_000.0).round(2).to_s + ' MΩ'
    end
  end
end
