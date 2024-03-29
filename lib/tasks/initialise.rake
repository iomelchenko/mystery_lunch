# frozen_string_literal: true

namespace :initialise do
  task meetings_seeds: :environment do
    date = ::Meeting::FORBIDDEN_PAIRS_PERIOD_IN_MONTHS.month.ago
    current_date = Date.current.end_of_day

    until date > current_date do
      start_time = Time.now

      year = date.year
      month = date.month

      puts "Started allocation for #{month}/#{year}"

      Matcher::PairsMatcher.new(year: year, month: month).allocate

      puts "-----> Created meetings for #{month}/#{year}"
      puts "       Duration - #{Time.now - start_time} sec."

      date += 1.month
    end
  end

  task current_month: :environment do
    start_time = Time.now
    current_date = Date.current
    year = current_date.year
    month = current_date.month

    puts "Started allocation for #{month}/#{year}"

    Matcher::PairsMatcher.new(year: year, month: month).allocate

    puts "-----> Created meetings for #{month}/#{year}"
    puts "       Duration - #{Time.now - start_time} sec."
  end
end
