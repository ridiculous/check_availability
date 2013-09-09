class Calendar < ActiveRecord::Base
  attr_accessible :dates, :refresh_date, :unit_id

  belongs_to :unit

  serialize :dates, Array

  after_validation :set_refresh_date

  def check_availability(arrival, depart, num_of_people)
    refresh_available_dates! if dates.empty? || (refresh_date.nil? || 6.hours.ago > refresh_date)
    if available = Integer(num_of_people) <= unit.capacity
      arrival.upto(depart - 1.day).each do |date|
        available = false if dates.exclude?(date.to_s)
      end
    end
    available
  end

  # Calendar css classes:
  # - ACADV available
  # - ACWDV weekend day available

  def refresh_available_dates!
    puts "getting #{unit.name}"
    calendar = new_web_agent.get(unit.calendar_url)
    puts "got #{unit.name}"
    # map out available dates and save to DB as array
    today = Date.today
    tds = Hash.new
    update_attributes!(
        refresh_date: Time.now,
        dates: today.upto(today + 1.year).map { |date|
          m = date.month.to_s
          table_cells = calendar.search("#calMonthAvail#{date.year}#{m.length == 1 ? "0#{m}" : m}").search('td.ACADV, td.ACWDV')
          if table_cells
            tds[m] ||= table_cells.map { |cell| cell.children.to_s }
            date.to_s if tds[m].include?(date.day.to_s)
          end
        }.compact
    )
  end

  def new_web_agent
    Mechanize.new do |a|
      a.user_agent_alias = 'Mac Safari'
      a.redirection_limit = 10
      a.follow_meta_refresh = true
    end
  end

  class Availability < Struct.new(:first, :duration, :errors)
  end

  private

  def set_refresh_date
    self.refresh_date = Time.now
  end
end
