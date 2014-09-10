# Active Record Intro:  `has_many` Association

## Summary

![Database Schema](schema_design_new.png)

*Figure 1*.  Database schema.

In the *Active Record Intro: `belongs_to` Association* challenge, we took the schema shown in Figure 1 and wrote the associations between our classes where one belongs to another:

- A dog belongs to an owner.
- A rating belongs to a judge.
- A rating belongs to a dog.

In this challenge we'll take a look at `has_many`.  A has many association between two classes is the inverse of the belongs to association.  An owner person has many dogs, a judge has many ratings, and a dog has many ratings.  Only, our owners and judges are really `People` objects, so a person has many dogs and has many ratings.

```ruby
class Dog < ActiveRecord::Base
  include USGeography
  
  has_many :ratings
  belongs_to :owner, { class_name: "Person" }

  validates :name, :license, :owner_id, { :presence => true }
  validates :license, { :uniqueness => true }
  validates :license, format: { with: /\A[A-Z]{2}\-/ }
  validates :age, { :numericality => { greater_than_or_equal_to: 0 },
                    :allow_blank  => true }

  validate :license_from_valid_state

  def license_from_valid_state
	# add errors under certain conditions
  end
end
```

*Figure 2.*  Code for `Dog` class.

Figure 2 shows an updated `Dog` class that defines the association between `Dog` and `Rating` from the perspective of `Dog`.  Note the line `has_many :ratings`.  

Just like `belongs_to`, `has_many` is a method that will be called on the class we're defining—in this case `Dog`.  `has_many` is going to provide us with instance methods to call on `Dog` objects.  The set of methods provided by `has_many` is different than the methods provided by `belongs_to`.

We will still get *getter* and *setter* methods.  And again, the method names are derived from the argument passed to the `has_many` method.  In this case, we passed `:ratings`.  Therefore, the getter method is `#ratings` and the setter method is `ratings=`.

We get a number of additional methods.  For example, we get a method for shoveling a `Rating` object into a dog's ratings:  `#ratings.<<`.  We also get getter and setter methods that work with the `id` value of the associated objects.  So, for any dog, we can get the `id` values of its ratings:  `#rating_ids`.  Or we can reassign the ratings that a dog has by providing the `id` values:  `#rating_ids=`.  And, as with `belongs_to`, we also get methods for building and creating ratings assiciated with a dog:  `#ratings.build`, `#ratings.create`, and `#ratings.create!`.  For a more comprehensive description of the methods provided, read the [apidock description](http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many).

### Active Record Conventions

We're expected to follow the same conventions with `has_many` as with `belongs_to`.

When we define a has many association, Active Record expects to find a class with a name matching the argument passed in.  In this case, we passed `:ratings`, so Active Record expects to find a `Rating` class.  We have one, so we're all right.  Also, Active Record needs to know how to identify the `Rating` that a `Dog` object has.  In other words, it needs to know the foreign key on the `ratings` table that matches the `id` of the `Dog` object.  Convention indicates that the foreign key should be named `dog_id`.  Again, we're following convention, so this association just works.

If one of these conventions were broken, we would have to configure the association.  In other words, we'd have to tell Active Record where to look.  We can do that with an optional hash argument that we can pass to the `has_many` method.  Active Record is going to assume that a specific class and a specific foreign key exits.  If they're not there we can pass that information along:

`has_many :ratings, { :class_name => "Rating", :foreign_key => :dog_id }`

Earlier in this *Summary* section, we identified a couple more has many associations.  A person has many dogs.  If in the `Person` class we defined the association `has_many :dogs`, it would not work because we've broken convention.  Active Record will expect that a class `Dog` exists, which we do have.  It will also expect that the `dogs` table has a `person_id` foreign key field, but looking at the schema design in Figure 1, there is no `person_id` field on the `dogs` table.  We've broken convention.  Instead, there is an `owner_id` field, so we would need to specify the foreign key field that Active Record should use.

We would find ourselves in a similar situation if we wanted to define a has many association between `Person` and `Rating`.  If we wanted to say in the `Person` class `has_many :ratings`, we would violate convention.

## Releases

### Pre-release: Create, Migrate, and Seed the Database

1. Run Bundler to ensure that the proper gems have been installed.

2. Use the provided Rake task to create the database.

3. Use the provided Rake task to migrate the database.

4. Use the provided Rake task to seed the database.  This will seed all three tables with data.

### Release 0: Exploring `has_many` Association Methods

Use the provided Rake task to open the console:  `bundle exec rake console`.

From within the console run ...

- `a`

  Something.

- `exit`

### Release 2:  Write `has_many` Associations

At the end of the *Summary* section, two other has many associations were described.  A person has many dogs.  A person has many ratings.

Define these associations in the appropriate classes.  Test have been provided to guide development.  When all of the tests are complete, submit the challenge.