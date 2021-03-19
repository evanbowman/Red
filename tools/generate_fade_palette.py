# The gameboy color has no cpu opcodes for multiplication. I could write some
# complicated algorithm to do this stuff on the gameboy's cpu, but I'm going to
# cheat and just use canned data. If you feed the assembly code for a color
# palette into this script, it will output a canned fade animation, 32 steps in
# size.


def get_rgb(bgr_555):
    r = 0x1F & bgr_555
    g = (0x3E0 & bgr_555) >> 5
    b = (0x7C00 & bgr_555) >> 10
    return (r, g, b)


lines = []


with open('palette_data.txt') as data:
    for line in data:
        vector = []
        parsed = line[3:].split(',')
        parity = False
        coll = ""
        for elem in parsed:
            p = elem.strip()
            p = p.strip("$")
            if parity:
                coll = p + coll
                coll.strip()
                parity = False
                vector.append(get_rgb(int(coll, 16)))
                coll = ""
            else:
                coll = p + coll
                parity = True
        lines.append(vector)


def lerp(a, b, t):
    return a * t + (1 - t) * b


def blend(lhs, rhs, amount):
    return (int(lerp(lhs[0], rhs[0], amount)),
            int(lerp(lhs[1], rhs[1], amount)),
            int(lerp(lhs[2], rhs[2], amount)))


black = (0, 0, 1)


def to_gbc_color(c):
    fmt = '{0:0{1}X}'.format(((c[0]) + ((c[1]) << 5) + ((c[2]) << 10)), 4)

    print("$" + fmt[2:4] + ",$" + fmt[0:2], end = ", ")


for i in range(0, 32):
    print(".blend_" + str(i) + "::")
    for line in lines:
        print("DB ", end="")
        for elem in line:
            to_gbc_color(blend(black, elem, i / 31))
        print("")
    print(".blend_" + str(i) + "_end::")
