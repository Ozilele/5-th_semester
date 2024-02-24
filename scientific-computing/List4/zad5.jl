include("./Functions.jl")
using .Functions

e = Base.MathConstants.e

function f1(x)
    return e^(x)
end

function f2(x)
    return x^2*sin(x)
end

# Functions.rysujNnfx(f1, 0.0, 1.0, 5)
ilorazy = Functions.ilorazyRoznicowe([-1.0, 0.0, 1.0, 2.0], [-1.0, 0.0, -1.0, 2.0])
wspolczynniki = Functions.naturalna([-1.0, 0.0, 1.0, 2.0], ilorazy)
print(wspolczynniki)

# Functions.rysujNnfx(f1, 0.0, 1.0, 10)
# Functions.rysujNnfx(f1, 0.0, 1.0, 15)
# Functions.rysujNnfx(f2, -1.0, 1.0, 5)
# Functions.rysujNnfx(f2, -1.0, 1.0, 10)
# Functions.rysujNnfx(f2, -1.0, 1.0, 15)
