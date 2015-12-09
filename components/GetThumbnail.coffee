noflo = require 'noflo'
superagent = require 'superagent'
htmlparser = require 'htmlparser'
uri = require 'urijs'

getThumbnail = (video, callback) ->
  match = video.match /youtube.com\/embed\/([^?]*)/
  if match
    return getYouTube match[1], callback
  match = video.match /vimeo.com\/video\/([^?]*)/
  if match
    return getVimeo match[1], callback
  match = video.match /cdn.embedly.com\/widgets\/media.html/
  if match
    return getEmbedly video, callback
  callback video

getYouTube = (id, callback) ->
  callback null, "http://img.youtube.com/vi/#{id}/hqdefault.jpg"

getVimeo = (id, callback) ->
  superagent.get("http://vimeo.com/api/v2/video/#{id}.json")
  .end (err, res) ->
    return callback err if err
    try
      data = JSON.parse res.text
    catch e
      return callback new Error "Failed to parse response"
    return callback new Error 'Missing return info' unless data.length
    callback null, data[0].thumbnail_large

getEmbedly = (url, callback) ->
  parsed = uri url.replace /&amp;/g, '&'
  unless parsed.hasQuery 'src'
    return callback new Error 'No source embed found for Embed.ly'
  if parsed.hasQuery 'image'
    data = parsed.search true
    return callback null, data.image

  # Fall back to regular handling
  data = parsed.search true
  getThumbnail data.src, callback

goDeep = (dom) ->
  src = null
  for root in dom
    unless root.children
      # Root is a child
      if root.name in ['video', 'iframe', 'source']
        if root.attribs?.src
          return root.attribs?.src
        return
    # Otherwise, keep going deeper trying to find some child
    url = goDeep root.children if root.children
    # Only say we find a src if it's not null
    src = url if url
  return src

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'youtube-play'
  c.description = 'Generate a thumbnail image URL for a video'

  c.inPorts.add 'in',
    datatype: 'all'
    description: 'Video URL or an object containing a "video" key'
  c.outPorts.add 'out',
    datatype: 'all'
  c.outPorts.add 'missed',
    datatype: 'all'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    error: 'missed'
    async: true
    forwardGroups: true
  , (video, groups, out, callback) ->
    if typeof video is 'string'
      getThumbnail video, (err, thumb) ->
        return callback err if err
        out.send thumb
        do callback
      return
    if typeof video is 'object' and video.video
      getThumbnail video.video, (err, thumb) ->
        return callback video if err
        video.src = thumb
        out.send video
        do callback
      return
    if typeof video is 'object' and video.html
      handler = new htmlparser.DefaultHandler (err, dom) ->
        return callback err if err
        return callback null, video if dom.length > 1
        return callback null, video unless dom.length
        src = goDeep dom
        return callback null, video unless src
        getThumbnail src, (err, thumb) ->
          return callback video if err
          video.src = thumb
          out.send video
          do callback
        return
      parser = new htmlparser.Parser handler
      parser.parseComplete video.html
      return
    callback video
