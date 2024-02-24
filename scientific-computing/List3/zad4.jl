include("./Functions.jl")
using .Functions

function f(x)
    return sin(x) - (1/4)x^2
end

function pf(x)
    return cos(x) - (1/2)x
end

a = 1.5
b = 2.0
x0 = 1.5
delta = (1/2) * 10^(-5)
epsilon = (1/2) * 10^(-5)
r, v, it, err = Functions.mbisekcji(f, a, b, delta, epsilon)
println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")

r, v, it, err = Functions.mstycznych(f, pf, x0, delta, epsilon, 10)
println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")

x0 = 1.0
x1 = 2.0
r, v, it, err = Functions.msiecznych(f, x0, x1, delta, epsilon, 10)
println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")
