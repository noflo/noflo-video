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
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for YouTube via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/VBbsqJ27HZ0/maxresdefault.jpg'
        done()
      ins.send '//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2FVBbsqJ27HZ0%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DVBbsqJ27HZ0&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2FVBbsqJ27HZ0%2Fhqdefault.jpg&key=internal&type=text%2Fhtml&schema=youtube'
    it 'should produce thumbnail URL for YouTube via Embed.ly (entitized)', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://img.youtube.com/vi/VBbsqJ27HZ0/maxresdefault.jpg'
        done()
      ins.send 'https://cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2FVBbsqJ27HZ0%3Ffeature%3Doembed&amp;url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DVBbsqJ27HZ0&amp;image=http%3A%2F%2Fi.ytimg.com%2Fvi%2FVBbsqJ27HZ0%2Fhqdefault.jpg&amp;key=b7d04c9b404c499eba89ee7072e1c4f7&amp;type=text%2Fhtml&amp;schema=youtube'
    it 'should produce thumbnail URL for Vimeo', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://i.vimeocdn.com/video/470731940_1280x720.jpg'
        done()
      ins.send '//player.vimeo.com/video/91393694?title=0&amp;byline=0&amp;color=ffffff'
    it 'should produce thumbnail URL for Vimeo via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://i.vimeocdn.com/video/475921185_1280x720.jpg'
        done()
      ins.send '//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fplayer.vimeo.com%2Fvideo%2F95895989&src_secure=1&url=http%3A%2F%2Fvimeo.com%2F95895989&image=http%3A%2F%2Fi.vimeocdn.com%2Fvideo%2F475921185_1280.jpg&key=internal&type=text%2Fhtml&schema=vimeo'
    it 'should produce thumbnail URL for Vine via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://v.cdn.vine.co/r/videos/B5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg?versionId=edU_LrAtIFsGvZj.Fgi0Si1bem68tBlk'
        done()
      ins.send '//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fmtc.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4%3FversionId%3DMfbYrYHKtQn5CarqDt9SoZHnUeQRVt7Z&src_secure=1&url=https%3A%2F%2Fvine.co%2Fv%2FOUnPWge7Jnj&image=https%3A%2F%2Fv.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg%3FversionId%3DedU_LrAtIFsGvZj.Fgi0Si1bem68tBlk&key=internal&type=video%2Fmp4&schema=vine'
    it 'should not produce thumbnail URL for video tags', (done) ->
      missed.on 'data', (data) ->
        chai.expect(data).to.equal 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'
        done()
      ins.send 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'

  describe 'with a HTML object', ->
    it 'should produce thumbnail URL for YouTube', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.video).to.equal '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ"></iframe>'
    it 'should strip out any dummy HTML around a possible source which have children', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/t0T_h7Pt4Ug/maxresdefault.jpg'
        done()
      ins.send
        html: "<a data-grid-id=\"2a557a4d-92e9-4081-8748-35cec9052ccd\" href=\"href\"><iframe width=\" 560\" height=\"315\" src=\"https://www.youtube.com/embed/t0T_h7Pt4Ug\" frameborder=\"0\" allowfullscreen=\"\">\"What would you attempt if you knew you couldn't fail?</iframe></a>"
    it 'should strip out any dummy HTML around a possible source', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/or88GPhXlWw/hqdefault.jpg'
        done()
      ins.send
        html: "<a href=\"href\"><iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/or88GPhXlWw\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>\"Hel</a>"
    it 'should strip out any really dummy HTML around a possible source', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/or88GPhXlWw/hqdefault.jpg'
        done()
      ins.send
        html: "<a href=\"href\"><b></b><h1><b><i><p><iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/or88GPhXlWw\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>\"Hel</p></i></b><b><i>Foo</i></b></a>"
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
        done()
      ins.send
        html: "<iframe src=\"//www.youtube.com/embed/8Dos61_6sss\"></iframe>"
    it 'should produce thumbnail URL for Vine via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://v.cdn.vine.co/r/videos/B5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg?versionId=edU_LrAtIFsGvZj.Fgi0Si1bem68tBlk'
        done()
      ins.send '<iframe class="embedly-embed" src="//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fmtc.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4%3FversionId%3DMfbYrYHKtQn5CarqDt9SoZHnUeQRVt7Z&src_secure=1&url=https%3A%2F%2Fvine.co%2Fv%2FOUnPWge7Jnj&image=https%3A%2F%2Fv.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg%3FversionId%3DedU_LrAtIFsGvZj.Fgi0Si1bem68tBlk&key=internal&type=video%2Fmp4&schema=vine" width="500" height="500" scrolling="no" frameborder="0" allowfullscreen></iframe>'
    it 'should produce thumbnail URL for YouTube via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/bWKzVO7WJcU/maxresdefault.jpg'
        done()
      ins.send
        html: '<iframe src="https://cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2FbWKzVO7WJcU%3Ffeature%3Doembed&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DbWKzVO7WJcU&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2FbWKzVO7WJcU%2Fmaxresdefault.jpg&key=b7d04c9b404c499eba89ee7072e1c4f7&type=text%2Fhtml&schema=youtube" width="854" height="480" scrolling="no" frameborder="0" allowfullscreen="allowfullscreen"></iframe>'
    it 'should not produce thumbnail URL for video with src attribute', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        # chai.expect(data.src).to.equal 'http://i.ytimg.com/vi/bWKzVO7WJcU/hqdefault.jpg'
        done()
      ins.send
        html: "<video autoplay=\"true\" loop=\"true\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.mp4\"></video>"
    it 'should not produce thumbnail URL for video with source child', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        # chai.expect(data.src).to.equal 'http://i.ytimg.com/vi/bWKzVO7WJcU/hqdefault.jpg'
        done()
      ins.send
        html: "<video autoplay=\"true\" loop=\"true\"><source type=\"video/mp4\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.mp4\"><source type=\"video/webm\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.webm\"></video>"

  describe 'with a video object', ->
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for Vimeo', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'http://i.vimeocdn.com/video/470731940_1280x720.jpg'
        done()
      ins.send
        video: '//player.vimeo.com/video/91393694?title=0&amp;byline=0&amp;color=ffffff'
    it 'should produce thumbnail URL for Vine via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://v.cdn.vine.co/r/videos/B5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg?versionId=edU_LrAtIFsGvZj.Fgi0Si1bem68tBlk'
        done()
      ins.send
        video: '//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fmtc.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4%3FversionId%3DMfbYrYHKtQn5CarqDt9SoZHnUeQRVt7Z&src_secure=1&url=https%3A%2F%2Fvine.co%2Fv%2FOUnPWge7Jnj&image=https%3A%2F%2Fv.cdn.vine.co%2Fr%2Fvideos%2FB5B06468B91176403722801139712_342c9a1c624.1.5.15775156368984795444.mp4.jpg%3FversionId%3DedU_LrAtIFsGvZj.Fgi0Si1bem68tBlk&key=internal&type=video%2Fmp4&schema=vine'
    it 'should not produce thumbnail URL for video tags', (done) ->
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).be.undefined
        done()
      ins.send
        video: 'http://mirrors.dotsrc.org/fosdem/2014/AW1121/Sunday/Flowbased_programming_for_heterogeneous_systems.webm'
