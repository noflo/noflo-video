noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetThumbnail = require '../components/GetThumbnail.coffee'
else
  GetThumbnail = require 'noflo-video/components/GetThumbnail.js'

describe 'GetThumbnail component', ->
  c = null
  ins = null
  out = null
  missed = null
  beforeEach ->
    c = GetThumbnail.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    missed = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
    c.outPorts.missed.attach missed

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'with a video URL string', ->
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/8Dos61_6sss/hqdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for Vimeo', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://i.vimeocdn.com/video/470731940_640.jpg'
        done()
      ins.send '//player.vimeo.com/video/91393694?title=0&amp;byline=0&amp;color=ffffff'
    it 'should not produce thumbnail URL for video tags', (done) ->
      missed.on 'data', (data) ->
        chai.expect(data).to.equal 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'
        done()
      ins.send 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'

  describe 'with a video object', ->
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/8Dos61_6sss/hqdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for Vimeo', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://i.vimeocdn.com/video/470731940_640.jpg'
        done()
      ins.send
        video: '//player.vimeo.com/video/91393694?title=0&amp;byline=0&amp;color=ffffff'
    it 'should not produce thumbnail URL for video tags', (done) ->
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).be.undefined
        done()
      ins.send
        video: 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'
