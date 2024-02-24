include("./Functions.jl")
using .Functions

delta = 10^(-4)
epsilon = 10^(-4)
e_value = Base.MathConstants.e
println(e_value)

function f(x)
    return e_value^(x) - 3x
end

# e^x = 3x
# e^x - 3x = 0
a = 0.0
b = 1.0
r, v, it, err = Functions.mbisekcji(f, a, b, delta, epsilon)
println("Pierwiastek to $r, wartość funkcji $v, liczba iteracji: $it, znak błędu: $err")
