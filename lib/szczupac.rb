# frozen_string_literal: true

require_relative "szczupac/version"

module Szczupac
  extend self

  def axis(name, values)
    values.map { |v| { name => v } }
  end

  def generate(*axes)
    order = axes.flat_map { |a| a.map(&:keys) }.uniq

    axes.flat_map do |axis|
      rest = axes - [axis]
      first_options = rest.map(&:first)

      axis
        .product([first_options.reduce(&:merge)])
        .map { |product| product.reduce(&:merge) }
        .map { |product| product.sort_by { |k, _| order.index(k) }.to_h }
    end.uniq
  end

  def permutation(*axes)
    order = axes.flat_map { |a| a.map(&:keys) }.uniq

    axes.flat_map do |axis|
      rest = axes - [axis]
      axis
        .product(*rest)
        .map { |product| product.reduce(&:merge) }
        .map { |product| product.sort_by { |k, _| order.index(k) }.to_h }
    end.uniq
  end

  def call(**named_lanes)
    named_lanes
      .flat_map do |name, values|
        first_from_rest =
          named_lanes
            .reject { |n, _| n == name }
            .map { |n, v| { n => v.first } }
            .reduce(&:merge)
        values
          .map { |v| { name => v } }
          .product([first_from_rest])
          .map { |v| v.reduce(&:merge) }
          .map { |v| v.sort_by { |k, _| named_lanes.keys.index(k) }.to_h }
      end
      .uniq
  end
  alias [] call
end
