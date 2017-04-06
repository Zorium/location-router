Qs = require 'qs'
Rx = require 'rxjs/Rx'

getCurrentUrl = (mode) ->
  hash = window.location.hash.slice(1)
  pathname = window.location.pathname
  search = window.location.search
  if pathname
    pathname += search

  return if mode is 'pathname' then pathname or hash \
         else hash or pathname

parseUrl = (url) ->
  a = document.createElement 'a'
  a.href = url

  {
    pathname: a.pathname
    hash: a.hash
    search: a.search
    path: a.pathname + a.search
  }


module.exports = class Router
  constructor: ->
    @mode = if window.history?.pushState then 'pathname' else 'hash'
    @hasRouted = false
    @subject = new Rx.BehaviorSubject(@_parse())

    # some browsers erroneously call popstate on intial page load (iOS Safari)
    # We need to ignore that first event.
    # https://code.google.com/p/chromium/issues/detail?id=63040
    window.addEventListener 'popstate', =>
      if @hasRouted
        setTimeout =>
          @subject.next @_parse()

  getStream: => @subject

  _parse: (url) =>
    url ?= getCurrentUrl(@mode)
    {pathname, search} = parseUrl url
    query = Qs.parse(search?.slice(1))

    hostname = window.location.hostname

    {url, path: pathname, query, hostname}

  go: (url) =>
    req = @_parse url

    if @mode is 'pathname'
      if @hasRouted
        window.history.pushState null, null, req.url
      else
        window.history.replaceState null, null, req.url
    else
      window.location.hash = req.url

    @hasRouted = true
    @subject.next req
