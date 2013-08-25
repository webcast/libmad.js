class MadSource
  constructor: (opts = {}) ->
    @bufferSize = opts.bufferSize
    @reampler = opts.resampler || Samplerate.FASTEST
    @decoder = opts.decoder
    @format = opts.format
    @context = opts.context

    @remaining  = []
    @resamplers = []
    @pending    = []
    for i in [0..@format.channels-1]
      @remaining[i]  = new Float32Array
      @pending[i]    = new Float32Array
      @resamplers[i] = new Samplerate
        type: @resampler

    @oscillator = @context.createOscillator()
    @source = @context.createScriptProcessor @bufferSize, @format.channels, @format.channels

    @source.onaudioprocess = @processBuffer
    @oscillator.connect @source

    setTimeout @decodeBuffer, 0

    @source.start = (pos) =>
      bufferDuration = parseFloat(@bufferSize)/parseFloat(@context.sampleRate)
      @handler = setInterval @decodeBuffer, 1000*bufferDuration
      @oscillator.start pos

    @source.stop = (pos) =>
      @oscillator.stop pos
      @oscillator.disconnect()
      clearInterval @handler if @handler?
      @handler = null

  concat: (a,b) ->
    return a if typeof b == "undefined" or b.length == 0
    return b if a.length == 0

    ret = new Float32Array a.length+b.length
    ret.set a
    ret.subarray(a.length).set b
    ret

  decodeBuffer: =>
    fn = (buffer, err) =>
      return @source.onerror?(err) if err?

      for i in [0..buffer.length-1]
        if @format.sampleRate != @context.sampleRate
          buffer[i] = @concat @remaining[i], buffer[i]
 
          {data, used} = @resamplers[i].process
            data:  buffer[i]
            ratio: parseFloat(@context.sampleRate) / parseFloat(@format.sampleRate)

          @remaining[i] = buffer[i].subarray used
          buffer[i] = data

        @pending[i] = @concat @pending[i], buffer[i]

      return if @pending[0].length >= @bufferSize

      @decoder.decodeFrame fn

    @decoder.decodeFrame fn

  processBuffer: (buf) =>
    for i in [0..@format.channels-1]
      channelData = buf.outputBuffer.getChannelData i
      samples = Math.min @pending[i].length, channelData.length
      channelData.set @pending[i].subarray(0, samples)
      @pending[i] = @pending[i].subarray samples, @pending[i].length

AudioContext = window.webkitAudioContext || window.AudioContext

AudioContext.prototype.createMadSource = (bufferSize, decoder, format, resampler) ->
  mad = new MadSource
    bufferSize : bufferSize
    context    : this
    decoder    : decoder
    format     : format

  mad.source
