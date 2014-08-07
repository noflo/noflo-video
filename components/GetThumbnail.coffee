noflo = require 'noflo'
superagent = require 'superagent'
uri = require 'URIjs'

class GetThumbnail extends noflo.AsyncComponent
  icon: 'youtube-play'
  description: 'Generate a thumbnail image URL for a video'
  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'all'
        description: 'Video URL or an object containing a "video" key'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'all'
      missed:
        datatype: 'all'
    super 'in', 'out', 'missed'

  doAsync: (video, callback) ->
    if typeof video is 'string'
      return @getThumbnail video, (err, thumb) =>
        return callback err if err
        @outPorts.out.send thumb
        do callback
    if typeof video is 'object' and video.video
      return @getThumbnail video.video, (err, thumb) =>
        return callback video if err
        video.src = thumb
        @outPorts.out.send video
        do callback
    callback video

  getThumbnail: (video, callback) ->
    match = video.match /youtube.com\/embed\/([^?]*)/
    if match
      return @getYouTube match[1], callback
    match = video.match /vimeo.com\/video\/([^?]*)/
    if match
      return @getVimeo match[1], callback
    match = video.match /cdn.embedly.com\/widgets\/media.html/
    if match
      return @getEmbedly video, callback
    callback video

  getYouTube: (id, callback) ->
    callback null, "http://img.youtube.com/vi/#{id}/hqdefault.jpg"

  getVimeo: (id, callback) ->
    superagent.get "http://vimeo.com/api/v2/video/#{id}.json"
    .end (err, res) ->
      return callback err if err
      try
        data = JSON.parse res.text
      catch e
        return callback new Error "Failed to parse response"
      return callback new Error 'Missing return info' unless data.length
      callback null, data[0].thumbnail_large

  getEmbedly: (url, callback) ->
    parsed = uri url
    unless parsed.hasQuery 'src'
      return callback new Error 'No source embed found for Embed.ly'
    if parsed.hasQuery 'image'
      data = parsed.search true
      return callback null, data.image

    # Fall back to regular handling
    data = parsed.search true
    @getThumbnail data.src, callback

exports.getComponent = -> new GetThumbnail
