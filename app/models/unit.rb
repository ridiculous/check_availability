class Unit < ActiveRecord::Base
  attr_accessible :calendar_url, :name, :capacity

  has_one :calendar

  after_create :create_calendar
  after_update :create_calendar

  after_validation :set_default_capacity

  validates :name, :calendar_url, presence: true
  validates :name, uniqueness: {case_sensitive: false}
  validates :capacity, numericality: true

  class << self
    def refresh_all
      refresh(all.reject { |u| u.calendar.nil? }, true)
    end

    def find_openings(start_date, end_date, num_of_people)
      units = all.reject { |u| u.calendar.nil? }
      refresh(units)
      units.keep_if { |u| u.calendar.check_availability(start_date, end_date, num_of_people) }
    end

    def refresh(units, force=false)
      units.map { |u|
        Thread.new do
          if force || u.calendar.time_to_refresh?
            u.calendar.refresh_available_dates!
          end
        end
      }.each(&:join)
    end
  end

  def vrbo_url
    VRBO::Calendar.new(calendar_url).url
  end

  private

  def create_calendar
    calendar || create_calendar!
  end

  def set_default_capacity
    self.capacity ||= 2
  end

end
