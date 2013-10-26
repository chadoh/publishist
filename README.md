Publishist.com
==============

[![Build Status](https://travis-ci.org/chadoh/publishist.png?branch=master)](https://travis-ci.org/chadoh/publishist)
[![Coverage Status](https://coveralls.io/repos/chadoh/publishist/badge.png?branch=master)](https://coveralls.io/r/chadoh/publishist?branch=master)

Running it locally
------------------

To get this thing up and running in your own development environment,
you'll need to clone this project as well as [the ansible setup] and
[the ansible source]. (Ensure the ansible setup and the publishist repos are in
the same parent directory). Also, make sure you have [Vagrant] and [VirtualBox]
installed. Then `cd` into the publishist directory and `vagrant up`.

Then go do some stretching/pushups/drinking. It'll be a bit of a wait.

Once it's done, you can `vagrant ssh` to get into the VM where
everything's installed.

  [the ansible setup]: https://github.com/chadoh/ansible-starter
  [the ansible source]: http://chadoh.github.io/ansible-presentation/?full#3
  [Vagrant]: http://www.vagrantup.com/
  [VirtualBox]: https://www.virtualbox.org/

### Running the tests

Once you've got it up and running the first time, you'll have to run these before you can run the tests:

    rake db:setup
    rake db:test:clone

Then you can run the tests/specs with these commands:

    rspec
    cucumber

RSpec runs all of the specs in the `spec` directory, while Cucumber runs all of
the "Features" in the `features` directory.

### Running the app

To start the app locally and run it in your browser, first you'll need to:

    rake db:setup

(If you haven't already.) This creates the database, loads in the schema from
`db/schema.rb`, then runs `rake db:seed` which loads in all of the data from
`db/seeds.rb`.

Then, run

    foreman start

to start the app. Once it says it's ready, visit problemchild.lvh.me:3000 in
your browser.

lvh.me is a website that some helpful person set up that is just an alias for
"localhost". So instead of visiting "localhost:3000", you can visit
"lvh.me:3000". For Publishist to work, it _needs_ a subdomain, and subdomains
don't work with "localhost". So lvh.me is a nice fast way of getting it
working.

Unfortunately, lvh.me requires internet connectivity. If you're going to be on
a plane or train and want to work on Publishist, you should consider setting up
your `/etc/hosts` file to handle some subdomains for you. Here's how:

1.  Go to your command line and use your favorite editor to open "/etc/hosts".
    For example:

        subl /etc/hosts

2.  Find the line that says

        127.0.0.1 localhost

    This line is just telling your computer that when you visit "localhost" in a
    browser, go to the IP address "127.0.0.1".

3.  Add these lines:

        127.0.0.1 publishist.dev
        127.0.0.1 problemchild.publishist.dev
        127.0.0.1 conspire.publishist.dev

4.  Visit problemchild.publishist.dev:3000 in your browser. Huzzah!

### Signing into the app

If you read db/seeds.rb, you'll see that two Publications will have
been created for you, "Problem Child" and "Conspire". Here are some of their
users that you can log in as:

* editor@problemchild.com
* coeditor@problemchild.com
* pr@problemchild.com
* editor@conspire.com
* coeditor@conspire.com
* pr@conspire.com

The password for all of the users created by db/seeds.rb is "bubbles".
