# frozen_string_literal: true

# Support methods for line breaks
class LinebreakSupport
  # Normalize line breaks to CR+LF
  def self.normalize(text)
    return text if text.nil?

    text.strip.encode(Encoding::UTF_8, universal_newline: true).encode(Encoding::UTF_8, crlf_newline: true)
  end
end
