#!/usr/bin/env ruby
# frozen_string_literal: true

# Verify that the built Essenfont-Regular.ttf is well-formed.
#
# Usage:
#   ruby scripts/verify.rb [Essenfont-Regular.ttf]

require "fontisan"

module EssenfontVerify
  def self.run(path = "Essenfont-Regular.ttf")
    unless File.exist?(path)
      warn "FAIL  #{path} not found (run `ruby scripts/build.rb` first)"
      exit 1
    end

    puts "=== Verifying #{path} ==="
    font = Fontisan::FontLoader.load(path)
    failures = []

    check(failures, "head magic number") do
      font.table("head").magic_number == 0x5F0F3CF5
    end

    check(failures, "head checksum adjusted (non-zero)") do
      font.table("head").checksum_adjustment.nonzero?
    end

    check(failures, "maxp num_glyphs > 0") do
      font.table("maxp").num_glyphs.positive?
    end

    check(failures, "cmap table present") do
      font.has_table?("cmap")
    end

    check(failures, "cmap has unicode mappings") do
      cmap = font.table("cmap")
      cmap && cmap.unicode_mappings && !cmap.unicode_mappings.empty?
    end

    check(failures, "name table present") do
      font.has_table?("name")
    end

    check(failures, "head units_per_em = 1000") do
      font.table("head").units_per_em == 1000
    end

    if failures.empty?
      puts "PASS  #{path} (#{font.table("maxp").num_glyphs} glyphs)"
    else
      failures.each { |f| puts "FAIL  #{f}" }
      exit 1
    end
  end

  def self.check(failures, description)
    result = yield
    puts "#{result ? 'PASS' : 'FAIL'}  #{description}"
    failures << description unless result
  rescue StandardError => e
    puts "FAIL  #{description} (#{e.message})"
    failures << description
  end
end

path = ARGV[0] || "Essenfont-Regular.ttf"
EssenfontVerify.run(path)
