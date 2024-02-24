include("./Functions.jl")
using .Functions
using Test

@testset "Newton" begin 
   @test Functions.mstycznych(x -> x^2 - 1, x -> 2x, 2.0, 0.01, 0.1, 1)[4] == 1
end

# (x^2 -1) = (x - 1)(x + 1)
@testset "Bisekcja" begin 
    @test Functions.mbisekcji(x -> x^2 - 1, -10.0, 10.0, 0.01, 0.1)[4] == 1
end

@testset "Sieczne" begin 
    @test Functions.msiecznych(x -> x^2 - 1, -10.0, 10.0, 0.01, 0.1, 10)[4] == 1
end