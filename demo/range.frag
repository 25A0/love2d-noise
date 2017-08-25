// Number of mountain ranges
uniform int ranges = 1;
// Current mountain range index
uniform int range = 0;
// Sky color
uniform vec3 fade_color = vec3(1.0, 1.0, 1.0);
float div = 1/256;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  vec4 encoded_noise = Texel(texture, vec2(texture_coords.x, 0.001 + float(range-1)/float(ranges)));
  float n = encoded_noise.r; // + encoded_noise.g * div + encoded_noise.b * div * div;

  float dist = float(ranges - range)/float(ranges);
  // draw a mountain range
  if(texture_coords.y > n) {
  	vec3 range_color = color.rgb + vec3(0.42, 0.70, 0.76) * (texture_coords.y - .4 - 0.25 * (1-n));
  	return vec4(mix(range_color, fade_color, dist), 1.0);
  }

  discard;

}

