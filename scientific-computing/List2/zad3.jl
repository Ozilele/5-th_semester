using SpecialMatrices
using LinearAlgebra

function calculate_relative_error(x, reference_x)
    # Euclidean norm of vectors subtraction
    error_norm = norm(x - reference_x) 
    # Euclidean norm
    reference_norm = norm(reference_x)
    # Relative error
    relative_error = error_norm / reference_norm
    return relative_error
end

function calcGauss(A, b) 
    x = A\b
    return x
end

function calcInverse(A, b)
    x = inv(A)*b
    return x
end

function hilb(n::Int)
    # Function generates the Hilbert matrix  A of size n,
    #  A (i, j) = 1 / (i + j - 1)
    # Inputs:
    #	n: size of matrix A, n>=1
    #
    #
    # Usage: hilb(10)
    #
    # Pawel Zielinski
    if n < 1
        error("size n should be >= 1")
    end
    return [1 / (i + j - 1) for i in 1:n, j in 1:n]
end

# Funkcja do generowania macierzy danego rozmiaru i na podstawie podanego uwarunkowania c
function matcond(n::Int, c::Float64)
    if n < 2
        return "Size of n should be > 1"
    end
    if c < 1.0
        return "Condition number c of a matrix should be >= 1.0"
    end
    A = rand(n, n)
    F = svd(A) # rozkład svd(wedlug wartości osobliwych)
    U, S, V = F # U to macierz lewych wektorów osobliwych
    #S to macierz diagonalna wartości osobliwych, V to macierz prawych wektorów osobliwych
    return U * diagm(0 => [LinRange(1.0, c, n);])*V # pomnozenie macierzy U i V^T, 
    # gdzie V^T to macierz transponowana przez macierz diagonalną S z odpowiednimi 
    # wartościami na diagonali jako zakres od 1.0 do c z równymi odstępami
end

for n in 2:1:15
    A = hilb(n) # macierz Hilberta
    x = ones(Float64, n) # wektor jednostkowy n stopnia
    b = A * x
    x_gauss = calcGauss(A, b)
    x_inverse = calcInverse(A, b)
    relative_error_gauss = calculate_relative_error(x_gauss, x)
    relative_error_inverse = calculate_relative_error(x_inverse, x)
    # println("Rozmiar macierzy n = $n, Błąd względny: $relative_error")
    # println("$(cond(A)) & $(relative_error_gauss) & $(relative_error_inverse)\\ \n\\hline")
    println("$n & $(cond(A)) & $(relative_error_gauss) & $(relative_error_inverse)\\\\ \n\\hline")
end 

println("--------------------------")
sizes = [5, 10, 20]
conditions = [1.0, 10.0, 10^3, 10^7, 10^12, 10^16]

for size in sizes
    for condition in conditions 
        A = matcond(size, condition)
        x = ones(size)
        b = A * x
        x_gauss = calcGauss(A, b)
        x_inverse = calcInverse(A, b)
        relative_error_gauss = calculate_relative_error(x_gauss, x)
        relative_error_inverse = calculate_relative_error(x_inverse, x)
        println("$size & $condition & $(relative_error_gauss) & $(relative_error_inverse)\\\\ \n\\hline")
    end
end
