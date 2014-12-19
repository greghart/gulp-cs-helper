gulp-cs-helper
==============

A module for exploring how to setup a Coffeescript Gulp based workflow. Basically just a personal project to bundle up
dependencies in an easy to use fashion.

## Features
* Watch and compile Coffeescript easily
* Extend gulp object with sane defaults
* Bundle up all necessary dependencies rather than tracking down Gulp docs on each new project (or copy pasting)

## Usage 
  npm install gulp-cs-helper --save
  
```coffee
# Gulpfile.coffee
gulp = require 'gulp'
require('gulp-cs-helper').help gulp,
  src: '.src/**/*.coffee'
  dir: './lib/'

gulp.task 'build', gulp.coffee
gulp.task 'watch', ->
  gulp.watch gulp.src, ['build']
```

Written in .litcoffee, so take a look with your favorite markdown editor to check out how it works
