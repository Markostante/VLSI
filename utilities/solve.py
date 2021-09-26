import argparse
import os
from glob import glob
import subprocess
from time import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--model", help="Path to the .mzn model", required=True, type=str)
    parser.add_argument("-i", "--in_dir", help="Path to the directory containing the input .dzn instances", required=True, type=str)
    parser.add_argument("-o", "--out_dir", help="Path to the directory that will contain the output solutions in .txt format", required=True, type=str)
    parser.add_argument("-c", "--cores", help="Number of cores", required=False, type=int) #FORSE DA TOGLIERE
    parser.add_argument("-s", "--stat", help="Output solver statistics", action='store_true')
    args = parser.parse_args()

    model = args.model
    in_dir = args.in_dir
    out_dir = args.out_dir
    cores = args.cores if args.cores is not None else 1
    
    for in_file in glob(os.path.join(in_dir, '*.dzn')):
        command = f'minizinc --solver Gecode -p {cores} -t 300000 --solver-statistics {model} {in_file}' \
            if args.stat else f'minizinc --solver Gecode -p {cores} -t 300000 {model} {in_file}'
        instance_name = in_file.split('/')[-1]
        instance_name = instance_name[:len(instance_name) - 4]
        out_file = os.path.join(out_dir, instance_name + '-out.txt')
        with open(out_file, 'w') as f:
            print(f'{out_file}:', end='\t', flush=True)
            start_time = time()
            subprocess.run(command.split())#, stdout=f)
            elapsed_time = time() - start_time
            print(f'{elapsed_time * 1000:.1f} ms')
            if (elapsed_time * 1000) < 300000:
                subprocess.run(command.split(), stdout=f)
                f.write('{}'.format(elapsed_time))


if __name__ == '__main__':
    main()