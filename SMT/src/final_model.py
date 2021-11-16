import os
import numpy as np
from z3 import *
from itertools import combinations
import time
from glob import glob

def read_instance(instance):

    with open(instance, 'r') as in_file:

        lines = in_file.read().splitlines()

        width = lines[0]
        n_circuits = lines[1]

        dx = []
        dy = []

        for i in range(int(n_circuits)):
            line = lines[i + 2].split(' ')
            dx.append(int(line[0]))
            dy.append(int(line[1]))

        return int(width), int(n_circuits), dx, dy

def write_solution(width, n_circuits, dx, dy, x_sol, y_sol, height, solution, elapsed_time):

    with open(solution, 'w+') as out_file:

        out_file.write('{} {}\n'.format(width, height))
        out_file.write('{}\n'.format(n_circuits))

        for i in range(n_circuits):
            out_file.write('{} {} {} {}\n'.format(dx[i], dy[i], x_sol[i], y_sol[i]))
        
        out_file.write("----------\n==========\n")

        out_file.write('{}'.format(elapsed_time))


def z3_max(vector):
    maximum = vector[0]
    for value in vector[1:]:
        maximum = If(value > maximum, value, maximum)
    return maximum 


def z3_cumulative(start, duration, resources, total):

    cumulative = []
    for u in resources:
        cumulative.append(
            sum([If(And(start[i] <= u, u < start[i] + duration[i]), resources[i], 0)
                 for i in range(len(start))]) <= total
        )
    return cumulative

def solve_instance(in_file, out_dir):

    instance_name = in_file.split('/')[-1]
    instance_name = instance_name[:len(instance_name) - 4]
    out_file = os.path.join(out_dir, instance_name + '-out.txt')

    width, n_circuits, dx, dy = read_instance(in_file)

    # Coordinates of the circuits
    x = IntVector('x',n_circuits)  
    y = IntVector('y',n_circuits)

    # Maximum plate height to minimize
    height = z3_max([y[i] + dy[i] for i in range(n_circuits)])

    # Setting the optimizer
    opt = Optimize()
    opt.minimize(height)

    # Setting domain and no overlap constraints
    domain_x = []
    domain_y = []
    no_overlap = []

    for i in range(n_circuits):
        domain_x.append(x[i] >= 0)
        domain_x.append(x[i] + dx[i] <= width)
        domain_y.append(y[i]>=0)
        domain_y.append(y[i] + dy[i] <= height)
        
        for j in range(i+1, n_circuits):
            no_overlap.append(Or(x[i]+dx[i] <= x[j], x[j]+dx[j] <= x[i], y[i]+dy[i] <= y[j], y[j]+dy[j] <= y[i]))

    opt.add(domain_x + domain_y + no_overlap)

    # Cumulative constraints
    cumulative_y = z3_cumulative(y, dy, dx, width)
    cumulative_x = z3_cumulative(x, dx, dy, sum(dy))

    opt.add(cumulative_x + cumulative_y)

    # Boundaries constraints
    max_width = [z3_max([x[i] + dx[i] for i in range(n_circuits)]) <= width]
    max_height = [z3_max([y[i] + dy[i] for i in range(n_circuits)]) <= sum(dy)] 

    opt.add(max_width + max_height)

    # Symmetry breaking constraints
    #areas_index = np.argsort([dx[i]*dy[i] for i in range(n_circuits)])
    #biggests = areas_index[-1], areas_index[-2]

    #symmetry_biggests = Or(x[biggests[1]] > x[biggests[0]], And(x[biggests[1]] == x[biggests[0]], y[biggests[1]] >= y[biggests[0]]))
    #symmetry_bottom_left = And(x[biggests[1]] * 2 <= width, y[biggests[1]] * 2 <= height)

    #opt.add(symmetry_biggests)
    #opt.add(symmetry_bottom_left)
    

    # Maximum time of execution
    opt.set("timeout", 300000)

    x_sol = []
    y_sol = []

    # Solve

    print(f'{out_file}:', end='\t', flush=True)
    start_time = time.time()

    if opt.check() == sat:
        model = opt.model()
        elapsed_time = time.time() - start_time
        print(f'{elapsed_time * 1000:.1f} ms')
        # Getting values of variables
        for i in range(n_circuits):
            x_sol.append(model.evaluate(x[i]).as_string())
            y_sol.append(model.evaluate(y[i]).as_string())
        height_sol = model.evaluate(height).as_string()

        # Storing the result
        write_solution(width, n_circuits, dx, dy, x_sol, y_sol, height_sol, out_file, elapsed_time)
    
    else:
        elapsed_time = time.time() - start_time
        print(f'{elapsed_time * 1000:.1f} ms')
        print("Solution not found")

def main():
    in_dir = "/Users/Marco/Downloads/VLSI-main-2/instances"
    for in_file in glob(os.path.join(in_dir, '*.txt')):
        #in_file = "/Users/Marco/Downloads/VLSI-main-2/instances/ins-12.txt"
        out_dir = "/Users/Marco/Downloads/VLSI-main-2/SMT/out/final"
        solve_instance(in_file, out_dir)
    


if __name__ == '__main__':
    main()