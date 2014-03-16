class HomeController < ApplicationController

  def index
    @range = DateRange.new(params[:start_date], params[:end_date])
    @calendar = Calendar.order('refresh_date DESC').first
    if params[:start_date]
      errors = []
      if @range.start_at > @range.stop_at
        errors << 'Departure date should be later than arrival date'
      elsif Time.zone.now.to_date > @range.start_at.to_date
        errors << 'You should really plan for a trip in the future instead of the past'
      end

      if errors.blank?
        @units = Unit.find_openings(@range.start_at, @range.stop_at, params[:number_of_people])
      else
        request.flash[:errors] = errors[0]
      end
    end
  end

  def refresh
    Unit.all.each do |unit|
      unit.calendar.refresh_available_dates! if unit.calendar
    end
    redirect_to(home_index_path, notice: 'Calendars have been refreshed!')
  end

  class DateRange

    attr_accessor :start_at, :stop_at

    def initialize(star=nil, en=nil)
      @start_at = Date.parse(convert_date(star)) rescue Time.zone.now
      @stop_at = Date.parse(convert_date(en)) rescue 2.days.from_now
    end

    private

    def convert_date(the_date)
      the_date.gsub(%r{(\d{2})/(\d{2})/(\d+)}, '\3-\1-\2')
    end

  end
end
