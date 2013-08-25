Libmad.js
========================

This repository provides a build of the mad MP3 decoding library in JavaScript.

Decoding API
------------

```
var file = // Request a File object..

file.createMadDecoder(function (decoder, format, err) {
  if (err) {
    console.log("Error while opening decoder", err);
    return
  }

  console.log("Decoder ready!";
  console.log("Samplerate: " + format.sampleRate);
  console.log("Channels: " + format.channels);
  console.log("Bitrate" " + format.bitRate);

  decoder.decodeFrame(function (data, err) {
    if (err) {
      return decoder.close();
    }
    
    // Format can theorically change in each frame.
    // This function returns invalid values if no frame
    // has been decoded.
    var currentFormat = decoder.getCurrentFormat(); 
    console.log("Got a frame!");
    console.log("Frame samplerate: " + currentFormat.sampleRate);
    console.log("Frame channels: " + currentFormat.channels);
    console.log("Frame bitrate" " + currentFormat.bitRate);
    
    console.log("Now processing data");
    // data is an array of Float32Arrays..
  });
});
```

The library also provides a wrapper to create a source node for the [Web Audio API](https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html):

```
var context = new AudioContext;
var source = context.createMadSource(1024, decoder, format);
source.connect(context.destination);

// The meaning of the argument is the same as for AudioBufferSourceNode
source.start(0);
```

Does it work?
-------------

Certainly so! Check the `examples/` directory for two implementations using the Web Audio API. 

Those examples have been tested and are working in Chrome. Firefox still needs to finish implementing the Web Audio API for it to
work, though.. Also, beware of [this webkit bug](https://bugs.webkit.org/show_bug.cgi?id=112521) when implementing your own stuff..

Author
------

Romain Beauxis <toots@rastageeks.org>

Code derived from libmp3lame-js by:
Andreas Krennmair <ak@synflood.at>

License
-------

libmad.js is published under the license terms as mad.
