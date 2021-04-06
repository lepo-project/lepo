# About LePo

LePo is a Web-based LMS (Learning Management System) that is developing with the aim of supporting the following three activities.

1. learner centered active learnings
1. instructional scaffoldings
1. data and function interoperation

# Getting Started [For Dev & Test Environment]

1. prepare the environment with Ruby 2 and Rails 5

1. clone or download lepo code

1. install ImageMagick

1. bundle install --without production

1. rails db:migrate

1. check some constants in config/initializers/constants.rb

1. set some credentials as credentials.yml.enc, if necessary
　　(Not necessary for default settings)

1. rails s  -b 127.0.0.1

1. access the top page ( localhost:3000 ) with web browser and follow the shown instruction.

 (For the initial configuration, signin with system admin account is limited for IP address 127.0.0.1.)

# For Production Environment

* set some credentials as credentials.yml.enc (Necessary to set at least for secret_key_base)

* recommended environments: Nginx, Unicorn and MariaDB (MySQL)

# Remarks
 - LePo is in alpha version status. In the near future, there may be a big code change.
 - We assume use LePo in Japanese now, but English language pack is also under development.
 - Using LePo with relative url root (subdirectory) is not supported.
