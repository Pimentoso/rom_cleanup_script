# frozen_string_literal: true

# Usage: ruby rom_cleanup.rb [directory] [.extension]
# Example: ruby rom_cleanup.rb /path/to/roms .zip
#
# Useful links:
# - https://www.tosecdev.org/tosec-naming-convention

require "logger"

logger = Logger.new($stdout)

DRY_RUN = false

directory = ARGV[0] || "."
extension = if ARGV[1]&.start_with?(".")
  ARGV[1]
else
  ".zip"
end

DUMP_INFO_FLAGS = [
  "cr",
  "f",
  "h",
  "m",
  # "p",
  "t",
  "tr ",
  "o",
  "u",
  "v",
  "b",
  "a " # weird alternate versions
]

COUNTRIES = %w[DE FR ES IT SE BR RU AU CA JP TW KR CN AS JP-KR]

DEV_STATUS = [
  "alpha",
  "beta",
  "pre-release",
  "proto",
  "demo"
]

if DRY_RUN
  logger.info { "##############################################" }
  logger.info { "##### DRY RUN - no files will be deleted #####" }
  logger.info { "##############################################" }
  logger.info { "" }
end

logger.info { "################ REMOVING ROMS BY UNWANTED FLAGS ################" }

files = Dir.glob(File.join(directory, "*#{extension}"))
files.each do |file|
  deleted = nil

  DUMP_INFO_FLAGS.each do |flag|
    if file.include?("[#{flag}")
      logger.debug { "contains [#{flag}] - deleting: #{file}" }
      deleted = File.delete(file) unless DRY_RUN
      break
    end
  end
  next if deleted

  COUNTRIES.each do |code|
    if file.include?("(#{code})")
      logger.debug { "contains (#{code}) - deleting: #{file}" }
      deleted = File.delete(file) unless DRY_RUN
      break
    end
  end
  next if deleted

  DEV_STATUS.each do |flag|
    if file.include?("(#{flag}")
      logger.debug { "contains (#{flag}) - deleting: #{file}" }
      deleted = File.delete(file) unless DRY_RUN
      break
    end
  end
  next if deleted
end

logger.info { "Done." }
logger.info { "################ REMOVING ROMS WITH MULTIPLE ALTERNATE VERSIONS ################" }

base_names = Dir.glob(File.join(directory, "*#{extension}")).reject { |f| f =~ /\[a/ }

base_names.each do |file|
  basename = File.basename(file, extension)

  matches = Dir.glob(File.join(directory, "#{basename}*")).select { |f| f =~ /\[a/ }.sort
  next unless matches.any?

  match_to_keep = nil
  max_a = 0
  matches.each do |match|
    a = if match.include?("[a]")
      1
    elsif rev = match.match(/\[a(\d*)\]/)
      rev[1].to_i
    else
      0
    end

    if a > max_a
      max_a = a
      match_to_keep = match
    end
  end

  if match_to_keep
    logger.debug { "Found latest alternate version: #{match_to_keep}" }

    matches.each do |match|
      if match != match_to_keep
        logger.debug { "Deleting old version: #{match}" }
        File.delete(match) unless DRY_RUN
      end
    end
    logger.debug { "Deleting old version: #{file}" }
    File.delete(file) unless DRY_RUN
  end
end

logger.info { "Done." }
logger.info { "################ REMOVING ROMS WITH MULTIPLE REGION (user input required) ################" }

base_names = Dir.glob(File.join(directory, "*#{extension}")).map { |f| File.basename(f, extension).split("(").first.strip }.uniq

base_names.each do |file|
  basename = "#{file} ("
  matches = Dir.glob(File.join(directory, "#{basename}*")).sort
  next unless matches.size > 1

  logger.info { "Multiple versions found for: #{file}" }
  matches.each_with_index do |match, index|
    logger.info { "#{index + 1}. #{File.basename(match)}" }
  end

  logger.info { "Enter number to keep (1-#{matches.size}): " }
  selection = STDIN.gets.chomp.to_i

  if selection.between?(1, matches.size)
    file_to_keep = matches[selection - 1]
    matches.each do |match|
      if match != file_to_keep
        logger.debug { "deleting: #{match}" }
        File.delete(match) unless DRY_RUN
      end
    end
  else
    logger.info { "Invalid selection, skipping..." }
  end

  logger.info { "################" }
end

logger.info { "Done." }
