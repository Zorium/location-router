# LocationRouter

```coffee
LocationRouter = require 'location-router'
router = new LocationRouter()

# Change url paths
router.go '/test'
router.go '/other_page'

# listen for url path changes
# returns RxJS Observable
router.getStream().subscribe (req) ->
  {url, path, query, hostname} = req
```
