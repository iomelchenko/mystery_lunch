Mystery Lunch application - at the beginning of each month every employee is  
randomly selected to have lunch with another employee from a different department.

## System dependencies
* Ruby version - 2.7.1
* ImageMagic - for images resizing
* Docker (in case you want to setup application in the virtual container)

## Application setup
* ### Local setup without Docker
* clone the app from repository  
`git clone git@github.com:iomelchenko/mystery_lunch.git`
* `cd mystery_lunch`
* `bundle install`
* `rake db:setup` - creates the database with an initial seeds
* `yarn install`
* adjust crontab (using whenever gem)
* `whenever --user your_local_user_name`
* `whenever --update-crontab --set environment='development'` - make it work on the dev environment
* `whenever --update-crontab` - update crontab
* `crontab -l` - check crontab in the System  
whenever logs you can see in these files:  
log/cron.log  
log/cron_error.log  
* Run the project in the development environment  
`rails s`
* open the url - `localhost:3000`

* User for Login  
`email: 'hr@example.com'`  
`password: 'Test1234'`  
this user has an admin role, without this role you can't access `users` resources  

* ### Local setup with Docker  
Tested on Ubuntu 18.04 system local environment  
* clone the app from repository  
  `git clone git@github.com:iomelchenko/mystery_lunch.git`
* `cd mystery_lunch`
* `docker-compose build`
* `docker-compose run web yarn install`
* `docker-compose run web rake db:setup`
* run `docker-compose up`

* open the url - `localhost:3000`

##  How to run the test suite  
run in the application folder  
`rspec ./spec`

##  Important considerations

### Algorithm
Since identified users allocation as a `NP-complete` problem, I'm using a greedy algorithm to achieve the best result for an appropriate time.
### Libraries
Some solutions were pragmatic (due to the small amount of project functionality).  
For the production project I'd use:  
* Device gem instead custom Simple session
* sidekiq and sidekiq-cron gems instead whenever gem for automation processes  
(also moved `add_new_use` and `delete_from_meeting` actions to the background)

* Vue.js framework with grid instead of JQuery Datatables

### TODO
* implement PG full text search for search by user_name/department  
(since sql filter `user.name ILIKE :search OR department.name ILIKE :search` can be slow on some amount of data);
* use `I18n` for translations in the codebase;

Thank you for reading this file to the end :)
