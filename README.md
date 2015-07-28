# Active Record Intro:  Has Many

## Summary

![Database Schema](schema_design_new.png)

*Figure 1*.  Schema design for this challenge, showing connections between primary keys and foreign keys.

This challenge assumes that we've completed and are comfortable with the material from the Active Record Intro challenge on the belongs to association.  Working with the schema shown in Figure 1, in that challenge we wrote a few belongs to associations for our models:

- a dog belongs to an owner/person
- a rating belongs to the judge/person who did the rating
- a rating belongs to the dog that was rated

In this challenge we'll take a look at the *has many* association.  A has many association is the inverse of the belongs to association; it's the other side of a one-to-many relationship.  Taking the belongs to associations that we wrote for our models, we can write inverse has many associations:

- an owner/person has many dogs
- a judge/person has many ratings
- a dog has many ratings

### Identifying a Has Many Association

As with the belongs to association, matching foreign keys to primary keys makes the has many association possible.  We're associating two models with each other; the table of one model needs a foreign key that points the the primary key on the table of the other model.

When we declare a belongs to association, on which model's table would we find the foreign key?  On which the primary key?  The table of the model that belongs to the other model would contain the foreign key.  So, based on our schema, we can say that a rating belongs to a dog.

The has many association is the inverse.  Any time a model's table hold a foreign key that points to another model, we can say this other model has many of the model.  In our schema, we can say that a dog has many ratings because the table for the `Rating` class has a foreign key that points to a dog.


### Declaring a Has Many Association
```ruby
class Dog < ActiveRecord::Base
  belongs_to :owner, { class_name: "Person" }
  has_many :ratings
end
```

*Figure 2.*  Code for the class `Dog` with both a belongs to and has many association defined.

Figure 2 shows a `Dog` class that declares two associations.  We should be familiar with declaring a belongs to association.  We're going to look at how to declare a has many association—it's very similar.

Before we look at the syntax for declaring a has many association, what are the different parts in declaring the belongs to association?  What are `belongs_to`, `:owner`, and `{ class_name: "Person" }`?

Like `.belongs_to`, `.has_many` is a method that will be called on the class we're defining—in this case `Dog`.  It serves the same purpose, too:  `.has_many` is going to provide us with instance methods that allow a dog to interact with ratings.  However, the set of methods provided by `.has_many` is different from the methods provided by `.belongs_to`.

As with declaring a belongs to association, we will get *getter* and *setter* methods.  And again, the method names are derived from the first argument passed to `.has_many`.  In this case, we passed `:ratings`.  Therefore, the getter method is `#ratings` and the setter method is `#ratings=`.  When we declare a has many association, the first argument must be plural.

We also get a number of additional methods.  For example, we get a method for shoveling a `Rating` object into a dog's collection of ratings:  `#ratings.<<`.  We also get getter and setter methods that work with the id values of the associated objects rather than the objects themselves: `#rating_ids` and `#rating_ids=`.  As with `.belongs_to`, we also get methods for building and creating ratings associated with a dog:  `#ratings.build`, `#ratings.create`, and `#ratings.create!`.

We'll explore some of these methods in this challenge.  For a more comprehensive list and description of the methods provided, read the [API Dock description](http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many).


### Active Record Conventions
When we declare a has many association, the conventions we'll follow are very similar to the conventions when declaring a belongs to association.  And, we'll configure broken conventions in the same way.

When we declare a has many association, we pass an argument that says what we we have (e.g. `:ratings` in our example).  Active Record expects to find a class with a name matching this argument.  In this case, we passed `:ratings`, and Active Record expects to find a `Rating` class.  We have one, so we're all right.

In addition, Active Record needs to know how to identify the many ratings that a dog has.  In other words, it needs to know the foreign key on the ratings table that points to a dog.  The convention is that the name of the foreign key will match the name of the model declaring the has many association.  In our case, the `Dog` class is declaring the has many association, so the ratings table should have a foreign key field named `dog_id`.  Again, we're following convention.

```ruby
class Dog < ActiveRecord::Base
  has_many :ratings, { :class_name => "Rating", :foreign_key => :dog_id }
end
```
*Figure 3*.  Passing an options hash when declaring a has many association.

In our example, we're following conventions, so we do not need to configure our association.  If one of these conventions were broken, we would have to configure the association.  In other words, we'd have to tell Active Record where to look.  We can do that with an optional hash argument that we can pass to the `.has_many` method.  Active Record is going to assume that a specific class and a specific foreign key exits.  If they're not there we can pass that information along (see Figure 3).

Earlier in this *Summary* section, we identified a couple more has many associations.  A person, as an owner, has many dogs.  If in the `Person` class we declared the association `has_many :dogs`, would it work?  What conventions would Active Record expect?

Active Record will expect that a class `Dog` exists.  We have one, so we've not broken that convention.  It will also expect that the dogs table has a `person_id` foreign key field, but looking at our schema in Figure 1, there is no `person_id` field on the `dogs` table.  We've broken convention.  Instead, there is an `owner_id` field, and we would need to configure our association by specifying the foreign key field that Active Record should use.


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

  If we look at our `new_rating` object, it now has a value for `id` and `dog_id`.  When we shoveled `new_rating` into `tenley`'s collection of ratings, Active Record updated the `dog_id` attribute of `new_record` to match `tenley's` `id` attribute.  And, it saved `new_record`, which assigned the `id` attribute.

- `tenley.ratings.include? new_rating`

  Running this, we should see that `tenley`'s ratings now include our `new_rating` object.  Note that Active Record did not query the database when we ran this.  `tenley`'s records had already been loaded.

- `tenley.rating_ids`

  This returns an array of `tenley`'s rating `id`s.

-  `tenley.ratings.build(coolness: 7, cuteness: 9, judge_id: 5)`

  We're creating a new `Rating` and associating it with `tenley`.  The new `Rating` object has its `dog_id` attribute set to `tenley`'s `id`.  The new `Rating` object's `id` is `nil` because it's not been saved to the database; this object only exits in Ruby.

- `tenley.ratings`

 If we look in the returned collection of `Rating` objects, we'll see our `Rating` with the `id` `nil`.

- `tenley.save`

  When we call save here on `tenley`, `tenley`'s newly built rating was also saved.

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
