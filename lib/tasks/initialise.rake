# frozen_string_literal: true

namespace :initialise do
  task meetings_seeds: :environment do
    date = ::Meeting::FORBIDDEN_PAIRS_PERIOD_IN_MONTHS.month.ago
    current_date = Date.current.end_of_day

    until date > current_date do
      year = date.year
      month = date.month

      PairsMatcher.new(year: year, month: month).allocate

      puts "Created the meetings for #{month}/#{year}"

      date += 1.month
    end
  end
end
