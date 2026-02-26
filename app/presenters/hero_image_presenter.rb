# frozen_string_literal: true

# Randomly selects a hero image and credit for the home page.
class HeroImagePresenter
  IMAGES = [
    ['broadcast.webp', 'Linda A. Cicero / Stanford News Service'],
    ['dig.webp', 'Linda A. Cicero / Stanford News Service'],
    ['experiment.webp', 'Andrew Brodhead'],
    ['fish.webp', 'Linda A. Cicero / Stanford News Service'],
    ['greenhouse.webp', 'Linda A. Cicero / Stanford News Service'],
    ['labcoats.webp', 'Andrew Brodhead'],
    ['marsh.webp', 'Andrew Brodhead'],
    ['microscope.webp', 'Andrew Brodhead'],
    ['microscopeslide.webp', 'Andrew Brodhead'],
    ['pipette.webp', 'Andrew Brodhead'],
    ['pond.webp', 'Andrew Brodhead'],
    ['robotics.webp', 'Andrew Brodhead'],
    ['scientist.webp', 'Andrew Brodhead'],
    ['shell.webp', 'Linda A. Cicero / Stanford News Service'],
    ['solar.webp', 'Linda A. Cicero / Stanford News Service'],
    ['wafer.webp', 'Andrew Brodhead'],
    ['waves.webp', 'Linda A. Cicero / Stanford News Service'],
    ['whiteboard.webp', 'Andrew Brodhead']
  ].freeze

  OTHER_IMAGES = [
    ['jk463cx1495_00_0001.webp', 'E.N. Murrey'],
    ['PC0170_s3_Tree_Calendar_1544_18_202_12_SixTrees2ICErs3_Tree_Calendar.webp', 'Robby Beyers'],
    ['SC0750_Milgram_03.webp', 'Philip G. Zimbardo'],
    ['PC0141_b02_Leland_Stanford_0143.webp', 'Leland Stanford'],
    ['PC0170_s3_Tree_Calendar_1118_02_141_18_TrumpzRallyTreeICE255rs3_Tree_Calendar.webp', 'Robby Beyers'],
    ['PC0170_s3_Cal_2010-11-20_154432_0787.webp', 'Robby Beyers'],
    ['PC0170_s2_19930918.Colorado_019.webp', 'Robby Beyers']
  ].freeze

  attr_reader :image, :credit

  def initialize
    @image, @credit = (Honeybadger.config[:env] == 'qa' ? OTHER_IMAGES : IMAGES).sample
  end
end
