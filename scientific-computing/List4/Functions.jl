module Functions
using PyPlot

# x - wektor długości n + 1 zawierający węzły x0,...,xn
# x[1]=x0, ... , x[n+1]=xn
# f - wektor długości n + 1 zawierający wartości interpolowanej funkcji w węzłach f(x0), ..., f(xn)
function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    n = length(f)
    # fx[1] = f[1] # c0 = f(x0)
    # Algorytm Newtona wzoru interpolacyjnego

    res = [value for value in f]
    println("-----")
    for i in 1:n
        for j in n:-1:i+1
            res[j] = (res[j] - res[j-1]) / (x[j] - x[j - i])
        end
    end
    return res
end

# x – wektor długości n + 1 zawierający węzły x0,...,xn
# fx - wektor długości n + 1 zawierający ilorazy róznicowe
# t - punkt, w którym nalezy obliczyc wartość wielomianu
function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(fx)
    nt = fx[n]
    for k in n-1:-1:1
        nt = fx[k] + (t - x[k]) * nt
    end
    return nt
end

# x - wektor długości n + 1 zawierający węzły x0,..., xn
# fx - wektor długości n + 1 zawierający ilorazy róznicowe f[x0, x1], f[x0, x1, x2], ...
function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(fx)
    a = [value for value in fx]

    for i in n-1:-1:1
        a[i] = fx[i] - a[i + 1] * x[i]
        for j in i+1:n-1
            a[j] = a[j] - a[j + 1] * x[i]
        end
    end

    return a
end

# funkcja interpolująca funkcję f(x) w przedziale [a,b] za pomocą wielomianu interpolacyjnego stopnia n w postaci Newtona i rysująca wielomian interpolacyjny i interpolowaną funkcję
function rysujNnfx(f, a::Float64, b::Float64, n::Int)
    if a > b
        a, b = b, a
    end

    x = Vector{Float64}(undef, n + 1)
    y = Vector{Float64}(undef, n + 1)
    delta = zero(Float64)

    for k in 1:n+1
        x[k] = a + delta
        y[k] = f(x[k])
        delta += (b - a) / n
    end

    n = (n + 1) * 10

    ilorazy = ilorazyRoznicowe(x, y)
    interpolationX = Vector{Float64}(undef, n)
    interpolationY = Vector{Float64}(undef, n)
    realVals = Vector{Float64}(undef, n)

    delta = zero(Float64)
    for i in 1:n
        interpolationX[i] = a + delta
        interpolationY[i] = warNewton(x, ilorazy, interpolationX[i])
        realVals[i] = f(interpolationX[i])
        delta += (b - a) / (n - 1)
    end

    clf()
    plot(interpolationX, interpolationY, label = "zinterpolowane", linewidth = 1.5, alpha = 0.5, color = "#527853")
    plot(interpolationX, realVals, label = "f(x)", linewidth = 1.5, alpha = 0.5, color = "#3348DC")
    legend(title = "Interpolacja")
    # savefig(string("wykresy/plot", f, "-", n, ".png"))
    show()
end

end
