class Rating < ActiveRecord::Base

  belongs_to :dog
  belongs_to :judge, { class_name: "Person" }

  validates :coolness, :cuteness, :judge_id, :dog_id, { :presence => true }
  validates :coolness, { :numericality => { :greater_than => 0, :less_than => 11 } }
  validates :cuteness, { :numericality => { :greater_than => 0, :less_than => 11 } }
  validates :judge_id, { :uniqueness => { :scope => :dog_id } }

end
