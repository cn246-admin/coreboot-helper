# Coreboot build helper
I wrote this to assist in building a custom coreboot rom for Lenovo x230. 

## What it do
So far, it will:
1.  Removes old coreboot roms
2.  Builds new coreboot roms
3.  Adds custom files
    * zerocat.cfg
    * Moves secondary payloads
    * Adds seabios payload
    * Adds background image(s)
4. Tweak parameters
    * gfx_uma_size=224M
    * wwan=Disable
    * bluetooth=Disable
5. Split 12M rom into 8M(Bottom) and 4M(Top) files
