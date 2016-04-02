noflo = require 'noflo'
superagent = require 'superagent'
htmlparser = require 'htmlparser'
youthumb = require 'youtube-thumbnails'
uri = require 'urijs'

getThumbnail = (video, callback) ->
  youtubeRegexp = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/ ]{11})/i
  match = video.match youtubeRegexp
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
  youthumb.all id, (thumbnails) ->
    if thumbnails?.maxres
      return callback null, "http://img.youtube.com/vi/#{id}/maxresdefault.jpg"
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
    # Start with the largest thumbnail and try to get a better one using
    # dimensions
    thumbnail = data[0].thumbnail_large
    if data[0].width and data[0].height
      urlParts = thumbnail.split '_'
      thumbnail = "#{urlParts[0]}_#{data[0].width}x#{data[0].height}.jpg"
    callback null, thumbnail

getEmbedly = (url, callback) ->
  parsed = uri url.replace /&amp;/g, '&'
  unless parsed.hasQuery 'src'
    return callback new Error 'No source embed found for Embed.ly'
  if parsed.hasQuery 'image'
    data = parsed.search true
    # If it's YouTube or Vimeo, get the thumbnail from src no matter what
    match = data.src.match /youtube.com/
    if match
      return getThumbnail data.src, callback
    match = data.src.match /vimeo.com/
    if match
      return getThumbnail data.src, callback
    # Otherwise, use image src from Embedly
    return callback null, data.image

  # Fall back to regular handling
  data = parsed.search true
  getThumbnail data.src, callback

goDeep = (dom) ->
  src = null
  for root in dom
    # If root is a video or iframe, try to get its src, no matter what
    if root.name in ['video', 'iframe']
      if root.attribs?.src
        return root.attribs?.src
    # Otherwise, see if it is a child
    unless root.children
      # Root is a child, so it's a dead end, or get a src or nothing
      if root.name in ['video', 'iframe', 'source']
        if root.attribs?.src
          return root.attribs?.src
        return null
    # If it's not a child nor video/iframe keep going deeper trying to find
    # some valid block on its children
    url = goDeep root.children if root.children
    # Only say we find a src if it's not null
    src = url if url
  return src

exports.getComponent = ->
  new noflo.Component
    icon: 'youtube-play'
    description: 'Generate a thumbnail image URL for a video'
    inPorts:
      in:
        datatype: 'all'
        description: 'Video URL or an object containing a "video" key;'
        required: true
    outPorts:
      out:
        datatype: 'all'
      missed:
        datatype: 'all'
    process: (input, output) ->
      return unless input.has 'in'
      video = input.getData 'in'
      return unless input.ip.type is 'data'

      if typeof video is 'string'
        getThumbnail video, (err, thumb) ->
          return output.sendDone missed: err if err
          output.sendDone out: thumb
        return
      if typeof video is 'object' and video.video
        getThumbnail video.video, (err, thumb) ->
          return output.sendDone missed: video if err
          video.src = thumb
          output.sendDone out: video
        return
      if typeof video is 'object' and video.html
        handler = new htmlparser.DefaultHandler (err, dom) ->
          return output.sendDone missed: err if err
          return output.sendDone out: video if dom.length > 1
          return output.sendDone out: video unless dom.length
          src = goDeep dom
          return output.sendDone out: video unless src
          video.video = src
          getThumbnail video.video, (err, thumb) ->
            return output.sendDone missed: video if err
            video.src = thumb
            output.sendDone out: video
          return
        parser = new htmlparser.Parser handler
        parser.parseComplete video.html
        return

      output.sendDone missed: video
