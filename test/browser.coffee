b = require 'b-assert'

browserIt = if window? then it else (-> null)

browserIt 'browser compares equals', ->
  unless window?
    throw new Error 'Only works in browsers'
  # noop
  b true, true
