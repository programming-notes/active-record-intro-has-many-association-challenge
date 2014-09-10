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

We get a number of additional methods.  For example, we get a method for shoveling a `Rating` object into a dog's ratings:  `#ratings.<<`.  We also get getter and setter methods that work with the `id` value of the associated objects.  So, for any dog, we can get the `id` values of its ratings:  `#rating_ids`.  Or we can reassign the ratings that a dog has by providing the `id` values:  `#rating_ids=`.  And, as with `belongs_to`, we also get methods for building and creating ratings associated with a dog:  `#ratings.build`, `#ratings.create`, and `#ratings.create!`.  For a more comprehensive description of the methods provided, read the [apidock description](http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many).

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

- `tenley = Dog.find_by(name: "Tenley")`

  This gives us a `Dog` object to work with.  The object has been assigned to the variable `tenley`.

- `tenley.ratings`

  We're using the *getter* method supplied by `has_many`.  This returns an `ActiveRecord::Associations::CollectionProxy` object.  It's not an array, but it behaves very similar to an array.  All `tenley`'s ratings are inside this collection.

- `tenley.ratings.count`

  This returns the number of ratings that `tenley` has.  The method that were calling is `#ratings.count`.  It was one of the methods created when we said declared `has_many :ratings` in the class `Dog`.  In the console output, look at the SQL query that was run:  `SELECT COUNT(*) FROM "ratings"  WHERE "ratings"."dog_id" = ?  [["dog_id", 1]]`.
  
  This is not a method chain the way we're used to seeing it in Ruby (i.e., call `#ratings` on `tenley` and then call `#count` on the return value).  Active Record understands `#ratings.count` and makes the appropriate SQL query.

- `new_rating = Rating.new(coolness: 8, cuteness: 10, judge_id: 4)`

  We're making a new `Rating` object that we are going to put into `tenley`'s ratings.  Looking at the new object, we can see that its `id` and `dog_id` attributes are both `nil`.

- `tenley.ratings << new_rating`

  We've used the `#ratings.<<` method that `has_many` provided for us.  We use this much like we would use the `Array#<<` method.  We're taking `tenley`'s collection of ratings and shoveling in another `Rating` object.

- `new_rating`

  If we look at our `new_rating` object, it now has a value for `dog_id`.  When we shoveled `new_rating` into `tenley`'s collection of ratings, Active Record updated the `dog_id` attribute of `new_record` to match `tenley's` `id` attribute.

- `tenley.ratings.include? new_rating`

  Running this, we should see that `tenley`'s ratings now include our `new_rating` object.  Note that Active Record did not query the database when we ran this.  `tenley`'s records had already been loaded.

- `tenley.save`

  When we run `tenley.save`, we see in the console output that Active Record ran a SQL query:  `INSERT INTO "ratings" ...`.  We saved our `Dog` object, and in doing so, we also saved `new_rating`.

- `new_rating`

  If we look at `new_rating`, we see that it now has an `id`.

- `tenley.rater_ids`

  This returns an array of `tenley`'s rating `id`s.

-  `tenley.ratings.build(coolness: 7, cuteness: 9, judge_id: 5)`

  We're creating a new `Rating` and associating it with `tenley`.  The new `Rating` object has its `dog_id` attribute set to `tenley`'s `id`.  The new `Rating` object's `id` is `nil` because it's not been saved to the database; this object only exits in Ruby.

- `tenley.ratings`
 
 If we look in the returned collection of `Rating` objects, we'll see our `Rating` with the `id` `nil`.

- `tenley.save`

  As when we shoveled an unsaved `Rating` into `tenley`'s ratings collection, when we call save here on `tenley`, `tenley`'s ratings are also saved.

- `tenley.ratings.where(cuteness: 10)`

  Here we're looking for all of `tenley`'s ratings where her cuteness was judged to be a 10.  Active Record interprets this method chain and runs one query:  `SELECT "ratings".* FROM "ratings"  WHERE "ratings"."dog_id" = ? AND "ratings"."cuteness" = 10  [["dog_id", 1]]`.

- `rating_ids = tenley.rating_ids`

  Once again, we're retrieving the `id`'s of `tenley`'s ratings.  This time, we're assigning the returned array to the variable `rating_ids`.
  
- `tenley.ratings = []`

  We can assign a collection of ratings to be `tenley`'s ratings.  Here we've used an empty array.  We're saying that `tenley` has no ratings.  To accomplish this, Active Record updates the `dog_id` value of all `tenley`'s previous ratings to be `nil`.

- `tenley.ratings.empty?`

  We can see that, in deed, `tenley` has no more ratings.

- `Rating.find rating_ids`

  We previously saved the `id`s of `tenley`'s old ratings in the variable `rating_ids`.  Now we're using these `id`s to find those ratings in the database.  In the collection returned to us, we can see that all of the included `Rating` objects have a `dog_id` of `nil`.  The link between these ratings and `tenley` has been broken.

- `tenley.rating_ids= rating_ids`

  We're giving `tenley` back her ratings.  We can assign a new collection of ratings by calling `#rating_ids=` and passing an array of ids in the `ratings` table.  We can see that Active Record makes a series of `UPDATE` SQL queries—one for each of the ids—to reestablish the connection between the rating and `tenley`.

- `tenley.ratings`

  We can see that `tenley` has her ratings back.

- `exit`

### Release 2:  Write `has_many` Associations

At the end of the *Summary* section, two other has many associations were described.  A person has many dogs.  A person has many ratings.

Define these associations in the appropriate classes.  These associations break convention, so we'll have to configue the `has_many` association.  Tests have been provided to guide development.  When all of the tests are complete, submit the challenge.