class ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :user, :birth_day, :birth_month, :birth_year,
  :gender, :race, :education, :university, :other_university,
  :travel_origin, :graduation_season, :graduation_year, :major,
  :hackathons, :github, :linkedin, :website, :devpost, :other_link,
  :statement, :outside_north_america, :created_at, :status, :accepted_date

  belongs_to :user

  def user
    object.user_id
  end
end
