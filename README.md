# About LePo

LePo is a Web-based LMS (Learning Management System) that is developing with the aim of supporting the following three activities.

1. learner centered active learnings
1. instructional scaffoldings
1. data and function interoperation

# Getting Started [For Dev & Test Environment]

1. prepare the environment with Ruby 2 and Rails 5

1. clone or download lepo code

1. install ImageMagick

1. bundle install

1. rails db:migrate

1. rails s  -b 127.0.0.1

1. access the top page ( localhost:3000 ) with web browser and follow the shown instruction.

 (For the initial configuration, signin with system admin account is limited for IP address 127.0.0.1.)

# For Production Environment

* set "SECRET_KEY_BASE" value as environment variable

* recommended environment: Nginx, Unicorn and MariaDB (MySQL)

# Current Status
 - LePo is in alpha version. In the near future, there may be a big code change.
 - We assume use LePo in Japanese now, but English language pack is also under development.
