from PIL import Image
import sys


# Convenience script for converting a 32x32 gif to Red's engine's texture
# format.


fname = sys.argv[1]
fname_prefix = fname.split(".")[0]


im = Image.open(fname)

frame = 0


def chunk(seq, size, groupByList=True):
    func = tuple
    if groupByList:
        func = list
    return [func(seq[i:i + size]) for i in range(0, len(seq), size)]


def getPaletteInRgb(img):
    assert img.mode == 'P', "image should be palette mode"
    pal = img.getpalette()
    colors = chunk(pal, 3, False)
    return colors


with open(fname_prefix + ".asm", "w") as output_file:
    output_file.write("Sprite" + fname_prefix + "::" + "\n")


while True:
    try:
        im.seek(frame)
        print("processing frame {}".format(frame))
    except EOFError:
        with open(fname_prefix + ".asm", "a") as output_file:
            output_file.write("Sprite" + fname_prefix + "End::" + "\n")
        sys.exit(0)

    pal = getPaletteInRgb(im)


    def map_color(gif_palette_index):
        # FIXME: add this color table as an argument to the script, rather than
        # hard-coding the indices.
        rgb = pal[gif_palette_index]

        if rgb == (242, 245, 235):
            return 0
        elif rgb == (20, 0, 0):
            return 3
        elif rgb == (243, 16, 66):
            return 2
        elif rgb == (76, 206, 250):
            return 1
        elif rgb == (184, 207, 239):
            return 1
        elif rgb == (80, 72, 112):
            return 2
        elif rgb == (8, 4, 23):
            return 3
        else:
            raise Exception("unexpected color in cutscene frame " + str(rgb))


    px = im.load()

    w, h = im.size

    if w != 32 or h != 32:
        raise Exception("invalid image size")

    def encode_tile(x, y, output_file):
        tile_out = "DB      "
        tile_temp_1 = 0 # Pixel LSB
        tile_temp_2 = 0 # Pixel MSB

        count = 0
        count2 = 0

        for yy in range(y, y + 8):
            for xx in range(x, x + 8):

                pixel = map_color(px[xx, yy])

                tile_temp_1 = tile_temp_1 | ((pixel & 0x1) << (7 - count))
                tile_temp_2 = tile_temp_2 | (((pixel & 0x2) >> 1) << (7 - count))

                count = count + 1

                if count == 8:
                    count2 += 1
                    tile_out += '${0:0{1}X}, '.format(tile_temp_1, 2)
                    tile_out += '${0:0{1}X}, '.format(tile_temp_2, 2)
                    count = 0
                    tile_temp_1 = 0
                    tile_temp_2 = 0

                if count2 == 4:
                    tile_out += "\nDB      "
                    count2 = 1000

        output_file.write(tile_out + "\n")


    with open(fname_prefix + ".asm", "a") as output_file:
        output_file.write("._{}:\n".format(frame))
        # The game uses 8x16 sprites, so we need to split the 32x32 image into
        # two 16 pixel tall, rows, and meta-tile each row as 8x16.
        for k in range(0, 32, 16):
            for i in range(0, 32, 8):
                for j in range(0, 16, 8):
                    encode_tile(i, j + k, output_file)


    frame += 1
