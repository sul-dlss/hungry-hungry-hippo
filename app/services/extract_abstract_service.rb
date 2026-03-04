# frozen_string_literal: true

# Service for extracting the abstract from a PDF using an LLM.
class ExtractAbstractService
  def self.call(...)
    new(...).call
  end

  # @param filepath [String] path to the PDF
  # @param raise_on_error [Boolean] whether to raise an error if extraction fails
  def initialize(filepath:, raise_on_error: false)
    @filepath = filepath
    @raise_on_error = raise_on_error
  end

  # @return [String, nil] extracted abstract text, or nil if it could not be extracted
  def call
    Tempfile.create(['subset-', '.pdf']) do |tempfile|
      subset_pdf(filepath:, new_file: tempfile.path)
      response = chat.ask 'What is the abstract for the article in the attached PDF?', with: tempfile.path
      response.content['abstract_sections'].join("\n\n").presence
    rescue RubyLLM::Error => e
      Honeybadger.notify(e, context: { filepath: })
      raise e if raise_on_error

      nil
    end
  end

  private

  attr_reader :filepath, :raise_on_error

  # Schema for the LLM response
  class AbstractSchema < RubyLLM::Schema
    array :abstract_sections, description: 'sections of the abstract of the article', of: :string
  end

  def chat
    @chat ||= RubyLLM.chat(model: 'gemini-3-flash-preview').with_temperature(0.0).tap do |chat|
      chat.with_instructions <<~INSTRUCTIONS
        Extract only the abstract that appears in the provided PDF. If the abstract has multiple sections, return each section separately. If the abstract cannot be found, return an empty string."
      INSTRUCTIONS
      chat.with_schema(AbstractSchema)
    end
  end

  def subset_pdf(filepath:, new_file:)
    doc = HexaPDF::Document.open(filepath)
    page_indexes = (0..(doc.pages.count - 1)).to_a
    page_indexes.shift(3)
    page_indexes.reverse_each do |index|
      doc.pages.delete_at(index)
    end
    doc.write(new_file)
  end
end
