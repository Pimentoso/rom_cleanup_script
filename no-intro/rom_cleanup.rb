# frozen_string_literal: true

# Usage: ruby rom_cleanup.rb [directory] [.extension]
# Example: ruby rom_cleanup.rb /path/to/roms .zip
#
# Useful links:
# - https://wiki.no-intro.org/index.php?title=Naming_Convention

require "logger"

logger = Logger.new($stdout)

DRY_RUN = false

directory = ARGV[0] || "."
extension = if ARGV[1]&.start_with?(".")
  ARGV[1]
else
  ".zip"
end

DUMP_INFO_FLAGS = ["b"]

COUNTRIES = [
  "Australia",
  "Brazil",
  "Canada",
  "China",
  "France",
  "Germany",
  "Hong Kong",
  "Italy",
  "Japan",
  "Korea",
  "Netherlands",
  "Spain",
  "Sweden",
  "Asia"
]

DEV_STATUS = [
  "Beta",
  "Proto",
  "Sample",
  "Demo",
  "Pirate",
  "Unl"
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
    if file.include?("(#{flag})")
      logger.debug { "contains (#{flag}) - deleting: #{file}" }
      deleted = File.delete(file) unless DRY_RUN
      break
    end
  end
  next if deleted
end

logger.info { "Done." }
# logger.info { "################ REMOVING ROMS WITH MULTIPLE REVISIONS (user input required) ################" }

# base_names = Dir.glob(File.join(directory, "*#{extension}")).select{ |f| f.include?("Rev ") }.map { |f| File.basename(f, extension).split("Rev ").first.strip }.uniq

# base_names.each do |file|
#   matches = [Dir.glob(File.join(directory, "#{file} Rev *")), Dir.glob(File.join(directory, "#{file} ("))].flatten.sort
#   if matches.size == 1
#     file_to_keep = matches[0]
#     new_filename = File.join(directory, "#{file} #{file_to_keep[file_to_keep.index('(')..]}")
#     logger.debug { "renaming #{file_to_keep} to #{new_filename}" }
#     File.rename(file_to_keep, new_filename) unless DRY_RUN

#     next
#   end

#   logger.info { "Multiple versions found for: #{file}" }
#   matches.each_with_index do |match, index|
#     logger.info { "#{index + 1}. #{File.basename(match)}" }
#   end

#   logger.info { "Enter number to keep (1-#{matches.size}): " }
#   selection = STDIN.gets.chomp.to_i

#   if selection.between?(1, matches.size)
#     file_to_keep = matches[selection - 1]
#     matches.each do |match|
#       if match != file_to_keep
#         logger.debug { "deleting: #{match}" }
#         File.delete(match) unless DRY_RUN
#       end
#     end
#     new_filename = File.join(directory, "#{file} #{file_to_keep[file_to_keep.index('(')..]}")
#     logger.debug { "renaming #{file_to_keep} to #{new_filename}" }
#     File.rename(file_to_keep, new_filename) unless DRY_RUN
#   else
#     logger.info { "Invalid selection, skipping..." }
#   end

#   logger.info { "################" }
# end

# logger.info { "Done." }
logger.info { "################ REMOVING ROMS WITH MULTIPLE REGIONS (user input required) ################" }

base_names = Dir.glob(File.join(directory, "*#{extension}")).sort.map { |f| File.basename(f, extension).split("(").first.strip }.uniq

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
