Courseware at Wharton
================================

A rails application utilizing the [Instructure Canvas API](https://canvas.instructure.com/doc/api/index.html).  The goal of this project is to fill in gaps in features The Wharton School most commonly needs that are missing (at the time) from the [Canvas learning management system](http://www.instructure.com/).

These include: 

* Quick Assignment Creation
* Appointment Groups to pdf
* Section Sync to Group Categories and Groups
* Output group membership data to a comma-delimited file

Installation

1.  Clone this repository to a new directory
2.  Install ruby version 1.9.3-p392 (you might consider using [rvm.io](rvm.io) to manage your ruby installs)
3.  Create a new gemset called canvas-app and install the bundler gem
    `gem install bundler`
4.  Use bundle install to install gems (check the Gemfile for required gems)
5.  In order to generate pdf files from appointment groups, you will need to install wkhtmltopdf. Downloads for Windows and Linux can be found [here](http://wkhtmltopdf.org/).  OS X versions can be installed with [Homebrew](http://brew.sh/)

Edit the following files with data from your institution.  You will need your Canvas access_token (API key) and MySQL connection info:

1.  config/application.yml
2.  config/database.yml

Run `bundle exec rake db:migrate`

If you would like to run the Courseware app in production, you’ll need to install Phusion Passenger along with Apache.  There is plenty of documentation for that [here](http://www.modrails.com/documentation/Users%20guide%20Apache.html).

To run locally, type `bundle exec rails s –e development`
 
License
================================

Licensed under MIT license

Copyright (c) 2014 The Wharton School

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.