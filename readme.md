Numidium [![Build Status](https://travis-ci.org/DarkWiiPlayer/numidium.svg?branch=master)](https://travis-ci.org/DarkWiiPlayer/numidium) [![Gem Version](https://badge.fury.io/rb/numidium.svg)](https://badge.fury.io/rb/numidium)
============

**Numidium is being completely rewritten for version 0.6**

Reason
--------
It just seemed like the project could benefit from being a bit more object oriented without necessarily losing it's paradimg-agnostic nature.

Changes
--------
- Test class: Represents a single test
- Result class: Represents the result of a single test run
- Suite class: Represents a test suite, several approaches possible
  - Instantiating: Every instance can represent a different test suite
  - Subclassing: Every subclass keeps track of its instances and subclasses and can call them all in one go.
- Modules: While it would be possible for modules to create new Tests directly, it is still possible to turn an array with a string and a proc into a test.

