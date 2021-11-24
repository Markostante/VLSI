import os
from glob import glob
import subprocess
from time import time


def solve_instance(cores, model, in_file, out_dir):
    # Run the chosen model
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

    in_dir = "../CP/in"
    model = "../CP/src/final_model.mzn"
    out_dir = "../CP/out/heuristics"
    for in_file in glob((os.path.abspath(os.path.join(in_dir, '*.dzn')))):
    #in_file = glob((os.path.abspath(os.path.join(in_dir, 'ins-9.dzn'))))[0]
        solve_instance(cores, model, in_file, out_dir)


if __name__ == '__main__':
    main()