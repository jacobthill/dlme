# frozen_string_literal: true

module Macros
  # Macros for extracting values from JSON documents
  module JSON
    # @param path [String] the jsonpath query expression
    # @param options [Hash] other options, may include :trim
    def extract_json(path, options = {})
      lambda do |json, accumulator, _context|
        result = Array(JsonPath.on(json, path))
        result = result.map(&:strip) if options.key?(:trim)
        accumulator.concat(result)
      end
    end
  end
end
