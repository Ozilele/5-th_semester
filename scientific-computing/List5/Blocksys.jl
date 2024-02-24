module blocksys
export gauss_elimination!, solve_gauss, gauss_elimination_with_partial_pivoting!, solve_gauss_with_partial_pivoting, LU_decomposition!, LU_decomposition_with_partial_pivoting!, solveLU, solveLU_with_partial_pivoting

using SparseArrays

# Gauss elimination without partial pivoting
function gauss_elimination!(A!::SparseMatrixCSC{Float64, Int64}, b!::Vector{Float64}, blockSize::Int64, n::Int64)    
    for i in 1:n-1
        for j in i+1:min(blockSize + i, n)
            factor = A![j, i] / A![i, i]
            A![j, i] = 0.0
            for k in i+1:min(blockSize + i, n)
                A![j, k] -= factor * A![i, k]
            end
            b![j] -= factor * b![i]    
        end
    end
end

# Gauss elimination with partial pivoting
function gauss_elimination_with_partial_pivoting!(A!::SparseMatrixCSC{Float64, Int64}, b!::Vector{Float64},   blockSize::Int64, n::Int64)::Vector{Int64}
    pivots = collect(1:n) # [1, 2, 3, ..., n] table of pivots

    for i in 1:n-1
        row = 0.0
        col = 0.0

        for j in i:min(blockSize + i, n)
            if abs(A![pivots[j], i]) > col
                col = abs(A![pivots[j], i])
                row = j
            end
        end

        pivots[row], pivots[i] = pivots[i], pivots[row] # swap of rows

        for k in i+1:min(blockSize + i, n)
            factor = A![pivots[k], i] / A![pivots[i], i]
            A![pivots[k], i] = 0.0

            for m in i+1:min(2 * blockSize + i, n) # 2 * blockSize + i because of swapped rows
                A![pivots[k], m] -= factor * A![pivots[i], m]
            end

            b![pivots[k]] -= factor * b![pivots[i]]
        end
    end

    return pivots
end

# function for solving triangular matrix A 
function solve_gauss(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, blockSize::Int64, n::Int64)
    x = zeros(Float64, n)
    x[n] = b[n] / A[n, n]
    for i in n-1:-1:1
        current_sum = 0
        for j in i+1:min(n, i + blockSize)
            current_sum += x[j] * A[i, j]
        end
        x[i] = (b[i] - current_sum) / A[i, i]
    end
    return x
end

function solve_gauss_with_partial_pivoting(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, blockSize::Int64, n::Int64, pivots::Vector{Int64})
    x = zeros(Float64, n)
    for k in 1:n-1
        for i in k+1:min(n, k + 2 * blockSize)
            b[pivots[i]] -= A[pivots[i], k] * b[pivots[k]]
        end
    end

    for i in n:-1:1
        currentSum = 0
        for j in i+1:min(n, i + 2 * blockSize)
            currentSum += A[pivots[i], j] * x[j]
        end
        x[i] = (b[pivots[i]] - currentSum) / A[pivots[i], i]
    end
    return x
end

# function for implementing LU decomposition
function LU_decomposition!(A!::SparseMatrixCSC{Float64, Int64}, n::Int64, blockSize::Int64) 
    for i in 1:n-1
        for k in i+1:min(n, i + blockSize)
            factor = A![k, i] / A![i, i]
            A![k, i] = factor
            for j in i+1:min(n, blockSize + i)
                A![k, j] -= factor * A![i, j]
            end
        end 
    end
end

# function for testing LU decomposition
function solveLU(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, blockSize::Int64)
    x = zeros(Float64, n)

    for i in 1:n-1 # Solving equation Ly = b
        for j in i+1:min(n, i + blockSize)
            b[j] -= A[j, i] * b[i]
        end
    end

    for i in n:-1:1 # Solving equation Ux = y
        currentSum = 0
        for j in i+1:min(n, i + blockSize)
            currentSum += A[i, j] * x[j]
        end
        x[i] = (b[i] - currentSum) / A[i, i]
    end
    return x
end

function LU_decomposition_with_partial_pivoting!(A!::SparseMatrixCSC{Float64, Int64}, n::Int64, blockSize::Int64) 
    pivots = collect(1:n) # [1, 2, 3, ..., n] table of pivots
    for i in 1:n-1
        row = 0.0
        col = 0.0

        for j in i:min(blockSize + i, n)
            if abs(A![pivots[j], i]) > col
                col = abs(A![pivots[j], i])
                row = j
            end
        end

        pivots[row], pivots[i] = pivots[i], pivots[row] # swap of rows

        for k in i+1:min(n, i + blockSize)
            factor = A![pivots[k], i] / A![pivots[i], i]
            A![pivots[k], i] = factor
            for j in i+1:min(n, 2 * blockSize + i) # 2* because of swapped rows
                A![pivots[k], j] -= factor * A![pivots[i], j]
            end
        end 
    end
    return pivots
end

# function for testing LU decomposition with partial pivoting
function solveLU_with_partial_pivoting(A::SparseMatrixCSC{Float64, Int64}, b::Vector{Float64}, n::Int64, blockSize::Int64, pivots::Vector{Int64})
    x = zeros(Float64, n)
    for i in 1:n-1 # Solving equation Ly = b
        for j in i+1:min(n, 2 * blockSize + i)
            b[pivots[j]] -= A[pivots[j], i] * b[pivots[i]]
        end
    end

    for i in n:-1:1 # Solving equation Ux = y
        currentSum = 0
        for j in i+1:min(n, 2 * blockSize + i)
            currentSum += A[pivots[i], j] * x[j]
        end
        x[i] = (b[pivots[i]] - currentSum) / A[pivots[i], i]
    end
    return x
end

end