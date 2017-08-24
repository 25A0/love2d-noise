This is a shader and a bit of lua code for [LOVE2D](https://www.love2d.org) to sample from classic Perlin and Simplex noise on the GPU.

Most of the code is adapted from [Stefan
Gustavson](http://staffwww.itn.liu.se/~stegu/)'s GLSL implementation
(http://staffwww.itn.liu.se/~stegu/simplexnoise/GLSL-noise.zip), I just made
the shader compatible with LOVE and ported the C code that generates the
gradient, permutation and simplex textures to lua.

My only notable contribution is the fact that the noise is seedable; when
compiling the shader you can supply a seed that influences the permutation
texture, which leads to different, but deterministic results for each seed.
Seeding the noise by changing the permutation table is not a new idea, but
Gustavson's implementation didn't have that feature as far as I'm aware.

The seeding should lead to deterministic results across platforms since it uses
LOVE's random number generator internally.

The shader exposes a few variables (`x`, `y`, `z`, `w`, `freq_x`, `freq_y`)
that can be used to offset the sample coordinates and change the frequency.
Additionally, the shader variable `type` determines which noise is used. `type`
can be set to any of the integers 1 through 6.

The shader includes:

 - 2D Perlin noise (type 1)
 - 2D Simplex noise (type 2)
 - 3D Perlin noise (type 3)
 - 3D Simplex noise (type 4)
 - 4D Perlin noise (type 5)
 - 4D Simplex noise (type 6)

The repository includes a small demo to experiment with the different noise
functions, move the sample coordinates, and change the frequency.

### Usage

This repository contains the following files:

 - `noise.frag` the fragment shader that samples the noise
 - `noise.lua` a lua module that handles the noise seeding, compiles the shader, and supplies the necessary data to the shader
 - `main.lua` a small demo to try out the different noise variants

Here is a minimal example to illustrate how to use the shader:

```lua
local noise = require("noise")

local shader

function love.load()
  noise.init()
  -- compile the shader. The second argument is the seed. If no seed is given,
  -- a default permutation table is used
  shader = noise.build_shader("noise.frag", 42)
end

function love.draw()
  love.graphics.translate(100, 0)
  noise.sample(shader, noise.types.simplex2d, 600, 600)
end
```

The example above draws 2D noise directly to the screen. If, instead, you just want to sample noise in a continuous area, and use the noise values in a different way, you could do something like this:

 1. Create a canvas. The size of the canvas depends on the number of samples you need. If you want to sample noise for a 16x16 grid, then a 16x16 canvas is sufficient.
 2. Sample noise using `noise.sample`. Set `samples_x` and `samples_y` to the width and height of your canvas. The sampling area (defined by `x`, `y`, `width`, `height`, `z`, `w`) is up to you.
 3. Extract the image data of the canvas using [`Canvas:newImageData`](https://love2d.org/wiki/Canvas:newImageData)
 4. Process the noise data by extracting individual pixels using [`ImageData:getPixel`](https://love2d.org/wiki/ImageData:getPixel), or by applying a function to each pixel using [`ImageData:mapPixel`](https://love2d.org/wiki/ImageData:mapPixel).

### Documentation

The `noise` module exposes the following variables and functions:

**`noise.init()`** is a function that needs to be called once, before you call `noise.sample` for the first time.

**`noise.types`** is a key-value table where each key is a human-readable name of a noise type available in this shader, and the value is the corresponding integer that can be used in `noise.sample` and `shader:send("type", type)` to define which noise type should be used.

Specifically, it contains:

```lua
noise.types = {
  perlin2d  = 1,
  simplex2d = 2,
  perlin3d  = 3,
  simplex3d = 4,
  perlin4d  = 5,
  simplex4d = 6,
}
```

**`noise.build_shader(path_to_shader, seed)`** is a function that compiles the shader, and returns the compiled shader.

 - `path_to_shader` is a file path pointing towards `noise.frag`.
 - `seed` is an integer that will seed the noise functions. If no seed is given, a default seed will be used.

**`noise.sample(shader, noise_type, samples_x, samples_y, x, y, width, height, z, w)`** samples noise of a certain type in a given area, and renders it to the currently active canvas.

 - `shader` is the compiled shader as returned by `noise.build_shader`.
 - `noise_type` is an integer that defines which type of noise will be sampled, and can be any one of the integer values in `noise.types`. In practice, you can simply do something like `noise.sample(shader, noise.types.simplex3d, ...`.
 - `samples_x` and `samples_y` are integers that define how many noise samples will be drawn along the x and y axis, respectively.
 - `x`, `y`, `width`, `height` are floats that define the area from which samples will be drawn along the x and y axis.
 - `z` and `w` are floats that define at which coordinates the noise will be sampled in the third and fourth dimension, respectively. If 2D noise is used, `z` and `w` is ignored. If 3D noise is used, `w` is ignored.

**`noise.decode(encoding, r, g, b)`** decodes a noise value and returns it as a float in range [0, 1].

 - `encoding` the used encoding scheme. See `noise.encoding` for valid values.
 - `r`, `g`, `b` the RGB components in range [0, 255].

The shader exposes the following variables:

 - `type` is an integer that determines which type of noise is sampled. See `noise.types` for valid values.
 - `encoding` defines in which way the noise value will be encoded in the RGBA components of the canvas. See `noise.encoding` for valid values.
 - `x`, `y`, `z`, `w` are floats that determine at which coordinate the noise is sampled.
 - `freq_x` and `freq_y` are floats that determine the area that will be sampled when rendering a texture with this shader.
