def read_instance(f):
    print(f)
    file = open(f)
    width = int(file.readline())
    n_pieces = int(file.readline())
    DX = []
    DY = []
    for i in range(n_pieces):
        piece = file.readline()
        split_piece = piece.strip().split(" ")
        DX.append(int(split_piece[0]))
        DY.append(int(split_piece[1]))
    return width, n_pieces, DX, DY


def write_instance(width, n_pieces, DX, DY, out_path="./file.dzn"):
    file = open(out_path, mode="w")
    file.write(f"width = {width};\n")
    # height_max = compute_height_max(DX, DY, width)
    # file.write(f"height_max = {height_max};\n")
    file.write(f"n = {n_pieces};\n")
    file.write(f"DX = {DX};\n")
    file.write(f"DY = {DY};")
    file.close()


def compute_height_max(x, y, w):
    l_max = sum(y)
    max_x = max(x)
    max_y = max(y)
    w_blocks = w // max_x
    l_max = -(l_max // -w_blocks)
    l_max = max_y if l_max < max_y else l_max
    return l_max
