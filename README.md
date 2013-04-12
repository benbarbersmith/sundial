Sundial
=======

Sundial is a telephone number to timezone conversion tool. Give it
a telephone number (in any format) and it'll tell you the local time and
timezone.

Sundial works particularly well with US telephone numbers, and in the US it
can look up timezones by area code. Unless your telephone number has an
international country code prefix like `+44`, `0044`, `+385` or `00385`, Sundial
will assume that you are converting a US telephone number.

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

Browse to the application root, then enter a telephone number that you
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
