##
push!(LOAD_PATH, "./src/simutils/")
using DiffEqOperators
using DifferentialEquations
using OrdinaryDiffEq
using LinearAlgebra
using Plots
using DataInterpolations
using TimerOutputs

using Simutils
set_standard_plot_properties()

## Defining constants for string property
T = 100.0 # N
μ = 0.01 # Kg/m
sim_time = (0.0, 1.0)
string_length = 2*pi
number_of_spatial_cells = 100

# Defining constants for time property
Δt = 0.001
t_vector = sim_time[1]:Δt:sim_time[2]
frequency = 50
x_excitation = sin.(2*pi*frequency*t_vector)

f_excitation = gaussian_excitation_function(100, 0.005, sim_time, 0.1, 0.017)
internal_positions = internal_node_positions(0, string_length, number_of_spatial_cells)

## Initial conditions
x_0 = zeros(number_of_spatial_cells)
dx_0 = zeros(number_of_spatial_cells)
c_squared = zeros(100)
c_squared[1:70] .= T/μ
c_squared[70:end] .= 0.1*T/μ


f = in_place_1D_string_with_coefficients(string_length, number_of_spatial_cells, c_squared, [f_excitation], [50])
prob = SecondOrderODEProblem(f, dx_0, x_0, sim_time)

## timing
to = TimerOutput()

## Simulate
solvers =  [Tsit5(), TRBDF2(), Rosenbrock23(), AutoTsit5(Rosenbrock23()), Midpoint(), Vern7()]
solver = solvers[6]
sol = @timeit to "simulation" solve(prob, solver)

energy = energy_of_string(sol, string_length, number_of_spatial_cells, c_squared, T)
root_squared_error(x1, x2) = vec(sum(sqrt.((x1-x2).^2), dims=1))

## plot image of state compared with analytical solution
excitation_energy_plot(sol, energy, f_excitation, sim_time, 0.0001, solver_name = repr(solver))
display(to)