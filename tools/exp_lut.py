#
# Now, we could write code to calculate the player's EXP scaling in the game
# itself, but then we'd have to write the code in assembly, and it would take
# up a bunch of rom space. Becuase there are only 99 possible level values for
# the player, and each levelup exp constant occupies two bytes, our algorithm
# for EXP scaling would have to take up fewer than ~200 bytes to even be worth
# the trouble.
#
# tl;dr we could do this in code, but it's a small lut, so not worth it really.
#
# Using canned data is actually more flexible, as it's much easier to change
# python code if we want to play with the level scaling.
#


import math


fill = 14
current_filled = 0

print("r1_exp_leveling_lut::")

for i in range(1, 99):
    if current_filled == 0:
        print("DB ", end="")

    n = i * 0.5
    exp = math.floor(0.106 * ((0.75 * (n * 2)) ** 2) + 8.702 * n)

    print('${0:0{1}X},'.format(exp & 0x00ff, 2), end='')
    print('${0:0{1}X}, '.format((exp & 0xff00) >> 8, 2), end='')
    current_filled += 2

    if current_filled == fill:
        current_filled = 0
        print("")

print("r1_exp_leveling_lut_end::")
