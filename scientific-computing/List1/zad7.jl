
# Function which calculates approximation of derivative and approximation's error
# arg - Argument dla którego jest liczona wartość pochodnej funkcji
# func - zdefiniowana w zadaniu funkcja
function approximate_derivative(dArr, precArr, arg, func)
    for n in 0:54
        h = 2.0^(-n)
        approximation = (func(arg + h) - func(arg)) / h
        precision_error = abs(derivative(arg) - approximation)
        push!(dArr, approximation)
        push!(precArr, precision_error)
    end
end

function f(x)
    return sin(x) + cos(3*x)
end

function derivative(x) 
    return cos(x) - 3*sin(3*x)
end

approximate_derivative_arr = Float64[]
precision_error_arr = Float64[]
approximate_derivative(approximate_derivative_arr, precision_error_arr, 1.0, f)
println(approximate_derivative_arr)
println("----------------------")
println(precision_error_arr)
