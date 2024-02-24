include("./Functions.jl")
using .Functions

delta = 10^(-5)
epsilon = 10^(-5)
e = Base.MathConstants.e

function f1(x)
    return e^(1 - x) - 1
end

function pf1(x)
    return -e^(1 - x)
end

function f2(x)
    return x*e^(-x)
end

function pf2(x)
    return -e^(-x)*(x - 1)
end

# a = 0.5
# b = 2.0
# r, v, it, err = Functions.mbisekcji(f1, a, b, delta, epsilon)
# println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")
x0 = 3.0
r, v, it, err = Functions.mstycznych(f2, pf2, x0, delta, epsilon, 15)
println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")
# x0 = -1.5
# x1 = 0.5
# r, v, it, err = Functions.msiecznych(f2, x0, x1, delta, epsilon, 10)
# println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")