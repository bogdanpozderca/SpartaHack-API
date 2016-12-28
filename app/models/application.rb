# == Schema Information
#
# Table name: applications
#
#  id                    :integer          not null, primary key
#  user_id               :integer          not null
#  birth_day             :integer          not null
#  birth_month           :integer          not null
#  birth_year            :integer          not null
#  education             :string           not null
#  university            :string
#  other_university      :string
#  travel_origin         :string
#  graduation_season     :string           not null
#  graduation_year       :integer          not null
#  major                 :text             is an Array
#  hackathons            :integer          not null
#  github                :string
#  linkedin              :string
#  website               :string
#  devpost               :string
#  other_link            :string
#  statement             :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  race                  :text             is an Array
#  gender                :string
#  outside_north_america :string
#  status                :string
#  accepted_date         :datetime
#
# Indexes
#
#  index_applications_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_703c720730  (user_id => users.id)
#

class Application < ApplicationRecord
  belongs_to :user

  validates :user_id,           presence: true, uniqueness: {
    message: "already has an application"
  }

  validates :birth_day,         presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than: 32
  }

  validates :birth_month,       presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than: 13
  }

  validates :birth_year,        presence: true, numericality: {
    only_integer: true,
    greater_than: 1920,
    less_than: 2005
  }

  validates :education,         presence: true
  validates :outside_north_america,         presence: true
  validates :graduation_season, presence: true
  validates :graduation_year,   presence: true, numericality: {
    only_integer: true,
    greater_than: 2015
  }

  validates :hackathons,        presence: true, numericality: {
    only_integer: true,
    greater_than: -1
  }
end
