import os
import numpy as np
from z3 import *
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

    # Coordinates of the points
    x = IntVector('x',n_circuits)  
    y = IntVector('y',n_circuits)

    # Actual dimensions
    dx_r = IntVector('dx_r', n_circuits)
    dy_r = IntVector('dy_r', n_circuits)

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
        domain_x.append(x[i] + dx_r[i] <= width)
        domain_y.append(y[i]>=0)
        domain_y.append(y[i] + dy_r[i] <= height)
    
        for j in range(i+1, n_circuits):
            no_overlap.append(Or(x[i]+dx_r[i] <= x[j], x[j]+dx_r[j] <= x[i], y[i]+dy_r[i] <= y[j], y[j]+dy_r[j] <= y[i]))

        # If a circuit is squared, then force it to be not rotated 
        opt.add(If(dx[i]==dy[i],And(dx[i]==dx_r[i],dy[i]==dy_r[i]),Or(And(dx[i]==dx_r[i],dy[i]==dy_r[i]),And(dx_r[i]==dy[i],dy_r[i]==dx[i]))))

    opt.add(domain_x + domain_y + no_overlap)

    # Cumulative constraints
    cumulative_y = z3_cumulative(y, dy_r, dx_r, width)
    cumulative_x = z3_cumulative(x, dx_r, dy_r, sum(dy_r))

    opt.add(cumulative_x + cumulative_y)

    # Boundaries constraints
    max_width = [z3_max([x[i] + dx_r[i] for i in range(n_circuits)]) <= width]
    max_height = [z3_max([y[i] + dy_r[i] for i in range(n_circuits)]) <= sum(dy_r)]

    opt.add(max_width + max_height)

    # Maximum time of execution
    opt.set("timeout", 300000)

    x_sol = []
    y_sol = []

    dx_sol = []
    dy_sol = []

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
            dx_sol.append(model.evaluate(dx_r[i]).as_string())
            dy_sol.append(model.evaluate(dy_r[i]).as_string())
        height_sol = model.evaluate(height).as_string()

        # Storing the result
        write_solution(width, n_circuits, dx_sol, dy_sol, x_sol, y_sol, height_sol, out_file, elapsed_time)
    
    else:
        elapsed_time = time.time() - start_time
        print(f'{elapsed_time * 1000:.1f} ms')
        print("Solution not found")

def main():
    in_dir = "../../instances"
    out_dir = "../out/rotation"
    for in_file in glob((os.path.abspath(os.path.join(in_dir, '*.txt')))):
    #in_file = glob((os.path.abspath(os.path.join(in_dir, 'ins-1.txt'))))[0]
        solve_instance(in_file, out_dir)
    


if __name__ == '__main__':
    main()
