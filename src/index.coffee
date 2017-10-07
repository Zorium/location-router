Qs = require 'qs'
Rx = require 'rxjs/Rx'

urlToReq = (url) ->
  a = document.createElement 'a'
  a.href = url

  {
    protocol: a.protocol
    hostname: a.hostname
    port: a.port
    pathname: a.pathname
    search: a.search
    hash: a.hash
    host: a.host

    url
    path: a.pathname + a.search + a.hash
    query: Qs.parse(a.search?.slice(1))
  }

module.exports = class Router
  constructor: ->
    initReq = urlToReq window.location.href
    @hasRouted = false
    @subject = new Rx.BehaviorSubject(initReq)
    @lastPath = initReq.path

    # some browsers erroneously call popstate on intial page load (iOS Safari)
    # We need to ignore that first event.
    # https://code.google.com/p/chromium/issues/detail?id=63040
    window.addEventListener 'popstate', =>
      setTimeout =>
        req = urlToReq window.location.href
        if @hasRouted and @lastPath isnt req.path
          @lastPath = req.path
          @subject.next req

  getStream: => @subject

  go: (url) =>
    @hasRouted = true
    req = urlToReq url

    if @lastPath isnt req.path
      @lastPath = req.path
      window.history.pushState? null, null, req.path
      @subject.next req
