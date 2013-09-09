class Unit < ActiveRecord::Base
  attr_accessible :calendar_url, :name, :capacity

  has_one :calendar

  after_create :create_calendar
  after_update :create_calendar

  after_validation :set_default_capacity

  validates :name, :calendar_url, presence: true
  validates :name, uniqueness: {case_sensitive: false}

  class << self

    def find_openings(start_date, end_date, num_of_people)
      all.keep_if { |unit| unit.calendar && unit.calendar.check_availability(start_date, end_date, num_of_people) }
    end
  end

  private

  def create_calendar
    calendar || create_calendar!
  end

  def set_default_capacity
    self.capacity ||= 2
  end
end
