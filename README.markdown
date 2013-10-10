Problem Child Literary Magazine
===============================

[![Build Status](https://travis-ci.org/chadoh/pcmag.png?branch=master)](https://travis-ci.org/chadoh/pcmag)
[![Coverage Status](https://coveralls.io/repos/chadoh/pcmag/badge.png?branch=master)](https://coveralls.io/r/chadoh/pcmag?branch=master)

Contributing
------------

To get this thing up and running in your own development environment,
you'll need to clone this project as well as [the ansible setup] and
[the ansible source]. (Ensure the ansible setup and the pcmag repos are
in the same parent directory). Also, make sure you have [Vagrant]
and [VirtualBox] installed. Then `cd` into the pcmag directory and
`vagrant up`.

Then go do some stretching/pushups/drinking. It'll be a bit of a wait.

Once it's done, you can `vagrant ssh` to get into the VM where
everything's installed. You'll probably want to

    rake db:setup
    rake db:test:clone
    rspec
    cucumber

To set up the dev and test db and run all the tests.

  [the ansible setup]: https://github.com/chadoh/ansible-starter
  [the ansible source]: http://chadoh.github.io/ansible-presentation/?full#3
  [Vagrant]: http://www.vagrantup.com/
  [VirtualBox]: https://www.virtualbox.org/
