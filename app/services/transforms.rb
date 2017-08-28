# frozen_string_literal: true

# Tranform helpers for string manipulation
module Transforms
  def self.split(result, option)
    result.flat_map { |s| s.split(option) }
  end

  def self.trim(result, _option)
    result.collect(&:strip)
  end

  def self.append(result, option)
    result.flat_map { |s| "#{s}#{option}" }
  end

  def self.replace(result, option)
    result.flat_map { |s| s.gsub(option[0], option[1]) }
  end

  def self.insert(result, option)
    result.flat_map { |s| option.gsub('%s', s) }
  end
end
