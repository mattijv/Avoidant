extern vec2 size;
extern int samples = 5; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 2.5; // lower = smaller glow, better quality

vec4 cap(vec4 colour);
 
vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;
  


  vec2 offset = vec2(-2, -2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-2, -1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-2, 0) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-2, 1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-2, 2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));

  offset = vec2(-1, -2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-1, -1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-1, 0) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-1, 1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(-1, 2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));

  offset = vec2(0, -2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(0, -1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(0, 0) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(0, 1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(0, 2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));

  offset = vec2(1, -2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(1, -1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(1, 0) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(1, 1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(1, 2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));

  offset = vec2(2, -2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(2, -1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(2, 0) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(2, 1) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  offset = vec2(2, 2) * sizeFactor;
  sum += cap(Texel(tex, tc + offset));
  
  return ((sum / (samples * samples)) + source) * colour;
}

vec4 cap(vec4 colour) {
  return step(0.2,colour)*colour;
}
