# About LePo

LePo is a Web-based LMS (Learning Management System) that is developing with the aim of supporting the following three activities.

1. learner centered active learnings
1. instructional scaffoldings
1. data and function interoperation

# Getting Started [For Dev & Test Environment]

1. Prepare the environment with Ruby 2 and Rails 5

1. install imagemagick

1. bundle install

1. rails db:migrate

1. rails s

1. access the top page ( localhost:3000 ) with web browser and follow the shown instruction.

(if you want to launch server in specific IP address, use -b option.)

# For Production Environment

* set "SECRET_KEY_BASE" value as environment variable (ex. in .bash_profile)

* recommended environment: Nginx, Unicorn and MariaDB (MySQL)

# Current Status
 - Now, LePo is alpha version. In the near future, there may be a big code change.
 - We assume use LePo in Japanese now, but English language pack is also under development.
