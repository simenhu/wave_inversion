module Simple_wave_sim

push!(LOAD_PATH, "./src/simutils/")
using DiffEqOperators
using DifferentialEquations
using Plots
using Interact
plotly()

using Simutils

ω = 1
k = 1
c = (ω/k)^2
number_of_spatial_cells = 100
dx = 1/(number_of_spatial_cells+1)
ord_spacial_deriv = 2

# Initial conditions
u_0 = 0.2.*sin.(range(0, 2*pi, length=number_of_spatial_cells))
u_dot_0 = zeros(number_of_spatial_cells)

# Defining diff.eq
A_x = CenteredDifference{1}(2, 2, dx, number_of_spatial_cells)
Q = Dirichlet0BC(Float64)
u_dot(du, u, p, t) = c*A_x*Q*u

## Simulate
prob = SecondOrderODEProblem(u_dot, u_dot_0, u_0, (0.0, 1.0))
sol = solve(prob, Tsit5())

## Showing results
du = plot(sol[1:100, 1:10:end])
u = plot(sol[101:end, 1:10:end])
display(plot(u, du, layout = (2,1)))
end