class Metric < ActiveRecord::Base
  serialize :data_set
  validates :key, :presence => true, :uniqueness => true

  def self.add_data_point(key, date, value)
    find_or_create_by(:key => key).add_data_point(date, value)
  end

  def add_data_point(date, value)
    self.data_set ||= []

    raise "value '#{value}' is not a number" unless value.is_a? Numeric

    data_set << { :date => date.to_time, :value => value }

    save!
  end
end

