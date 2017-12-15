@echo off
call pik 24 x64
call gem build nanotest.gemspec
call gem install nanotest*.gem

echo.Running selftest/examples...
echo.
ruby selftest.rb
timeout 3
