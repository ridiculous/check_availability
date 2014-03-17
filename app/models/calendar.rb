class Calendar < ActiveRecord::Base

  REFRESH_INTERVAL = 3

  attr_accessible :dates, :refresh_date, :unit_id

  belongs_to :unit

  serialize :dates, Array

  after_validation :set_refresh_date

  def check_availability(arrival, depart, num_of_people)
    available = Integer(num_of_people) <= unit.capacity
    available && vrbo_calendar.available?(arrival, depart, dates)
  end

  def time_to_refresh?
    dates.empty? || (refresh_date.nil? || REFRESH_INTERVAL.hours.ago > refresh_date)
  end

  def refresh_available_dates!
    puts "-> getting #{unit.name}"
    update_attributes!(refresh_date: Time.now, dates: vrbo_calendar.find_available_dates)
    puts "-> got #{unit.name}"
  end

  def vrbo_calendar
    VRBO::Calendar.new(unit.calendar_url) # actually the url is just the unit now id
  end

  private

  def set_refresh_date
    self.refresh_date = Time.now
  end
end
