# frozen_string_literal: true

# Service for extracting the abstract from a PDF using an LLM.
class ExtractAbstractService
  def self.call(...)
    new(...).call
  end

  # @param filepath [String] path to the PDF
  def initialize(filepath:)
    @filepath = filepath
  end

  # @return [String, nil] extracted abstract text, or nil if it could not be extracted
  def call
    chat = RubyLLM.chat(model: 'gemini-flash-latest').with_temperature(0.0)
    chat.with_instructions <<~INSTRUCTIONS
      Extract only the abstract that appears in the provided PDF. If the abstract cannot be found, return an empty string."
    INSTRUCTIONS
    response = chat.ask 'What is the abstract for the article in the attached PDF?', with: filepath
    response.content.presence
  rescue RubyLLM::Error => e
    Rails.logger.error "Failed to extract abstract from PDF at #{filepath}: #{e.message}"
    Honeybadger.notify(e, context: { filepath: })
    nil
  end

  private

  attr_reader :filepath
end
