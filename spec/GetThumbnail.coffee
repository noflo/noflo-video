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
        chai.expect(data).to.equal 'https://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for YouTube playlist', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/tS8s7cBqfK0/hqdefault.jpg'
        done()
      ins.send 'https://www.youtube.com/watch?v=tS8s7cBqfK0&list=PLB2CD92050E0F9B8E&index=76'
    it 'should produce thumbnail URL for minified YouTube URL', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send 'http://youtu.be/NLqAF9hrVbY'
    it 'should produce thumbnail URL for simple YouTube URLs', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send 'http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US'
    it 'should produce thumbnail URL for YouTube user pages', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/1p3vcRhsYGo/hqdefault.jpg'
        done()
      ins.send 'http://www.youtube.com/user/Scobleizer#p/u/1/1p3vcRhsYGo'
    it 'should produce thumbnail URL for YouTube via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/VBbsqJ27HZ0/maxresdefault.jpg'
        done()
      ins.send '//cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2FVBbsqJ27HZ0%3Ffeature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DVBbsqJ27HZ0&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2FVBbsqJ27HZ0%2Fhqdefault.jpg&key=internal&type=text%2Fhtml&schema=youtube'
    it 'should produce thumbnail URL for YouTube via Embed.ly (entitized)', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'https://img.youtube.com/vi/VBbsqJ27HZ0/maxresdefault.jpg'
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
    it 'should produce thumbnail URL for SoundCloud via Embed.ly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'http://i1.sndcdn.com/artworks-000191113056-akbwmo-t500x500.jpg'
        done()
      ins.send '//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Fvisual%3Dtrue%26url%3Dhttp%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F289396323%26show_artwork%3Dtrue&url=https%3A%2F%2Fsoundcloud.com%2Fstansono%2Frewind&image=http%3A%2F%2Fi1.sndcdn.com%2Fartworks-000191113056-akbwmo-t500x500.jpg&key=internal&type=text%2Fhtml&schema=soundcloud'
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
    it 'should produce safe thumbnail URL for non-secure Vimeo source via embedly', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.match /^https:/
        chai.expect(data.html).to.match /image=https/
        done()
      ins.send
        html: '<iframe src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fplayer.vimeo.com%2Fvideo%2F110527483&amp;url=https%3A%2F%2Fvimeo.com%2F110527483&amp;image=http%3A%2F%2Fi.vimeocdn.com%2Fvideo%2F494826799_1280.jpg&amp;key=b7d04c9b404c499eba89ee7072e1c4f7&amp;type=text%2Fhtml&amp;schema=vimeo" width="1000" height="563" scrolling="no" frameborder="0" allowfullscreen="allowfullscreen"></iframe>'
    it 'should produce thumbnail URL for YouTube', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.video).to.equal '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ"></iframe>'
    it 'should produce thumbnail URL for YouTube playlist', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/tS8s7cBqfK0/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="https://www.youtube.com/watch?v=tS8s7cBqfK0&list=PLB2CD92050E0F9B8E&index=76"></iframe>'
    it 'should produce thumbnail URL for minified YouTube URL', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="http://youtu.be/NLqAF9hrVbY"></iframe>'
    it 'should produce thumbnail URL for simple YouTube URLs', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US"></iframe>'
    it 'should produce thumbnail URL for YouTube user pages', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/1p3vcRhsYGo/hqdefault.jpg'
        done()
      ins.send
        html: '<iframe src="http://www.youtube.com/user/Scobleizer#p/u/1/1p3vcRhsYGo"></iframe>'
    it 'should strip out any dummy HTML around a possible source which have children', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/t0T_h7Pt4Ug/maxresdefault.jpg'
        done()
      ins.send
        html: "<a data-grid-id=\"2a557a4d-92e9-4081-8748-35cec9052ccd\" href=\"href\"><iframe width=\" 560\" height=\"315\" src=\"https://www.youtube.com/embed/t0T_h7Pt4Ug\" frameborder=\"0\" allowfullscreen=\"\">\"What would you attempt if you knew you couldn't fail?</iframe></a>"
    it 'should strip out any dummy HTML around a possible source', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/or88GPhXlWw/hqdefault.jpg'
        done()
      ins.send
        html: "<a href=\"href\"><iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/or88GPhXlWw\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>\"Hel</a>"
    it 'should strip out any really dummy HTML around a possible source', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/or88GPhXlWw/hqdefault.jpg'
        done()
      ins.send
        html: "<a href=\"href\"><b></b><h1><b><i><p><iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/or88GPhXlWw\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>\"Hel</p></i></b><b><i>Foo</i></b></a>"
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
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
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/bWKzVO7WJcU/maxresdefault.jpg'
        done()
      ins.send
        html: '<iframe src="https://cdn.embedly.com/widgets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2FbWKzVO7WJcU%3Ffeature%3Doembed&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DbWKzVO7WJcU&image=http%3A%2F%2Fi.ytimg.com%2Fvi%2FbWKzVO7WJcU%2Fmaxresdefault.jpg&key=b7d04c9b404c499eba89ee7072e1c4f7&type=text%2Fhtml&schema=youtube" width="854" height="480" scrolling="no" frameborder="0" allowfullscreen="allowfullscreen"></iframe>'
    it 'should not produce thumbnail URL for video with src attribute', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      ins.send
        html: "<video autoplay=\"true\" loop=\"true\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.mp4\"></video>"
    it 'should not produce thumbnail URL for video with source child', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      ins.send
        html: "<video autoplay=\"true\" loop=\"true\"><source type=\"video/mp4\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.mp4\"><source type=\"video/webm\" src=\"//s3-us-west-2.amazonaws.com/cdn.thegrid.io/posts/cta-ui-bg.webm\"></video>"
    it 'should not produce thumbnail URL for empty video', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      ins.send
        html: "<video></video>"
    it 'should not produce thumbnail URL for invalid HTML video block', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      ins.send
        html: "<video></video"
    it 'should not produce thumbnail URL for invalid HTML block', (done) ->
      @timeout 6000
      missed.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        done()
      ins.send
        html: "<p></p>"

  describe 'with a video object', ->
    it 'should produce thumbnail URL for YouTube without query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/8Dos61_6sss/maxresdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/8Dos61_6sss'
    it 'should produce thumbnail URL for YouTube with query', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/P5cdlLTqb24/hqdefault.jpg'
        done()
      ins.send
        video: '//www.youtube.com/embed/P5cdlLTqb24?list=UUnPE7t9tqwcsO0LLyw5zuPQ'
    it 'should produce thumbnail URL for YouTube playlist', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/tS8s7cBqfK0/hqdefault.jpg'
        done()
      ins.send
        video: 'https://www.youtube.com/watch?v=tS8s7cBqfK0&list=PLB2CD92050E0F9B8E&index=76'
    it 'should produce thumbnail URL for minified YouTube URL', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send
        video: 'http://youtu.be/NLqAF9hrVbY'
    it 'should produce thumbnail URL for simple YouTube URLs', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/NLqAF9hrVbY/hqdefault.jpg'
        done()
      ins.send
        video: 'http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US'
    it 'should produce thumbnail URL for YouTube user pages', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://img.youtube.com/vi/1p3vcRhsYGo/hqdefault.jpg'
        done()
      ins.send
        video: 'http://www.youtube.com/user/Scobleizer#p/u/1/1p3vcRhsYGo'
    it 'should produce thumbnail URL for Vimeo', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.equal 'https://i.vimeocdn.com/video/470731940_1280x720.jpg'
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
    it 'should produce thumbnail for Vimeo URL', (done) ->
      @timeout 6000
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.src).to.be.equal 'https://i.vimeocdn.com/video/605511151_1920x1080.jpg'
        done()
      ins.send
        video: 'https://vimeo.com/169598313'
