def read_instance(f):
    print(f)
    file = open(f)
    width = int(file.readline())
    n_circuits = int(file.readline())
    DX = []
    DY = []
    for i in range(n_circuits):
        piece = file.readline()
        split_piece = piece.strip().split(" ")
        DX.append(int(split_piece[0]))
        DY.append(int(split_piece[1]))
    return width, n_circuits, DX, DY

def write_instance(width, n_circuits, DX, DY, out_path="./file.dzn"):
    file = open(out_path, mode="w")
    file.write(f"width = {width};\n")
    file.write(f"n = {n_circuits};\n")
    file.write(f"DX = {DX};\n")
    file.write(f"DY = {DY};")
    file.close()