# Constants for first_calc / final version
module Constants
  WIDTH   = 520
  HEIGHT  = 750

  INPUT_TOP_LEFT  = GosuEnhanced::Point(200, 30)
  RESULT_TOP_LEFT = GosuEnhanced::Point(200, 190)

  NUM_FIELDS      = 4

  INPUT_LABELS    = [
    'Frequency in Hz', 'Period in ms', 'Duty Ratio % (50-99)', 'C1 in µF'
  ]

  INPUT_DEFAULTS  = ['2', '500', '51', '22']

  HZ_INDEX        = 0
  PERIOD_INDEX    = 1
  DUTY_INDEX      = 2
  C1_INDEX        = 3

  RESULT_LABELS   = ['RA', 'RB']

  # Some constants that define the appearance of the text fields.

  SELECTION_COLOR = 0xcc88ffff    # Bright Cyan
  BOTTOM_PAD      = 3
  REST_PAD        = 4
end
