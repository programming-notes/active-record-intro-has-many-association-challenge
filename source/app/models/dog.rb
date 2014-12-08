class Dog < ActiveRecord::Base

  has_many :ratings
  belongs_to :owner, { class_name: "Person" }

end
