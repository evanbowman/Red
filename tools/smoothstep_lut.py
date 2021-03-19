def smoothstep(edge0, edge1, x):
    x2 = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)

    return x2 * x2 * (3 - 2 * x2);


def clamp(x, lower, upper):
    if x < lower:
        return lower
    elif x > upper:
        return upper
    return x


count = 0


print("DB ", end="")

for i in range(0, 256):
    print('${0:0{1}X},'.format(int(255 * smoothstep(0, 255, i)), 2), end=" ")
    count += 1
    if count > 7:
        count = 0
        print("")
        print("DB ", end="")
