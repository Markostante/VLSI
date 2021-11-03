import sys
import os
import re
from instances_to_dzn import write_instance, read_instance

if __name__ == "__main__":
    in_path = "C:\\Users\\Ale\\PycharmProjects\\VLSI\\VLSI\\instances\\"
    out_path = "C:\\Users\\Ale\\PycharmProjects\\VLSI\\VLSI\\CP\\in\\"
    if len(sys.argv) >= 2:
        in_path = sys.argv[1]
    if len(sys.argv) == 3:
        out_path = sys.argv[2]
    files = os.listdir(in_path)

    list_instances = []
    for f in files:
        obj = re.search("^ins-[0-9]+.txt", f)
        if obj is not None:
            width, n_pieces, DX, DY = read_instance(in_path + f)
            f2 = f.replace(".txt", ".dzn")
            write_instance(width, n_pieces, DX, DY, out_path+f2)