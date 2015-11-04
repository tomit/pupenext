module Administration::DepartureHelper
  ROOT = 'administration.delivery_methods.departures'

  def day_of_the_week_options
    Date::DAYS_INTO_WEEK.inject([]) do |result, day|
      index = day.first == :sunday ? 0 : day.second + 1
      result << [t("#{ROOT}.day_of_the_week_options.#{day.first}"), index]
    end
  end
end