include("./Blocksys.jl")
include("matrixgen.jl")

using .blocksys
using .matrixgen
using SparseArrays
using LinearAlgebra

JUMP = 1500
REPETITIONS = 10
MAX_SIZE = 45000
BLOCK_SIZE = 4

function printToFile(x::Vector{Float64}, file) 
    n = length(x)
    for i in 1:n
        println(file, x[i])
    end
    close(file)
end

function readMatrixAndVector(matrixFile, vectorFile, outputFile)
    try 
        matrix_A_file = open(matrixFile, "r")
        vector_B_file = open(vectorFile, "r")
        
        size = 0
        blockSize = 0
        A_rows = Int[]
        A_cols = Int[]
        A_vals = Float64[]
        Vector_B = Float64[]

        for (i, line) in enumerate(eachline(matrix_A_file))
            if i == 1
                elements = split(line, " ")
                size = parse(Int64, elements[1])
                blockSize = parse(Int64, elements[2])
            elseif i != 1
                elements = split(line, " ")
                push!(A_rows, parse(Int64, elements[1]))
                push!(A_cols, parse(Int64, elements[2]))
                push!(A_vals, parse(Float64, elements[3]))
            end
        end

        for (i, line) in enumerate(eachline(vector_B_file))
            if i != 1
                push!(Vector_B, parse(Float64, line))
            end
        end

        close(matrix_A_file)
        close(vector_B_file)

        A = sparse(A_rows, A_cols, A_vals)
        B = Vector_B
        # gauss_elimination!(A, B, blockSize, size)
        # x = solve_gauss(A, B, blockSize, size)
        # pivots = gauss_elimination_with_partial_pivoting!(A, B, blockSize, size)
        # x = solve_gauss_with_partial_pivoting(A, B, blockSize, size, pivots)
        # LU_decomposition!(A, size, blockSize)
        # x = solveLU(A, B, size, blockSize)
        pivots = LU_decomposition_with_partial_pivoting!(A, size, blockSize)
        x = solveLU_with_partial_pivoting(A, B, size, blockSize, pivots)
        file = open(outputFile, "w")
        printToFile(x, file)
    catch e
        println("Wystąpił błąd: $e")
    end
end

matrix_File_path = "data/Dane10000_1_1/A.txt"
vector_File_path = "data/Dane10000_1_1/b.txt"
outputFile = "results/lu_pivot/10k.txt"
# readMatrixAndVector(matrix_File_path, vector_File_path, outputFile)

function calculate_relative_error(x, reference_x)
    error_norm = norm(x - reference_x) 
    reference_norm = norm(reference_x)
    # Bląd względny
    relative_error = error_norm / reference_norm
    return relative_error
end

function readMatrixAndCalcB(matrixFile, outputFile)
    try 
        matrix_A_file = open(matrixFile, "r")
        size = 0
        blockSize = 0
        A_rows = Int[]
        A_cols = Int[]
        A_vals = Float64[]

        for (i, line) in enumerate(eachline(matrix_A_file))
            if i == 1
                elements = split(line, " ")
                size = parse(Int64, elements[1])
                blockSize = parse(Int64, elements[2])
            elseif i != 1
                elements = split(line, " ")
                push!(A_rows, parse(Int64, elements[1]))
                push!(A_cols, parse(Int64, elements[2]))
                push!(A_vals, parse(Float64, elements[3]))
            end
        end

        close(matrix_A_file)
        A = sparse(A_rows, A_cols, A_vals)
        x = ones(Float64, size)
        x = sparse(x)
        gauss_elimination!(A, x, blockSize, size)
        b = solve_gauss(A, x, blockSize, size) # obliczenie wektora prawych stron
        b = sparse(b)

        A_old = sparse(A_rows, A_cols, A_vals)
        gauss_elimination!(A_old, b, blockSize, size)
        x_approx = solve_gauss(A_old, b, blockSize, size)
        x_ref = ones(Float64, size)
        # Obliczanie błędu względnego
        relative_error = calculate_relative_error(x_approx, x_ref)
        println("Error is $relative_error")

        out_file = open(outputFile, "w")
        println(out_file, relative_error)

        printToFile(x_approx, out_file)
    catch e
        println("Wystąpił błąd: $e")
    end
end

function calcRightSide(A, size, blockSize)
    x = ones(Float64, size)
    # LU_decomposition!(A, size, blockSize)
    # b = solveLU(A, x, size, blockSize)
    pivots = LU_decomposition_with_partial_pivoting!(A, size, blockSize)
    b = solveLU_with_partial_pivoting(A, x, size, blockSize, pivots)
    # gauss_elimination!(A, x, blockSize, size)
    # b = solve_gauss(A, x, blockSize, size)
    return b
end

matrix_File_path = "data/Dane50000_1_1/A.txt"
file_name = "results/b_calc/50000.txt"
# readMatrixAndCalcB(matrix_File_path, file_name)

function runTest(A, b, size, blockSize)
    pivots = LU_decomposition_with_partial_pivoting!(A, size, blockSize)
    solveLU_with_partial_pivoting(A, b, size, blockSize, pivots)
    # LU_decomposition!(A, size, blockSize)
    # solveLU(A, b, size, blockSize)
    # gauss_elimination!(A, b, blockSize, size)
    # solve_gauss(A, b, blockSize, size)
end

function testAlgorithms()
    for i in JUMP:JUMP:MAX_SIZE
        totalTime = 0
        totalMemory = 0
        for rep in 1:REPETITIONS
            A = blockmat(i, BLOCK_SIZE, 1.0)
            b = calcRightSide(A, i, BLOCK_SIZE) # right side always with the same alg
            # b = calculateRightSide(A, i, BLOCK_SIZE)
            (_, time, memory) = @timed runTest(A, b, i, BLOCK_SIZE) # test with different alg
            totalTime += time
            totalMemory += memory
        end
        println("(", i, ", ", string(totalTime / REPETITIONS), ", ", string(totalMemory / REPETITIONS), ")", ",")
    end
end

testAlgorithms()

