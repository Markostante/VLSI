import argparse
import os
from glob import glob
import subprocess
from time import time


def solve_instance(cores, model, in_file, out_dir):
    # command to run the model
    command = f'minizinc --solver Gecode -p {cores} -t 300000 {model} {in_file}'

    instance_name = in_file.split('/')[-1] if os.name == 'nt' else in_file.split('/')[-1]
    instance_name = instance_name[:len(instance_name) - 4]
    out_file = os.path.join(out_dir, instance_name + '-out.txt')
    with open(out_file, 'w') as f:
        print(f'{out_file}:', end='\n', flush=True)
        start_time = time()
        subprocess.run(command.split())
        elapsed_time = time() - start_time
        print(f'{elapsed_time * 1000:.1f} ms')
        if (elapsed_time * 1000) < 300000:
            subprocess.run(command.split(), stdout=f)
            f.write('{}'.format(elapsed_time))


def main():
    cores = 1
    model = "/Users/Marco/Downloads/VLSI-main-2/CP/basic_model.mzn"
    in_file = "/Users/Marco/Downloads/VLSI-main-2/CP/in/ins-16.dzn"
    out_dir = "/Users/Marco/Downloads/VLSI-main-2/CP/out"

    solve_instance(cores, model, in_file, out_dir)


if __name__ == '__main__':
    main()
