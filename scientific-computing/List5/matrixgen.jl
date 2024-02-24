# Pawel Zielinski
module matrixgen
using SparseArrays 

using LinearAlgebra

export  blockmat

function matcond(n::Int, c::Float64)
	# Function generates a random square matrix A of size n with
	# a given condition number c.
	# Inputs:
	#	n: size of matrix A, n>1
	#	c: condition of matrix A, c>= 1.0
	#
	# Usage: matcond(10, 100.0)
	#
	# Pawel Zielinski
    if n < 2
     error("size n should be > 1")
    end
    if c< 1.0
     error("condition number  c of a matrix  should be >= 1.0")
    end
    (U,S,V)=svd(rand(n,n))
    return U*diagm(0 =>[LinRange(1.0,c,n);])*V'
end

	


  function blockmat(n::Int, l::Int, ck::Float64)
		# Function generates a random block sparse matrix A of size n with
		# a given condition number ck of inner block Ak and it save the output
		# matrix in a text file.
		# Inputs:
		#	n: size of block matrix A, n>1
		# l: size of inner matrices Ak, n mod l =0 (n is  divisible by l)
		#	ck: condition of inner matrix Ak, ck>= 1.0	
		# outputfile: name of the output text file
		#
		# Usage: blockmat(100, 4 ,10.0, "A.txt")
		#		
		#
		#  the output file format
	  #  n  l              <--- the size of block matrix A, the size of inner matrices Ak
		#  i1  j1   A[i1,j1] <--- a non-zero element of block matrix A 
		#  i2  j2   A[i2,j2] <--- a non-zero element of block matrix A 
		#  i3  j3   A[i3,j3] <--- a non-zero element of block matrix A 
		#  ...
		#  ...
		#  EOF
		#
					
    if n < 2
     error("size n should be > 1")
    end
		if n%l!=0 
			error("n is not divisible by l")
		end
					
		nb=div(n,l)
		Ak=Matrix{Float64}(undef, l, l)
		# l(l-1)/2 * v-1 + 
		size = nb * l * l + 3 * (nb - 1) * l

		cols = Array{Int}(undef, size)
		rows = Array{Int}(undef, size)
		vals = Array{Float64}(undef, size)

		index = 1
		for k in 1:nb
			Ak = matcond(l, ck)
			for i in 1:l, j in 1:l
				cols[index] = (k - 1) * l + i
				rows[index] = (k - 1) * l + j
				vals[index] = Ak[i, j]
				index += 1
			end
			
			if k < nb
				for i in 1:l
					cols[index] = (k - 1) * l + i
					rows[index] = k * l + i
					vals[index] = 0.3 * rand()
					index += 1
				end
		 	end

			if k > 1
				for i in 1:l
					cols[index] = (k - 1) * l + i
					rows[index] = (k - 1) * l - 1
					vals[index] = 0.3 * rand()
					index += 1

					cols[index] = (k - 1) * l + i
					rows[index] = (k - 1) * l
					vals[index] = 0.3 * rand()
					index += 1
				end
			end 
	 	end

		return sparse(cols, rows, vals)
		# end	 # do
	end # blockmat
		
end # matrixgen

# open(outputfile, "w") do f
# 	println(f, n," ",l)
# 	for k in 1:nb
# 		Ak=matcond(l, ck)
# 		for i in 1:l, j in 1:l
# 			println(f,(k-1)*l+i," ",(k-1)*l+j," ", Ak[i,j])
# 		end
# 		if k<nb
# 		   for i in 1:l
# 				println(f,(k-1)*l+i," ",k*l+i," ",0.3*rand())
# 			  end
# 		end
# 		if k>1
# 	   for i in 1:l
# 			 println(f,(k-1)*l+i," ",(k-1)*l," ",0.3*rand())
# 		 end
# 		end 
# 	end