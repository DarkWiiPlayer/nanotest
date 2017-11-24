@echo off
call gem build nanotest.gemspec
call gem install nanotest*.gem

echo.Running selftest/examples...
echo.
ruby selftest.rb
timeout 3
