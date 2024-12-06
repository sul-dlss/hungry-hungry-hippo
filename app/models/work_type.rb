# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
  class InvalidType < StandardError; end

  MINIMUM_REQUIRED_MUSIC_SUBTYPES = 1
  MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES = 2
  MIXED_MATERIALS = 'Mixed Materials'
  MUSIC = 'Music'
  OTHER = 'Other'

  DATA_TYPES = [
    '3D model', 'Database', 'Documentation', 'Geospatial data', 'Image',
    'Tabular data', 'Text corpus'
  ].freeze

  VIDEO_TYPES = [
    'Conference session', 'Documentary', 'Event', 'Oral history', 'Performance'
  ].freeze

  SOUND_TYPES = ['Interview', 'Oral history', 'Podcast', 'Speech'].freeze

  TEXT_TYPES = [
    'Article', 'Capstone', 'Government document', 'Policy brief', 'Preprint', 'Report',
    'Technical report', 'Thesis', 'Working paper'
  ].freeze

  SOFTWARE_TYPES = %w[Code Documentation Game].freeze

  IMAGE_TYPES = ['CAD', 'Map', 'Photograph', 'Poster', 'Presentation slides'].freeze

  MUSIC_TYPES = [
    'Data',
    'Image',
    'MIDI',
    'Musical transcription',
    'Notated music',
    'Piano roll',
    'Software/Code',
    'Sound',
    'Text',
    'Video'
  ].freeze

  # These types appear below the fold and may be expanded
  MORE_TYPES = [
    '3D model', 'Animation', 'Article', 'Book', 'Book chapter', 'Broadcast', 'CAD', 'Capstone',
    'Code', 'Conference abstract', 'Conference session', 'Correspondence', 'Course/instructional materials',
    'Data', 'Database', 'Documentary', 'Documentation', 'Dramatic performance',
    'Essay', 'Ethnography', 'Event', 'Experimental audio/video', 'Field recording',
    'Game', 'Geospatial data', 'Government document', 'Image', 'Interview',
    'Journal/periodical issue', 'Manuscript', 'Map', 'MIDI', 'Musical transcription',
    'Narrative film', 'Notated music', 'Oral history', 'Other spoken word', 'Pamphlet',
    'Performance', 'Photograph', 'Piano roll', 'Podcast', 'Poetry reading',
    'Policy brief', 'Poster', 'Portfolio', 'Preprint', 'Presentation recording',
    'Presentation slides', 'Questionnaire', 'Remote sensing imagery', 'Report',
    'Software', 'Sound recording', 'Speaker notes', 'Speech', 'Story', 'Syllabus',
    'Tabular data', 'Technical report', 'Text', 'Text corpus', 'Thesis',
    'Transcript', 'Unedited recording', 'Video art', 'Video recording',
    'White paper', 'Working paper'
  ].freeze

  MIXED_TYPES = (['Music'] + MORE_TYPES).sort.freeze

  attr_reader :label, :cocina_type, :subtypes

  def initialize(**params)
    @label = params.fetch(:label)
    @subtypes = params.fetch(:subtypes)
    @cocina_type = params.fetch(:cocina_type)
  end

  def to_s
    @label
  end

  def self.find(label)
    all.find { |work| work.label == label } || raise(InvalidType, "Unknown worktype #{label}")
  end

  # id is a value acceptable for MODS typeOfResource

  def self.all # rubocop:disable Metrics/AbcSize
    [
      new(label: 'Text', subtypes: TEXT_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Data', subtypes: DATA_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Software/Code', subtypes: SOFTWARE_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Image', subtypes: IMAGE_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Sound', subtypes: SOUND_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Video', subtypes: VIDEO_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Music', subtypes: MUSIC_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Mixed Materials', subtypes: MIXED_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(label: 'Other', subtypes: [], cocina_type: Cocina::Models::ObjectType.object)
    ]
  end

  def self.more_types
    MORE_TYPES
  end

  def self.subtypes_for(label)
    find(label).subtypes
  end
end
