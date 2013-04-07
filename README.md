Sundial
=======

Sundial is a telephone-number to timezone conversion tool. Give it a US
telephone number (in any old format) and it'll tell you the timezone to
which the number corresponds. 

Installation
------------

Install dependencies using bundler:

    $ bundle install 

That's the only dependency you need; after that, just grab a copy of the souce
and run the application.

    $ rackup 

If you'd rather use a hosted copy, check out `http://sundial.benjaminasmith.com/`. 

Usage
-----

Browse to the application root, then enter a US telephone number that you
would like to lookup. Format is not important.

There are other ways to use Sundial besides visiting that page and typing
a number into the box. You can visit a URL like
`http://sundial.benjaminasmith.com/somenumber` to convert `somenumber` with
the number you want to convert. For example, to convert `Cell: 651.342.2323` you would visit the following URL:

   http://sundial.benjaminasmith.com/Cell:%20651.342.2323


Improvements? Ideas?
--------------------

If you have a specific feature request or if you found a bug, please 
[give me a shout](web@benjaminasmith.com). And of course, please feel free to
fork the code or the data and send a pull request with improvements.

Cheers!
